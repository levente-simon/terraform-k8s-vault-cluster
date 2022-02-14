terraform { }

provider "kubernetes" {
  host                   = var.k8s_host
#  client_certificate     = var.k8s_client_certificate
#  client_key             = var.k8s_client_key
  cluster_ca_certificate = var.k8s_cluster_ca_certificate
  token                  = var.k8s_cluster_client_token
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
#    client_certificate     = var.k8s_client_certificate
#    client_key             = var.k8s_client_key
    cluster_ca_certificate = var.k8s_cluster_ca_certificate
    token                  = var.k8s_cluster_client_token
  }
}

variable "module_depends_on" {
  type    = any
  default = []
}

resource "kubernetes_namespace" "vault" {
  depends_on = [ var.module_depends_on ]

  lifecycle {
    ignore_changes  = all 
  }

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "vault_ca_cert" {
  depends_on = [ kubernetes_namespace.vault ]
  metadata {
    name       = "vault-ca-crt"
    namespace  = var.namespace
  }

  type       = "kubernetes.io/tls"
  data       = {
      "tls.crt" = var.tls_crt
      "tls.key" = var.tls_key
  }
}

resource "kubernetes_secret" "tls_server" {
  depends_on = [ kubernetes_namespace.vault ]
  metadata {
    name       = "tls-server"
    namespace  = var.namespace
  }

  type       = "kubernetes.io/tls"
  data       = {
      "tls.crt" = var.tls_crt
      "tls.key" = var.tls_key
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [ kubernetes_namespace.vault ]
  name       = "vault"

  lifecycle {
    ignore_changes  = all 
  }

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = var.namespace
  values     = [ "${format(file("${path.module}/etc/vault-config.yaml"),
                     var.vault_host,
                     var.vault_config,
                     var.vault_ui_host)}"
               ]
}

#data "external" "setup_vault" {
#  depends_on  = [ helm_release.cert-manager ]
#
#  program     = [
#                  "${path.module}/bin/vault-setup.sh",
#                  "-f", var.k8s_config_path,
#                  "-n", var.namespace,
#                  "-i", var.nr_of_vault_pods,
#                  "-p", var.vault_conf_persist,
#                  "-s", var.vault_key_shares,
#                  "-t", var.vault_key_threshold
#                ]
#}

