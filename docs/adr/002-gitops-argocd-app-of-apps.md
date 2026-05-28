# ADR-002: GitOps via ArgoCD app-of-apps

## Status
Accepted

## Context
Platform components (cert-manager, ingress-nginx, Kyverno, Falco) need a consistent
deployment model with Git as the audit trail. The bootstrap question — who deploys
the GitOps tool itself — needed a clear answer.

## Decision
Ansible bootstraps the cluster and installs ArgoCD once via Helm. ArgoCD then manages
all platform components, including itself, via a root Application pointing at
`k8s/platform/`. Each platform component is its own ArgoCD Application (app-of-apps
pattern), ordered with sync waves.

## Consequences
Git becomes the single source of truth for all platform state after initial bootstrap.
Sync waves provide explicit ordering for components with dependencies (e.g. ClusterIssuer
after cert-manager CRDs). The Ansible playbook is idempotent but only needs to run once
per cluster lifecycle.
