# ── Providers ─────────────────────────────────────────────────────────────────
# Deux providers aliasés, un par serveur Proxmox physique.
# Le placement d'une VM sur le bon hôte se fait via le bloc `provider` de chaque
# resource (cf vms.tf) — le provider ne pouvant pas être dynamique sous for_each,
# on déclare une resource par serveur, chacune itérant sur ses VMs.

provider "proxmox" {
  alias     = "srv_a"
  endpoint  = var.proxmox_endpoint_a
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure
}

provider "proxmox" {
  alias     = "srv_b"
  endpoint  = var.proxmox_endpoint_b
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure
}
