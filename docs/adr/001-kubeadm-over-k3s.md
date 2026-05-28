# ADR-001: Use kubeadm over k3s

## Status
Accepted

## Context
The cluster serves both as a portfolio project and CKS exam preparation. The CKS exam
requires hands-on control-plane hardening (audit policy, admission control, static pod
manifests) which is only accessible on a kubeadm-bootstrapped cluster. k3s abstracts
most of these components away.

## Decision
Use kubeadm to bootstrap the Kubernetes control plane.

## Consequences
CKS-relevant hardening (audit policy, apiserver flags, etcd access) is directly
configurable via static manifests and kubeadm config. Operational overhead is higher
than k3s — upgrades, CNI selection, and certificate management are all manual. This
overhead is intentional: it is the learning surface.
