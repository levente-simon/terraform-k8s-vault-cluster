variable "k8s_config_path"            { type = string }
variable "vault_host"                 { type = string }
variable "vault_ui_host"              { type = string }
variable "vault_key_shares"           { type = number }
variable "vault_key_threshold"        { type = number }

variable "vault_conf_persist" {
  type    = string
  default = "false"
}

variable "tls_crt" {
  type      = string
  sensitive = true
}

variable "tls_key" {
  type      = string
  sensitive = true
}

variable "k8s_host" {
  type      = string
  sensitive = true
}

variable "k8s_client_certificate" {
  type      = string
  sensitive = true
  default   = ""
}

variable "k8s_client_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "k8s_cluster_ca_certificate" {
  type      = string
  sensitive = true
  default   = ""
}

variable "k8s_cluster_client_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "nr_of_vault_pods" { 
  type    = number
  default = 3
}

variable "namespace" {
  type    = string
  default = "vault"
}

variable "vault_audit_storage_size" {
  type    = string
  default = "6Gi"
}

variable "vault_data_storage_size" {
  type    = string
  default = "6Gi"
}

variable "vault_sa_config" {
  type = string
  default = <<EOT
  standalone:
    enabled: true
    config: |
      ui = true
      listener "tcp" {
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        tls_cert_file = "/vault/userconfig/tls-server/tls.crt"
        tls_key_file = "/vault/userconfig/tls-server/tls.key"
      }

%s

      storage "raft" {
        path = "/vault/data"
      }
      service_registration "kubernetes" {}
EOT
}

variable "vault_ha_config" {
  type = string
  default = <<EOT
  ha:
    enabled: true
    replicas: 3
    raft:
      enabled: true
      setNodeId: true
      config: |
        ui = true
        listener "tcp" {
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          tls_cert_file = "/vault/userconfig/tls-server/tls.crt"
          tls_key_file = "/vault/userconfig/tls-server/tls.key"
          tls_ca_cert_file = "/vault/userconfig/vault-ca-crt/tls.crt"
        }

%s

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
	
variable "vault_ha_enabled" {
  type = bool
  default = true
}

variable "vault_autounseal" {
  type    = bool
  default = false
}

variable "vault_unseal_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vault_unseal_address" {
  type    = string
  default = ""
}

variable "vault_unseal_key_name" {
  type    = string
  default = ""
}

variable "vault_unseal_mount_path" {
  type    = string
  default = ""
}

variable "vault_unseal_config" {
  type    = string
  default = <<EOT
        seal "transit" {
          address = "%s"
          disable_renewal = "false"
          key_name = "%s"
          mount_path = "%s"
          tls_skip_verify = "true"
        }
EOT
}

variable "vault_unseal_helm_cfg" {
  type    = string
  default = <<EOT
  extraSecretEnvironmentVars:
    - envName: VAULT_TOKEN
      secretName: unseal-token
      secretKey: TOKEN
EOT
}
