# Ansible

Bootstraps a single-node Kubernetes cluster (kubeadm + Cilium) and hands off to ArgoCD for platform management. Run all playbooks from the `ansible/` directory — `ansible.cfg` sets roles path and inventory relative to that directory.

## Prerequisites

```bash
pip install ansible
ansible-galaxy collection install ansible.posix
```

SSH access to the VPS must be working before running any playbook.

Before running the ArgoCD bootstrap, set `argocd_repo_url` in `inventory/group_vars/k8s_control_plane.yml` to your GitHub repo URL.

## Configuration

| File | Purpose |
|---|---|
| `inventory/hosts.yml` | Host definitions — update `ansible_host` and `ansible_user` |
| `inventory/group_vars/k8s_control_plane.yml` | Cluster variables — single source of truth |
| `ansible.cfg` | Sets `roles_path = ./roles` and default inventory |

## Run

```bash
cd ansible

# Check SSH connectivity
ansible k8s_control_plane -m ping

# Dry-run
ansible-playbook playbooks/k8s.yml --check

# Apply
ansible-playbook playbooks/k8s.yml
```

After a successful run:
- `~/.kube/config` is written locally, pointing at `https://node01.rudolphmaier.de:6443`
- `kubectl get nodes` shows the node as `Ready`
- ArgoCD is running in the `argocd` namespace and syncing `k8s/platform/`

## Playbook: `playbooks/k8s.yml`

Four plays run in sequence:

| Play | Role | What it does |
|---|---|---|
| 1 | `k8s-common` | System prerequisites: swap off, kernel modules, sysctl, containerd, kubeadm/kubelet/kubectl |
| 2 | `k8s-control-plane` | `kubeadm init`, kubeconfig for root + ansible user, untaint node, fetch kubeconfig locally |
| 3 | `cilium` | Install Helm, deploy Cilium CNI via Helm chart |
| 4 | `argocd-bootstrap` | Deploy ArgoCD via Helm, apply app-of-apps root manifest |

## Roles

### `k8s-common`

1. Disable swap
2. Load `overlay` and `br_netfilter` kernel modules, persist across reboots
3. Set sysctl: `net.bridge.bridge-nf-call-iptables`, `net.ipv4.ip_forward`
4. Install containerd, enable `SystemdCgroup = true` (cgroup v2 / Ubuntu 24.04)
5. Add Kubernetes apt repo for the pinned version, install and hold `kubeadm`, `kubelet`, `kubectl`

### `k8s-control-plane`

1. `kubeadm init --apiserver-cert-extra-sans=<subdomain>.<domain>` (idempotent — skipped if `/etc/kubernetes/admin.conf` exists)
2. Write kubeconfig for root and the ansible user on the remote host
3. Untaint the control-plane node so workloads can schedule
4. Fetch `admin.conf` to `~/.kube/config` locally and rewrite server to FQDN

### `cilium`

1. Install Helm via official install script
2. Add the Cilium Helm repo
3. `helm upgrade --install cilium` at the pinned version, wait for readiness

### `argocd-bootstrap`

1. Add the ArgoCD Helm repo
2. `helm upgrade --install argocd` at the pinned version, wait for readiness
3. Template and apply the app-of-apps root manifest (`k8s/platform/`)

## Variables

All defined in `inventory/group_vars/k8s_control_plane.yml`:

| Variable | Value | Description |
|---|---|---|
| `k8s_version` | `1.36` | Kubernetes minor version — controls apt repo URL |
| `cilium_chart_version` | `1.19.4` | Cilium Helm chart version |
| `argocd_chart_version` | `9.5.16` | ArgoCD Helm chart version (app v3.4.3) |
| `kubeconfig_local_path` | `~/.kube/config` | Where to write the kubeconfig locally |
| `domain` | `rudolphmaier.de` | Domain for DNS and cert SANs |
| `subdomain` | `node01` | Subdomain label |
| `argocd_repo_url` | *(set before running)* | GitHub repo URL ArgoCD pulls from |

## Upgrading Kubernetes

Change `k8s_version` in `group_vars/k8s_control_plane.yml` and re-run. Drain the node first and follow the [kubeadm upgrade guide](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/).
