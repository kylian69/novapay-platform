# Terraform Proxmox — Provisioning des VMs NovaPay

> Ticket **NOVA-10** — [P01] Installer Proxmox et provisionner les VMs via Terraform.

Provisionne de façon reproductible toutes les VMs des clusters **prod** et
**staging** sur les 2 serveurs Proxmox physiques (40c/192Go).
Provider : [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox) `~> 0.70`.

## Topologie & specs des VMs

Toutes les VMs sont définies dans le map `local.vms` (`vms.tf`) et créées via
`for_each` (une resource par serveur, le provider aliasé ne pouvant pas être
dynamique sous `for_each`).

| VM                 | Cluster | Rôle          | vCPU | RAM    | Disque | IP (défaut)   | Hôte  | vm_id |
|--------------------|---------|---------------|-----:|-------:|-------:|---------------|-------|------:|
| `bastion`          | —       | management    | 4    | 8 Go   | 100 Go | 192.168.1.10  | srv-A | 100   |
| `cp-prod-1`        | prod    | control-plane | 4    | 8 Go   | 50 Go  | 192.168.1.20  | srv-A | 101   |
| `cp-prod-2`        | prod    | control-plane | 4    | 8 Go   | 50 Go  | 192.168.1.21  | srv-B | 102   |
| `worker-prod-1`    | prod    | worker        | 14   | 56 Go  | 200 Go | 192.168.1.30  | srv-A | 111   |
| `worker-prod-2`    | prod    | worker        | 14   | 56 Go  | 200 Go | 192.168.1.31  | srv-B | 112   |
| `worker-prod-3`    | prod    | worker        | 14   | 56 Go  | 200 Go | 192.168.1.32  | srv-A | 113   |
| `cp-staging`       | staging | control-plane | 4    | 8 Go   | 50 Go  | 192.168.1.40  | srv-A | 201   |
| `worker-staging-1` | staging | worker        | 6    | 24 Go  | 100 Go | 192.168.1.50  | srv-A | 211   |
| `worker-staging-2` | staging | worker        | 6    | 24 Go  | 100 Go | 192.168.1.51  | srv-B | 212   |

VIP control-plane prod : `192.168.1.100` (gérée par **kube-vip**, hors Terraform).

## Nœuds bare-metal — NON gérés par Terraform

Conformément à l'architecture (`CLAUDE.md`), ces nœuds sont des **PC légers
(4c/8Go) hors Proxmox**. Ils sont déclarés directement dans l'inventaire Ansible
(`infra/ansible/inventory/hosts.yml`), pas ici :

| Nœud              | Rôle                                              |
|-------------------|---------------------------------------------------|
| `cp-prod-3`       | Arbitre etcd (3ᵉ control-plane du quorum HA prod) |
| `load-generators` | Générateurs de charge (tests perf/chaos)          |

> Le cluster **staging** est volontairement single-CP (non-HA) — cf ADR 0001.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # puis adapter (ne PAS commiter)

terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

> ⚠️ `proxmox_api_token` est **sensible** : l'injecter via Vault / secret CI.
> `terraform.tfvars` et `*.tfstate` sont git-ignorés — aucun secret en clair.

### Pré-requis sur les serveurs Proxmox

- Proxmox VE installé sur srv-A et srv-B (nœuds `pve-a` / `pve-b`).
- Un template cloud-init **Ubuntu 24.04** (`vm_template_id`, défaut `9000`).
- Un token API Proxmox dédié (`terraform@pve!<token>`).

## Alimenter l'inventaire Ansible

```bash
terraform output -json all_vms | jq .
```

## Fichiers

| Fichier                   | Rôle                                            |
|---------------------------|-------------------------------------------------|
| `versions.tf`             | `required_version`, provider, backend (commenté)|
| `providers.tf`            | Providers aliasés `srv_a` / `srv_b`             |
| `variables.tf`            | Variables d'entrée                              |
| `vms.tf`                  | Map `local.vms` + resources `for_each`          |
| `outputs.tf`              | IPs / récap pour Ansible                        |
| `terraform.tfvars.example`| Modèle de configuration                         |
