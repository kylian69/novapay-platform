# ── Outputs : alimentent l'inventaire Ansible (infra/ansible/inventory/hosts.yml)

output "all_vms" {
  description = "Récapitulatif de toutes les VMs Proxmox gérées (nom → ip/host/vm_id)"
  value = {
    for name, vm in local.vms : name => {
      ip           = vm.ip
      vm_id        = vm.vm_id
      proxmox_node = vm.server == "a" ? var.proxmox_node_a : var.proxmox_node_b
    }
  }
}

output "prod_control_planes" {
  description = "IPs des control-planes prod (pour l'inventaire Ansible)"
  value = {
    cp1 = var.prod_cp1_ip
    cp2 = var.prod_cp2_ip
    cp3 = "PC léger bare-metal (arbitre etcd) — hors Terraform, à déclarer dans hosts.yml"
    vip = var.prod_vip
  }
}

output "prod_workers" {
  description = "IPs des workers prod"
  value = {
    worker1 = var.prod_worker1_ip
    worker2 = var.prod_worker2_ip
    worker3 = var.prod_worker3_ip
  }
}

output "staging_nodes" {
  description = "IPs du cluster staging"
  value = {
    cp      = var.staging_cp_ip
    worker1 = var.staging_worker1_ip
    worker2 = var.staging_worker2_ip
  }
}

output "bastion_ip" {
  description = "IP du poste de pilotage"
  value       = var.bastion_ip
}

output "bare_metal_nodes" {
  description = "Nœuds NON gérés par Terraform (PC légers bare-metal) — à configurer manuellement dans l'inventaire Ansible"
  value = {
    cp_prod_3       = "Arbitre etcd (control-plane #3 du quorum HA prod)"
    load_generators = "Générateurs de charge (tests perf/chaos) — PC légers 4c/8Go"
  }
}

output "ansible_inventory_hint" {
  description = "Rappel : exporter les IPs vers l'inventaire Ansible"
  value       = "terraform output -json all_vms | jq ."
}
