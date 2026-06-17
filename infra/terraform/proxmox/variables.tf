# ── Connexion Proxmox ─────────────────────────────────────────────────────────

variable "proxmox_endpoint_a" {
  description = "URL API Proxmox serveur A (ex: https://192.168.1.10:8006)"
  type        = string
}

variable "proxmox_endpoint_b" {
  description = "URL API Proxmox serveur B (ex: https://192.168.1.11:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token Proxmox (format: terraform@pve!token-name=secret). Injecté via Vault/secret CI, jamais en clair."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Ignorer le certificat TLS Proxmox (true en environnement lab on-prem)"
  type        = bool
  default     = true
}

# ── Nœuds Proxmox ─────────────────────────────────────────────────────────────

variable "proxmox_node_a" {
  description = "Nom du nœud Proxmox sur le serveur physique A"
  type        = string
  default     = "pve-a"
}

variable "proxmox_node_b" {
  description = "Nom du nœud Proxmox sur le serveur physique B"
  type        = string
  default     = "pve-b"
}

variable "vm_datastore" {
  description = "Datastore Proxmox pour les disques des VMs"
  type        = string
  default     = "local-lvm"
}

# ── Réseau ────────────────────────────────────────────────────────────────────

variable "network_gateway" {
  description = "Passerelle du réseau des VMs"
  type        = string
  default     = "192.168.1.1"
}

variable "network_bridge" {
  description = "Bridge Proxmox utilisé par les VMs"
  type        = string
  default     = "vmbr0"
}

variable "network_prefix" {
  description = "Préfixe CIDR du réseau des VMs"
  type        = number
  default     = 24
}

variable "dns_servers" {
  description = "Serveurs DNS des VMs"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

# ── Template VM ───────────────────────────────────────────────────────────────

variable "vm_template_id" {
  description = "ID du template Proxmox (Ubuntu 24.04 cloud-init)"
  type        = number
  default     = 9000
}

variable "vm_user" {
  description = "Utilisateur SSH créé dans les VMs"
  type        = string
  default     = "novapay"
}

variable "vm_ssh_public_key" {
  description = "Clé SSH publique injectée dans les VMs"
  type        = string
}

# ── IPs — Cluster PROD ────────────────────────────────────────────────────────

variable "prod_cp1_ip" {
  description = "IP control-plane prod 1 (srv-A)"
  type        = string
  default     = "192.168.1.20"
}

variable "prod_cp2_ip" {
  description = "IP control-plane prod 2 (srv-B)"
  type        = string
  default     = "192.168.1.21"
}

variable "prod_worker1_ip" {
  description = "IP worker prod 1 (srv-A)"
  type        = string
  default     = "192.168.1.30"
}

variable "prod_worker2_ip" {
  description = "IP worker prod 2 (srv-B)"
  type        = string
  default     = "192.168.1.31"
}

variable "prod_worker3_ip" {
  description = "IP worker prod 3 (srv-A)"
  type        = string
  default     = "192.168.1.32"
}

variable "prod_vip" {
  description = "IP virtuelle (VIP) du control-plane prod — gérée par kube-vip (hors Terraform)"
  type        = string
  default     = "192.168.1.100"
}

# ── IPs — Cluster STAGING ─────────────────────────────────────────────────────

variable "staging_cp_ip" {
  description = "IP control-plane staging (srv-A)"
  type        = string
  default     = "192.168.1.40"
}

variable "staging_worker1_ip" {
  description = "IP worker staging 1 (srv-A)"
  type        = string
  default     = "192.168.1.50"
}

variable "staging_worker2_ip" {
  description = "IP worker staging 2 (srv-B)"
  type        = string
  default     = "192.168.1.51"
}

# ── IP — Poste de pilotage ────────────────────────────────────────────────────

variable "bastion_ip" {
  description = "IP de la VM poste de pilotage (Claude Code, kubectl, terraform)"
  type        = string
  default     = "192.168.1.10"
}
