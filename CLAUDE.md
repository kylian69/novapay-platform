# NovaPay Platform — Claude Code Memory

Plateforme GitOps zero-trust sur Kubernetes (projet master DevSecOps 2026).
Monorepo GitOps : ArgoCD synchronise 2 clusters depuis ce repo.
**Jamais de `kubectl apply` manuel en prod. Jamais de secret en clair.**

## Commandes — utilise CELLES-CI, ne devine pas

```bash
# Validation manifests
kubeconform -strict -summary <fichier.yaml>   # PAS kubeval (déprécié)
helm lint apps/<svc>/chart
helm template apps/<svc>/chart | kubeconform -strict -summary -
kustomize build apps/<svc>/overlays/staging

# IaC
terraform fmt -check && terraform validate    # dans infra/terraform/<module>/
checkov -d infra/ --quiet

# Sécurité
trivy image --severity CRITICAL,HIGH <image>
trivy fs --severity CRITICAL,HIGH .

# Clusters
export KUBECONFIG=~/.kube/prod               # cluster prod
export KUBECONFIG=~/.kube/staging            # cluster staging
cilium status
cilium hubble
```

## Contraintes NON NÉGOCIABLES

1. **Zéro secret en clair.** Jamais de valeur de secret dans un fichier.
   → Toujours via `ExternalSecret` (ESO → Vault). Pas de `Secret` brut, pas de SealedSecret statique.
2. **Images par digest uniquement.** `image@sha256:...` — jamais `:latest` ni tag mutable.
3. **Pas d'Ingress.** Routage via Gateway API : `HTTPRoute`, `GRPCRoute` uniquement.
4. **Pas de kubectl apply en prod.** Toute modif d'état passe par un commit Git → ArgoCD.
5. **Pas de privileged / runAsRoot.** `securityContext` restrictif obligatoire sur tous les pods.

## Stack & versions

- Kubernetes 1.35, Cilium CNI (eBPF + Gateway API), Istio Ambient (ztunnel + waypoint, **pas sidecar**)
- Grafana Alloy (pipeline OTEL unifié — **pas Promtail, pas Grafana Agent**)
- Helm pour le packaging app, Kustomize pour les overlays par env
- ArgoCD sync waves : `platform/` se déploie avant `apps/`

## Architecture infra (ce que tu ne peux pas deviner)

- **2 clusters** : `prod` (HA, 3 control-planes sur 3 machines physiques dont 1 PC léger arbitre etcd)
  + `staging` (single CP, non-HA assumé — voir ADR 0001)
- **On-prem** : 2 serveurs Proxmox (40c/192Go) + PC légers (4c/8Go) comme générateurs de charge
- **Cloud** : DNS managé + S3/GCS pour backups Velero/Loki/Tempo + cluster éphémère EKS/GKE (phase 08 uniquement)
- **3 microservices** : `api-gateway`, `payment-svc` (critique, waypoint L7 + SLO strict), `notification-svc`

## Structure du repo (4 couches)

```
infra/       → Terraform + Ansible (bootstrap manuel, 1 fois)
clusters/    → App of Apps ArgoCD (prod + staging)
platform/    → Briques infra cluster (cilium, vault, observability, security...)
apps/        → Microservices NovaPay (api-gateway, payment-svc, notification-svc)
docs/        → ADRs, runbooks, chaos reports, finops, threat model
```

## Conventions de commit

Format : `<type>(<scope>): <description> <NOVA-XX> <#statut>`
Exemples :
```
feat(payment-svc): add retry logic NOVA-21 #in-progress
fix(cilium): correct gateway api httproute NOVA-13 #review
chore(infra): add .gitkeep placeholders NOVA-10 #done
```
Statuts Jira : `#in-progress` | `#review` | `#done`
Voir `.github/COMMIT_CONVENTION.md` pour la référence complète.

## Workflow attendu

1. Travaille **un ticket Jira à la fois** (demande lequel si pas précisé).
2. Avant de coder : expose ton plan en 3-4 lignes, attends validation.
3. Après avoir codé : lance les lint/scan ci-dessus AVANT de proposer un commit.
4. Ne commite jamais sans que j'aie revu le diff.
5. Si une contrainte ci-dessus est violée, **refuse et signale-le explicitement**.

## Garde-fous

- Ne modifie jamais `*.tfstate`, `*.tfvars`, `*.kubeconfig`, fichiers sous `~/.kube/`
- En cas de doute sur une commande destructive (`terraform destroy`, `velero restore`, `kubectl delete`), demande confirmation explicite avant d'exécuter.