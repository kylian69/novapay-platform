# Conventions de commit — NovaPay Platform

## Format

```
<type>(<scope>): <description courte> <NOVA-XX> <#statut-jira>
```

La description est en minuscules, sans point final, max 72 caractères.

## Types

| Type       | Usage |
|------------|-------|
| `feat`     | Nouvelle fonctionnalité ou composant |
| `fix`      | Correction de bug ou de config |
| `chore`    | Tâche technique sans impact fonctionnel (gitkeep, fmt, etc.) |
| `docs`     | Documentation, ADR, runbook |
| `ci`       | Modification des workflows GitHub Actions |
| `refactor` | Refactorisation sans changement de comportement |
| `test`     | Ajout ou modification de tests |
| `security` | Correctif ou durcissement de sécurité |
| `infra`    | Terraform, Ansible, Proxmox |

## Scopes courants

`infra` | `cluster` | `cilium` | `argocd` | `vault` | `observability` |
`security` | `api-gateway` | `payment-svc` | `notification-svc` |
`kyverno` | `istio` | `cert-manager` | `backstage` | `finops` | `chaos`

## Statuts Jira (smart commits)

| Statut          | Effet dans Jira |
|-----------------|-----------------|
| `#in-progress`  | Passe le ticket en "In Progress" |
| `#review`       | Passe le ticket en "Review" |
| `#done`         | Passe le ticket en "Done" |

## Exemples

```bash
# Démarrage d'une tâche
feat(infra): add proxmox terraform provider config NOVA-10 #in-progress

# En cours de développement (pas de statut = pas de transition Jira)
feat(infra): provision control-plane VMs on server-A

# Prêt pour review (PR ouverte)
feat(infra): bootstrap prod cluster HA with kubeadm NOVA-11 #review

# Merge et ticket terminé
feat(cilium): install CNI with gateway api and lb-ipam NOVA-13 #done

# Fix en cours
fix(payment-svc): correct liveness probe path NOVA-21

# Sécurité
security(kyverno): block images without cosign signature NOVA-16 #done

# Docs
docs(adr): add 0001-staging-non-ha decision record NOVA-32 #done
```

## Règles

1. **Une PR par ticket Jira.** Branche nommée `NOVA-XX-description-courte`.
2. **Pas de push direct sur `main`.** Toujours une PR, toujours une review.
3. **Le premier commit d'une branche** doit référencer le ticket avec `#in-progress`.
4. **Le commit de merge** doit clore le ticket avec `#done` ou `#review` selon l'état.
5. **Pas de `WIP` ni de `temp`** dans les messages de commit mergés.
6. En cas de commit multi-lignes, le corps (après une ligne vide) explique le **pourquoi**, pas le comment.

## Body optionnel (pour les commits complexes)

```
feat(istio): enable ambient mesh on prod namespace NOVA-20 #review

Active le mode ambient (ztunnel L4 + waypoint L7 sur payment-svc).
Choix justifié dans docs/adr/0003-ambient-vs-sidecar.md :
- -40% de RAM vs sidecar sur notre workload
- observabilité L7 maintenue via waypoint proxy ciblé
- mTLS strict conservé entre tous les services
```