#!/bin/bash
###########################
# Levente Simon

# NROFPODS=3
NS="-n vault"
KSHS=5
KTSH=3
PERSIST="false"

while getopts f:n:i:c:k:a:u:p:s:t:h arg; do
  case ${arg} in
    f)
     if [[ $(echo ${OPTARG} | cut -d: -f1) == 'base64' ]]; then
       export CONFIG_DATA=$(echo ${OPTARG} | cut -d: -f2)
       KCONF="--kubeconfig <(echo \$CONFIG_DATA | base64 --decode)"
     else
       KCONF="--kubeconfig=${OPTARG}"
     fi
     ;;
    n)
     NS="-n ${OPTARG}"
     ;;
    i)
     NROFPODS=${OPTARG}
     ;;
    c)
     KCONF="${KCONF} --client-certificate=${OPTARG}"
     ;;
    k)
     KCONF="${KCONF} --client-key=${OPTARG}"
     ;;
    a)
     KCONF="${KCONF} --certificate-authority=${OPTARG}"
     ;;
    u)
     KCONF="${KCONF} --server==${OPTARG}"
     ;;
    p)
     if [[ $(echo ${OPTARG} | cut -d: -f1) == 'vault' ]]; then
       PERSIST="vault"
       VAULT_SECRET=$(echo ${OPTARG} | cut -d: -f2)
     else
       PERSIST="${OPTARG}"
     fi
     ;;
    s)
     KSHS="${OPTARG}"
     ;;
    t)
     KTSH="${OPTARG}"
     ;;
    h)
     echo "Usage: $(basename $0) -i <number-of-pods> -c <client-certificate> -k <client-key> -a <certificate-authority> -u <server> -n <namespace> -p <file-to-persist> -s <key-shares> -t <key-threshold> "
     exit;;
  esac
done

# while [[ $(eval "kubectl ${KCONF} ${NS} get pods --no-headers" | grep  Running | wc -l) -ne ${NROFPODS} ]] ; do
while [[ $(eval "kubectl ${KCONF} ${NS} get pods --no-headers" | grep -v Running | wc -l) -ne 0 ]] ; do
  sleep 2
done

first_pod=$(eval "kubectl ${KCONF} ${NS} get pods -o name" | head -1)

while [[ -z $(echo ${INITSTATUS} | sed -e 's/\s//g') ]] ; do
  INITSTATUS=$(eval "kubectl ${KCONF} ${NS} exec ${first_pod} -- vault status -format=json" 2>/dev/null | jq -r .initialized)
  sleep 2
done
if [[ ${INITSTATUS} == "false" ]]; then
  export INIT=$(eval "kubectl ${KCONF} ${NS} exec ${first_pod} -- vault operator init -key-shares=${KSHS} -key-threshold=${KTSH} -format=json" 2>/dev/null)
  RESULT=$(echo ${INIT} | jq  '{"unseal_keys":. | to_entries | map(select(.key | match("_keys_b64"))) | map(.value) | add | join(" "),"root_token":.root_token}')
fi

if [[ ${PERSIST} != "false" ]]; then
  if [[ ${PERSIST} == "vault" ]]; then
    if [[ $(vault kv get -non-interactive=true -field=vault-secret ${VAULT_SECRET} > /dev/null 2>&1) && -z ${RESULT} ]]; then
      RESULT=$(vault kv get -non-interactive=true -field=vault-secret ${VAULT_SECRET} | base64 --decode 2>/dev/null)
    fi
    eval "vault kv patch ${VAULT_SECRET} vault-secret=\$(echo ${RESULT} | base64 -w 0) root_token=\$(echo ${RESULT} | jq -r '.root_token')" 2>/dev/null 1>&2
  else
    if [[ -f ${PERSIST} && -z ${RESULT} ]]; then
      RESULT=$(cat ${PERSIST})
    fi
    echo ${RESULT} > ${PERSIST}
    chmod 600 ${PERSIST}
  fi
fi  

# IFS=", "
read -ra UNSEAL <<< $(echo ${RESULT} | jq -r '.unseal_keys')

if [[ ${#UNSEAL[@]} -ge ${KTSH} ]]; then
  for pod in $(eval "kubectl ${KCONF} ${NS} get pods -o go-template='{{ range  \$i := .items }}{{ range .status.conditions }}{{ if (and (eq .type \"Ready\") (eq .status \"False\")) }}{{ \$i.metadata.name}} {{ end }}{{ end }}{{ end }}'"); do
    while [[ $(eval "kubectl ${KCONF} ${NS} exec ${pod} -- vault status -format=json" 2>/dev/null | jq -r .initialized) != "true" ]] ; do
      sleep 5
    done
    for (( i=0; i <= ${KTSH}-1; ++i )); do
      eval "kubectl ${KCONF} ${NS} exec ${pod} -- vault operator unseal ${UNSEAL[$i]}" 2>/dev/null 1>&2
      sleep 2
    done
  done
else
  RESULT=$(echo '{"unseal_keys":"na","root_token":"na"}' | jq)
fi

echo ${RESULT}
