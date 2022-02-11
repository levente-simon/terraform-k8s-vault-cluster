#!/bin/bash
###########################
# Levente Simon

NROFPODS=3
NS="-n vault"
KSHS=5
KTSH=3


ARGS=$(getopt -o f:n:i:c:k:a:u:p:s:t:h -- $@)
eval set -- ${ARGS}

while true; do
  case $1 in
    -f)
     KCONF="--kubeconfig=$2"
     shift 2;;
    -n)
     NS="-n $2"
     shift 2;;
    -i)
     NROFPODS=$2
     shift 2;;
    -c)
     KCONF="${KCONF} --client-certificate=$2"
     shift 2;;
    -k)
     KCONF="${KCONF} --client-key=$2"
     shift 2;;
    -a)
     KCONF="${KCONF} --certificate-authority=$2"
     shift 2;;
    -u)
     KCONF="${KCONF} --server==$2"
     shift 2;;
    -p)
     PERSIST="$2"
     shift 2;;
    -s)
     KSHS="$2"
     shift 2;;
    -t)
     KTSH="$2"
     shift 2;;
    -h)
     echo "Usage: $(basename $0) -i <number-of-pods> -c <client-certificate> -k <client-key> -a <certificate-authority> -u <server> -n <namespace> -p <file-to-persist> -s <key-shares> -t <key-threshold> "
     exit;;
    --)
     break;;
  esac
done

while [[ $(kubectl ${KCONF} ${NS} get pods | grep  Running | wc -l) -ne ${NROFPODS} ]] ; do
  sleep 2
done

first_pod=$(kubectl ${KCONF} ${NS} get pods -o name|head -1)

INITSTATUS=$(kubectl ${KCONF} ${NS} exec ${first_pod} -- vault status -format=json 2>/dev/null | jq -r .initialized)
if [[ ${INITSTATUS} == "false" ]]; then
  export INIT=$(kubectl ${KCONF} ${NS} exec ${first_pod} -- vault operator init -key-shares=${KSHS} -key-threshold=${KTSH} -format=json 2>/dev/null)
  RESULT=$(echo ${INIT} | jq  '{"unseal_keys":.unseal_keys_b64 | join(" "),"root_token":.root_token}')
fi

if [[ ! -z ${PERSIST} ]]; then
  if [[ -f ${PERSIST} && -z ${RESULT} ]]; then
    RESULT=$(cat ${PERSIST})
  fi
  echo ${RESULT} > ${PERSIST}
  chmod 600 ${PERSIST}
fi  

# IFS=", "
read -ra UNSEAL <<< $(echo ${RESULT} | jq -r '.unseal_keys')

if [[ ${#UNSEAL[@]} -ge ${KTSH} ]]; then
  for pod in $(kubectl ${KCONF} ${NS} get pods -o go-template='{{ range  $i := .items }}{{ range .status.conditions }}{{ if (and (eq .type "Ready") (eq .status "False")) }}{{ $i.metadata.name}} {{ end }}{{ end }}{{ end }}'); do
    while [[ $(kubectl ${KCONF} ${NS} exec ${pod} -- vault status -format=json 2>/dev/null | jq -r .initialized) != "true" ]] ; do
      sleep 5
    done
    for (( i=0; i <= ${KTSH}-1; ++i )); do
      kubectl ${KCONF} ${NS} exec ${pod} -- vault operator unseal ${UNSEAL[$i]} 2>/dev/null 1>&2
      sleep 2
    done
  done
else
  RESULT=$(echo '{"unseal_keys":"na","root_token":"na"}' | jq)
fi

echo ${RESULT}
