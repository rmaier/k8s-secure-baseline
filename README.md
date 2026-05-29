# k8s-secure-baseline

A compliant GitOps platform baseline — a self-managed Kubernetes cluster on a GCP VPS, provisioned with OpenTofu/Terragrunt, configured with Ansible, and managed via ArgoCD. Hardened to CKS standards and documented against NIS-2, DSGVO, and BSI-Grundschutz baselines.

See [`docs/roadmap.md`](docs/roadmap.md) for the full project goals and phased plan.

## Repo structure

```
infra/          OpenTofu + Terragrunt — provisions GCP VM and DNS
ansible/        Ansible — bootstraps kubeadm, Cilium, ArgoCD
k8s/            Kubernetes manifests — ArgoCD app-of-apps
docs/           Architecture, compliance mappings, ADRs, runbooks
.agents/        Agent config (skills, MCP servers) — shared across Claude Code and OpenCode
```

## 1. Provision the VPS

See [`infra/README.md`](infra/README.md) for full details.

```bash
cd infra/envs/gcp-vps
export TF_VAR_desec_token=<your-token>

# With Terragrunt
terragrunt init && terragrunt apply -var-file=terraform.tfvars

# Without Terragrunt
tofu init && tofu apply -var-file=terraform.tfvars
```

## 2. Bootstrap the cluster

See [`ansible/README.md`](ansible/README.md) for full details.

Set `argocd_repo_url` in `ansible/inventory/group_vars/k8s_control_plane.yml` first, then:

```bash
cd ansible
ansible k8s_control_plane -m ping     # verify SSH
ansible-playbook playbooks/k8s.yml
```

This runs four plays in sequence: system prerequisites → kubeadm control plane → Cilium CNI → ArgoCD bootstrap.

After a successful run: `kubectl get nodes` shows `Ready`, `argocd app list` shows all platform apps syncing from Git.

## 3. Cilium CNI

[docs](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#k8s-install-quick)

Cilium is installed automatically by the Ansible playbook (`ansible/roles/cilium`) via Helm:

```bash
helm upgrade --install cilium cilium/cilium \
  --version 1.19.4 \
  --namespace kube-system
```

### Cilium CLI

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

```bash
cilium status
cilium connectivity test
```

## 4. Access ArgoCD

The UI is available at `https://argocd.rudolphmaier.de` (TLS via Let's Encrypt).

**Initial login:**

```bash
# Get the auto-generated admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Username: `admin`. After first login, change the password via User Info → Update Password, then delete the secret:

```bash
kubectl delete secret argocd-initial-admin-secret -n argocd
```

**Login options:**

| Method | How |
|---|---|
| Admin account | Initial password from secret above |
| Local accounts | Add `accounts.<name>: login` to `argocd-cm` ConfigMap |
| GitHub SSO | Configure Dex in `argocd-cm` / `argocd-secret` (~10 lines) |

For production hardening: set up SSO, then disable admin with `admin.enabled: "false"` in `argocd-cm`.

## 5. Tooling setup

### tflint and tofu fmt

tflint [repo](https://github.com/terraform-linters/tflint)

```bash
curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip
unzip tflint_linux_amd64.zip
sudo install -c -v tflint /usr/local/bin/
```

```bash
tofu fmt -diff
tflint --recursive
```

### Trivy

[website](https://trivy.dev/docs/latest/getting-started/installation/)

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.70.0
# check
trivy fs --scanners misconfig --exit-code 1 --severity HIGH,CRITICAL .
```

### pre-commit

[website](https://pre-commit.com/)

```bash
sudo apt install pre-commit
# Install pre-commit hooks into the repo
pre-commit install
pre-commit run --all-files
```

Gates: `tofu fmt`, `tflint`, Trivy secrets, Trivy IaC misconfig.

### Terragrunt

[docs](https://docs.terragrunt.com/getting-started/quick-start/)

```bash
curl -sSfL --proto '=https' --tlsv1.2 https://terragrunt.com/install | bash
```

## Agent and git setup

`.claude` is a symlink to `.agents/`. On a fresh clone:

```bash
ln -s .agents .claude
```

MCP servers are configured in `.agents/mcp/servers.json`. To regenerate vendor-specific configs:

```bash
.agents/scripts/sync-mcp.sh
```
