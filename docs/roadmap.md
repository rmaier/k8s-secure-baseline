# Roadmap — k8s-secure-baseline

A self-managed Kubernetes platform on commodity infrastructure: provisioned with IaC,
configured with Ansible, deployed via GitOps, hardened to CKS standards, and documented
against EU compliance baselines. Runs on one VM today; architected so the workload layer
migrates to any hyperscaler unchanged.

## Goals

Five purposes, mutually reinforcing:

| Goal | How the platform serves it |
|---|---|
| Portfolio (regulated industries) | README-as-architecture, control-mapping docs, ADRs |
| CKS prep | kubeadm cluster you harden: audit policy, admission control, network policy, runtime detection |
| OpenTofu / Terragrunt | Remote state, DRY provider/env config, two real cloud roots |
| Ansible | Node hardening (CIS), kubeadm bootstrap, ArgoCD handoff |
| ArgoCD | App-of-apps owns the whole platform; Git = audit trail |
| Compliance (NIS-2 / DSGVO / BSI) | requirement → control → implementation → evidence tables |

**The differentiator is the documentation.** Most DevOps portfolios prove "I can deploy."
This one proves "I can deploy *and* map it to NIS-2 Art. 21 / BSI SYS.1.6 with evidence."

## Locked decisions

- **kubeadm, not k3s** — CKS exam fidelity; control-plane hardening is configured the kubeadm way.
- **No cloud abstraction at the IaC layer** — portability lives at the k8s/ArgoCD layer; per-cloud Tofu roots stay independent.
- **Remote state before CI/CD** — state holds secrets, so encryption/locking/access-control on it is itself a documentable control.
- **Image signing via Kyverno `verifyImages`; commit signing via ArgoCD gpg** — different layers, kept precise.

## Phases

### Phase 0 — Foundation cleanup
- `tofu state mv` to absorb the `vps` refactor without destroy/recreate
- Migrate to remote state: GCS backend, encryption + locking
- Introduce Terragrunt root for DRY remote-state/provider config (`tofu/gcp/`)
- Repo rename + `docs/` scaffold + first ADRs: `001-kubeadm-over-k3s`, `002-gitops-argocd`, `003-no-iac-cloud-abstraction`

### Phase 1 — Working GitOps platform (kubeadm VPS)
- Swap Flannel → Cilium (CNI replacement on the running cluster — disruptive, document in a runbook/ADR)
- Ansible roles: `node-hardening`, existing `kubeadm`, `cilium`, `argocd-bootstrap`
- ArgoCD installed by Ansible, then manages itself + platform via app-of-apps
- Platform apps (ArgoCD-owned): cert-manager (LE HTTP-01 ClusterIssuer), ingress-nginx
- Demo app deployed by ArgoCD with real TLS
- **Done:** `argocd app list` all green; demo app reachable over HTTPS by domain

### Phase 2 — Security hardening (CKS layer)
- Kyverno policies: no `:latest`, require resource limits, disallow root/privileged, require non-root
- Falco runtime threat detection
- API server audit policy the kubeadm way (`/etc/kubernetes/audit-policy.yaml` + apiserver flags + volume mounts in the static manifest)
- kube-bench (CIS) run, findings triaged, P0/P1 remediated and documented
- **Done:** kube-bench score documented; audit log captures secret reads, exec, API access

### Phase 3 — Secrets + supply chain
- External Secrets Operator → GCP Secret Manager (SecretStore abstraction keeps it portable; no secrets in Git)
- Trivy in GitHub Actions: PR gate, fail on CRITICAL
- Cosign signs images in CI; Kyverno `verifyImages` blocks unsigned at admission; ArgoCD gpg verifies commits
- **Done:** a PR with a CRITICAL CVE is blocked; an unsigned image is rejected

### Phase 4 — Second provider (GKE) to prove portability
- New independent root `tofu/gke/` (not a shared abstraction); Terragrunt env for it
- Same ArgoCD app definitions deploy unchanged
- Document the diff: Workload Identity vs SA keys, managed control plane (CKS control-plane work is not possible here — that's why it lives in Phase 2 on kubeadm), storage classes
- **Done:** the diff doc — migration runbook + compliance evidence

### Phase 5 — Compliance documentation (ongoing)
- `docs/compliance/nis2-mapping.md` — Art. 21: access control (RBAC+Kyverno), incident handling (Falco+runbook), supply chain (Cosign+Trivy), encryption (cert-manager + etcd-at-rest), logging (audit policy)
- `docs/compliance/dsgvo-controls.md` — secret management (ESO), encryption, access logging, data minimization
- `docs/compliance/bsi-grundschutz-sys16.md` — SYS.1.6 container building-block requirement mapping
- CI/CD: `tofu plan` on PR / `apply` on merge via Workload Identity Federation; tag `v0.1.0`

## Coherence note

All control-plane CKS work lands in Phase 2 on kubeadm *because* GKE (Phase 4) hides the
control plane. kubeadm-first is what makes both the CKS and the portability goals achievable.
