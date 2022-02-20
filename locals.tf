locals {
  vault_config = format(var.vault_config, var.vault_unseal_token == "" ? "" :
    format(var.vault_unseal_config, var.vault_unseal_address, var.vault_unseal_key_name, var.vault_unseal_mount_path))
}
