# Ansible

Bootstraps Kubernetes (kubeadm) on the GCP VPS. Run all playbooks from the `ansible/` directory — `ansible.cfg` sets the roles path and inventory relative to that directory.

## Prerequisites

```bash
pip install ansible        # or apt-get install ansible
ansible-galaxy collection install ansible.posix
```

SSH access to the VPS must be working before running any playbook.

## Configuration

| File | Purpose |
|---|---|
| `inventory/hosts.yml` | Host definitions — update `ansible_host` and `ansible_user` |
| `group_vars/k8s_control_plane.yml` | Cluster variables — k8s version, pod CIDR, Flannel manifest URL |
| `ansible.cfg` | Sets `roles_path = ./roles` and default inventory |

## Playbooks

### `playbooks/k8s.yml` — Kubernetes bootstrap

Installs kubeadm, bootstraps a single-node control plane, deploys Flannel CNI, and fetches the kubeconfig locally.

```bash
# Check SSH connectivity
ansible k8s_control_plane -m ping

# Dry-run
ansible-playbook playbooks/k8s.yml --check

# Apply
ansible-playbook playbooks/k8s.yml
```

After a successful run, `~/.kube/config` is written locally and `kubectl get nodes` should show the node as `Ready`.

## Roles

### `k8s-common`

System prerequisites that must be in place before kubeadm runs:

1. Disable swap (kubeadm refuses to start with swap on)
2. Load kernel modules `overlay` and `br_netfilter`, persist across reboots
3. Set sysctl: `net.bridge.bridge-nf-call-iptables`, `net.ipv4.ip_forward`
4. Install containerd, generate default config, enable `SystemdCgroup = true` (required on Ubuntu 24.04 / cgroup v2)
5. Add Kubernetes apt repo for the pinned version, install and hold `kubeadm`, `kubelet`, `kubectl`

### `k8s-control-plane`

Single-node control plane setup:

1. Run `kubeadm init --pod-network-cidr=10.244.0.0/16` (idempotent — skipped if `/etc/kubernetes/admin.conf` exists)
2. Write kubeconfig for root on the remote host
3. Deploy Flannel CNI
4. Remove the control-plane taint so workloads can schedule on the single node
5. Fetch `admin.conf` to `~/.kube/config` locally

## Variables

Defined in `group_vars/k8s_control_plane.yml` and mirrored as role defaults:

| Variable | Default | Description |
|---|---|---|
| `k8s_version` | `1.32` | Kubernetes minor version — controls apt repo URL |
| `pod_network_cidr` | `10.244.0.0/16` | Pod network — must match Flannel's default |
| `flannel_manifest` | `…/kube-flannel.yml` | Flannel manifest URL |
| `kubeconfig_local_path` | `~/.kube/config` | Where to write the kubeconfig locally |

## Upgrading Kubernetes

Change `k8s_version` in `group_vars/k8s_control_plane.yml` and re-run. The apt repo URL is templated from that variable. Drain the node and follow the [kubeadm upgrade guide](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) before re-running the playbook.
