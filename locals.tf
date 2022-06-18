locals {
  vault_config = format(
    var.vault_ha_enabled ? var.vault_ha_config : var.vault_sa_config,
    var.vault_autounseal ?
      format(var.vault_unseal_config, var.vault_unseal_address, var.vault_unseal_key_name, var.vault_unseal_mount_path) :
      ""
  )
}
