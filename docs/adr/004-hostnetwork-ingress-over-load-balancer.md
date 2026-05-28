# ADR-004: hostNetwork ingress-nginx over a cloud load balancer

## Status
Accepted

## Context
On a single GCP VPS, exposing HTTP/HTTPS traffic requires either a cloud load balancer
(GCP L4/L7 LB, billed per hour) or a direct binding to host ports. MetalLB was also
considered for a more production-like setup.

## Decision
Run ingress-nginx as a DaemonSet with `hostNetwork: true` and `service.type: ClusterIP`.
The controller binds directly to ports 80 and 443 on the VPS network interface. A
wildcard DNS A record (`*.rudolphmaier.de`) points to the static VPS IP.

## Consequences
No load balancer cost or complexity on a single-node setup. New services are reachable
immediately via subdomain without additional DNS or LB configuration. This approach does
not generalise to multi-node clusters without MetalLB or a cloud LB; that migration is
documented as part of the GKE phase.
