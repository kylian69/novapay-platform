# ── Définition centralisée des VMs ────────────────────────────────────────────
#
# Toutes les VMs des clusters prod + staging sont décrites dans un seul map.
# Ajouter/retirer une VM = éditer ce map (reproductibilité — cf NOVA-10).
#
# Topologie physique :
#   srv-A / srv-B = 2 serveurs Proxmox (40c/192Go chacun)
#   server = "a" → nœud var.proxmox_node_a (défaut pve-a)
#   server = "b" → nœud var.proxmox_node_b (défaut pve-b)
#
# NON gérés ici (PC légers bare-metal, hors Proxmox — cf CLAUDE.md, voir README) :
#   - cp-prod-3       : arbitre etcd (control-plane #3, quorum HA)
#   - load-generators : générateurs de charge (tests perf/chaos)
#   → provisionnés via l'inventaire Ansible (infra/ansible/inventory/hosts.yml).
#
# Convention vm_id :
#   100-199 → prod    | 200-299 → staging   (1xx/1=cp, 11x=worker)

locals {
  vms = {
    # ── Poste de pilotage ─────────────────────────────────────────────────────
    "bastion" = {
      server = "a"
      vm_id  = 100
      cores  = 4
      memory = 8192
      disk   = 100
      ip     = var.bastion_ip
      tags   = ["management", "bastion"]
    }

    # ── Cluster PROD ──────────────────────────────────────────────────────────
    "cp-prod-1" = {
      server = "a"
      vm_id  = 101
      cores  = 4
      memory = 8192
      disk   = 50
      ip     = var.prod_cp1_ip
      tags   = ["kubernetes", "prod", "control-plane"]
    }
    "cp-prod-2" = {
      server = "b"
      vm_id  = 102
      cores  = 4
      memory = 8192
      disk   = 50
      ip     = var.prod_cp2_ip
      tags   = ["kubernetes", "prod", "control-plane"]
    }
    "worker-prod-1" = {
      server = "a"
      vm_id  = 111
      cores  = 14
      memory = 57344 # 56 Go
      disk   = 200
      ip     = var.prod_worker1_ip
      tags   = ["kubernetes", "prod", "worker"]
    }
    "worker-prod-2" = {
      server = "b"
      vm_id  = 112
      cores  = 14
      memory = 57344
      disk   = 200
      ip     = var.prod_worker2_ip
      tags   = ["kubernetes", "prod", "worker"]
    }
    "worker-prod-3" = {
      server = "a"
      vm_id  = 113
      cores  = 14
      memory = 57344
      disk   = 200
      ip     = var.prod_worker3_ip
      tags   = ["kubernetes", "prod", "worker"]
    }

    # ── Cluster STAGING (single CP, non-HA — cf ADR 0001) ─────────────────────
    "cp-staging" = {
      server = "a"
      vm_id  = 201
      cores  = 4
      memory = 8192
      disk   = 50
      ip     = var.staging_cp_ip
      tags   = ["kubernetes", "staging", "control-plane"]
    }
    "worker-staging-1" = {
      server = "a"
      vm_id  = 211
      cores  = 6
      memory = 24576 # 24 Go
      disk   = 100
      ip     = var.staging_worker1_ip
      tags   = ["kubernetes", "staging", "worker"]
    }
    "worker-staging-2" = {
      server = "b"
      vm_id  = 212
      cores  = 6
      memory = 24576
      disk   = 100
      ip     = var.staging_worker2_ip
      tags   = ["kubernetes", "staging", "worker"]
    }
  }

  vms_srv_a = { for name, vm in local.vms : name => vm if vm.server == "a" }
  vms_srv_b = { for name, vm in local.vms : name => vm if vm.server == "b" }
}

# ── VMs sur le serveur A ──────────────────────────────────────────────────────
resource "proxmox_virtual_environment_vm" "srv_a" {
  provider  = proxmox.srv_a
  for_each  = local.vms_srv_a
  name      = each.key
  node_name = var.proxmox_node_a
  vm_id     = each.value.vm_id
  tags      = each.value.tags

  clone {
    vm_id = var.vm_template_id
    full  = true
  }

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.vm_datastore
    size         = each.value.disk
    interface    = "scsi0"
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.network_prefix}"
        gateway = var.network_gateway
      }
    }
    dns {
      servers = var.dns_servers
    }
    user_account {
      username = var.vm_user
      keys     = [var.vm_ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [clone]
  }
}

# ── VMs sur le serveur B ──────────────────────────────────────────────────────
resource "proxmox_virtual_environment_vm" "srv_b" {
  provider  = proxmox.srv_b
  for_each  = local.vms_srv_b
  name      = each.key
  node_name = var.proxmox_node_b
  vm_id     = each.value.vm_id
  tags      = each.value.tags

  clone {
    vm_id = var.vm_template_id
    full  = true
  }

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.vm_datastore
    size         = each.value.disk
    interface    = "scsi0"
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.network_prefix}"
        gateway = var.network_gateway
      }
    }
    dns {
      servers = var.dns_servers
    }
    user_account {
      username = var.vm_user
      keys     = [var.vm_ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [clone]
  }
}
