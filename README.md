## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.vault](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.vault](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.tls_server](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.vault_ca_cert](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.vault_seal_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [external_external.setup_vault](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_k8s_config_path"></a> [k8s\_config\_path](#input\_k8s\_config\_path) | n/a | `string` | n/a | yes |
| <a name="input_k8s_host"></a> [k8s\_host](#input\_k8s\_host) | n/a | `string` | n/a | yes |
| <a name="input_tls_crt"></a> [tls\_crt](#input\_tls\_crt) | n/a | `string` | n/a | yes |
| <a name="input_tls_key"></a> [tls\_key](#input\_tls\_key) | n/a | `string` | n/a | yes |
| <a name="input_vault_host"></a> [vault\_host](#input\_vault\_host) | n/a | `string` | n/a | yes |
| <a name="input_vault_key_shares"></a> [vault\_key\_shares](#input\_vault\_key\_shares) | n/a | `number` | n/a | yes |
| <a name="input_vault_key_threshold"></a> [vault\_key\_threshold](#input\_vault\_key\_threshold) | n/a | `number` | n/a | yes |
| <a name="input_vault_ui_host"></a> [vault\_ui\_host](#input\_vault\_ui\_host) | n/a | `string` | n/a | yes |
| <a name="input_k8s_client_certificate"></a> [k8s\_client\_certificate](#input\_k8s\_client\_certificate) | n/a | `string` | `""` | no |
| <a name="input_k8s_client_key"></a> [k8s\_client\_key](#input\_k8s\_client\_key) | n/a | `string` | `""` | no |
| <a name="input_k8s_cluster_ca_certificate"></a> [k8s\_cluster\_ca\_certificate](#input\_k8s\_cluster\_ca\_certificate) | n/a | `string` | `""` | no |
| <a name="input_k8s_cluster_client_token"></a> [k8s\_cluster\_client\_token](#input\_k8s\_cluster\_client\_token) | n/a | `string` | `""` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | n/a | `any` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `"vault"` | no |
| <a name="input_nr_of_vault_pods"></a> [nr\_of\_vault\_pods](#input\_nr\_of\_vault\_pods) | n/a | `number` | `3` | no |
| <a name="input_vault_autounseal"></a> [vault\_autounseal](#input\_vault\_autounseal) | n/a | `bool` | `false` | no |
| <a name="input_vault_conf_persist"></a> [vault\_conf\_persist](#input\_vault\_conf\_persist) | n/a | `string` | `"false"` | no |
| <a name="input_vault_config"></a> [vault\_config](#input\_vault\_config) | n/a | `string` | `"        ui = true\n        listener \"tcp\" {\n          address = \"[::]:8200\"\n          cluster_address = \"[::]:8201\"\n          tls_cert_file = \"/vault/userconfig/tls-server/tls.crt\"\n          tls_key_file = \"/vault/userconfig/tls-server/tls.key\"\n          tls_ca_cert_file = \"/vault/userconfig/vault-ca-crt/tls.crt\"\n        }\n\n%s\n    \n        storage \"raft\" {\n          path = \"/vault/data\"\n            retry_join {\n            leader_api_addr = \"https://vault-0.vault-internal:8200\"\n            leader_ca_cert_file = \"/vault/userconfig/vault-ca-crt/tls.crt\"\n            leader_client_cert_file = \"/vault/userconfig/tls-server/tls.crt\"\n            leader_client_key_file = \"/vault/userconfig/tls-server/tls.key\"\n          }\n          retry_join {\n            leader_api_addr = \"https://vault-1.vault-internal:8200\"\n            leader_ca_cert_file = \"/vault/userconfig/vault-ca-crt/tls.crt\"\n            leader_client_cert_file = \"/vault/userconfig/tls-server/tls.crt\"\n            leader_client_key_file = \"/vault/userconfig/tls-server/tls.key\"\n          }\n          retry_join {\n            leader_api_addr = \"https://vault-2.vault-internal:8200\"\n            leader_ca_cert_file = \"/vault/userconfig/vault-ca-crt/tls.crt\"\n            leader_client_cert_file = \"/vault/userconfig/tls-server/tls.crt\"\n            leader_client_key_file = \"/vault/userconfig/tls-server/tls.key\"\n          }\n          autopilot {\n            cleanup_dead_servers = \"true\"\n            last_contact_threshold = \"200ms\"\n            last_contact_failure_threshold = \"10m\"\n            max_trailing_logs = 250000\n            min_quorum = 5\n            server_stabilization_time = \"10s\"\n          }\n        }\n        service_registration \"kubernetes\" {}\n"` | no |
| <a name="input_vault_unseal_address"></a> [vault\_unseal\_address](#input\_vault\_unseal\_address) | n/a | `string` | `""` | no |
| <a name="input_vault_unseal_config"></a> [vault\_unseal\_config](#input\_vault\_unseal\_config) | n/a | `string` | `"        seal \"transit\" {\n          address = \"%s\"\n          disable_renewal = \"false\"\n          key_name = \"%s\"\n          mount_path = \"%s\"\n          tls_skip_verify = \"true\"\n        }\n"` | no |
| <a name="input_vault_unseal_helm_cfg"></a> [vault\_unseal\_helm\_cfg](#input\_vault\_unseal\_helm\_cfg) | n/a | `string` | `"  extraSecretEnvironmentVars:\n    - envName: VAULT_TOKEN\n      secretName: unseal-token\n      secretKey: TOKEN\n"` | no |
| <a name="input_vault_unseal_key_name"></a> [vault\_unseal\_key\_name](#input\_vault\_unseal\_key\_name) | n/a | `string` | `""` | no |
| <a name="input_vault_unseal_mount_path"></a> [vault\_unseal\_mount\_path](#input\_vault\_unseal\_mount\_path) | n/a | `string` | `""` | no |
| <a name="input_vault_unseal_token"></a> [vault\_unseal\_token](#input\_vault\_unseal\_token) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_root_token"></a> [root\_token](#output\_root\_token) | n/a |
| <a name="output_unseal_keys"></a> [unseal\_keys](#output\_unseal\_keys) | n/a |
