variable "k8s_config_path"            { type = string }
variable "vault_host"                 { type = string }
variable "vault_ui_host"              { type = string }
variable "tls_crt"                    { type = string }
variable "tls_key"                    { type = string }
variable "k8s_host"                   { type = string }
variable "k8s_client_certificate"     { type = string }
variable "k8s_client_key"             { type = string }
variable "k8s_cluster_ca_certificate" { type = string }
variable "vault_conf_persist"         { type = string }
variable "vault_key_shares"           { type = number }
variable "vault_key_threshold"        { type = number }

variable "nr_of_vault_pods" { 
  type    = number
  default = 3
}

variable "namespace" {
  type    = string
  default = "vault"
}

variable "vault_config" {
  type = string
  default = <<EOT
        ui = true
          listener "tcp" {
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          tls_cert_file = "/vault/userconfig/tls-server/tls.crt"
          tls_key_file = "/vault/userconfig/tls-server/tls.key"
          tls_ca_cert_file = "/vault/userconfig/vault-ca-crt/tls.crt"
        }
    
        storage "raft" {
          path = "/vault/data"
            retry_join {
            leader_api_addr = "https://vault-0.vault-internal:8200"
            leader_ca_cert_file = "/vault/userconfig/vault-ca-crt/tls.crt"
            leader_client_cert_file = "/vault/userconfig/tls-server/tls.crt"
            leader_client_key_file = "/vault/userconfig/tls-server/tls.key"
          }
          retry_join {
            leader_api_addr = "https://vault-1.vault-internal:8200"
            leader_ca_cert_file = "/vault/userconfig/vault-ca-crt/tls.crt"
            leader_client_cert_file = "/vault/userconfig/tls-server/tls.crt"
            leader_client_key_file = "/vault/userconfig/tls-server/tls.key"
          }
          retry_join {
            leader_api_addr = "https://vault-2.vault-internal:8200"
            leader_ca_cert_file = "/vault/userconfig/vault-ca-crt/tls.crt"
            leader_client_cert_file = "/vault/userconfig/tls-server/tls.crt"
            leader_client_key_file = "/vault/userconfig/tls-server/tls.key"
          }
          autopilot {
            cleanup_dead_servers = "true"
            last_contact_threshold = "200ms"
            last_contact_failure_threshold = "10m"
            max_trailing_logs = 250000
            min_quorum = 5
            server_stabilization_time = "10s"
          }
        }
        service_registration "kubernetes" {}
EOT
}
