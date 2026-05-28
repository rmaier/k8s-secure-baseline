# ADR-005: HTTP-01 ACME challenge over DNS-01

## Status
Accepted

## Context
cert-manager needs to prove domain ownership to Let's Encrypt. Two solver types were
available: HTTP-01 (serves a token over port 80) and DNS-01 (creates a TXT record via
the DNS provider API).

## Decision
Use HTTP-01 with ingressClassName nginx. The VPS has a public IP with port 80 open and
ingress-nginx already handles the challenge path via a temporary Ingress created by
cert-manager.

## Consequences
Certificate issuance works without any DNS provider API credentials in the cluster.
HTTP-01 cannot issue wildcard certificates — each subdomain requires its own certificate
request. If wildcard certificates are needed in the future, DNS-01 with the deSEC
provider would require storing the deSEC API token as a Kubernetes Secret.
