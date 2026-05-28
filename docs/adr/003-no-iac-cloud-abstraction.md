# ADR-003: No cloud abstraction at the IaC layer

## Status
Accepted

## Context
The project targets multiple cloud providers (GCP VPS today, GKE later). A shared
Terraform module abstraction across providers was considered to avoid duplication of
provider-specific resources.

## Decision
Each cloud environment gets its own independent OpenTofu root under `infra/`. There is
no shared abstraction module across providers. Portability is achieved at the Kubernetes
and ArgoCD layer, not the IaC layer.

## Consequences
The same ArgoCD Application definitions deploy unchanged to any Kubernetes cluster
regardless of provider. IaC roots remain small and provider-specific with no leaky
abstractions. Adding a second provider (GKE) means a new `infra/envs/gke/` root, not
changes to existing modules.
