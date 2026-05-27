# Demo iac repo

## Agent and git setup

```
.
├── .agents/
│   ├── agents/
│   │   ├── AGENTS.md
│   │   └── system-prompt.md
│   ├── mcp/
│   │   └── servers.json
│   ├── skills/
│   │   ├── ansible/SKILL.md      # Ansible playbook patterns
│   │   ├── commit/SKILL.md       # Conventional Commits
│   │   ├── devsecops/SKILL.md    # Security, compliance (NIS2/DORA)
│   │   ├── iac/SKILL.md          # OpenTofu, Terragrunt patterns
│   │   └── k8s/SKILL.md          # Kubernetes conventions
│   ├── scripts/
│   │   ├── link.sh
│   │   └── sync-mcp.sh
│   ├── settings.json
│   └── .gitignore
├── .claude -> .agents/
├── .mcp.json                     # Claude mcp config
├── opencode.json
└── README.md
```



```bash
ln -s .agents .claude
```

mcp servers vendor agnostic config in `.agents/mcp/servers.json`. 

Tell Claude to use  ` .agents/scripts/sync-mcp.sh` to create vendor specific mcp configs. 

claude mcp [config](https://code.claude.com/docs/en/settings#what-uses-scopes)

Test the MCP integration for opentofu: 

> whats the latest hashicorp/google version ? 
>
> ```bash
> Thinking: The user is asking about the latest version of the hashicorp/google provider. Let me look up the OpenTofu registry to find the latest version.
> ⚙ opentofu_get-provider-details [namespace=hashicorp, name=google]
> Thinking: The latest version of hashicorp/google is v7.33.0.
> v7.33.0
> ```
>
> check [here](https://search.opentofu.org/provider/hashicorp/google/latest). 

## Provision vps and dns

[infra](infra/README.md) docs



## Implementation checklist

### Prerequisites

- [x] Init Git repo
- [x] Install OpenTofu
- [x] Install gcloud CLI — authenticate + set default project
- [ ] Install kubectl locally — for later smoke-testing

### VM provisioning

- [x] Flat OpenTofu config in `infra/` — no Terragrunt, local state
- [x] Ubuntu 24.04 LTS, `e2-medium`, 30 GB `pd-balanced`
- [x] Firewall rules — ports 22, 80, 443, 6443 (k8s API)
- [x] DNS A record via `timofurrer/desec` provider (`infra/modules/dns/`) — IP always in sync, no static IP needed
- [x] VM reachable via domain name over SSH

### Kubernetes bootstrap

- [ ] Add `metadata_startup_script` to `google_compute_instance` — cloud-init to install k8s
- [ ] Install containerd — configure cgroup driver = systemd
- [ ] Install kubeadm, kubelet, kubectl — pin to a specific version
- [ ] Run `kubeadm init` — `--pod-network-cidr=10.244.0.0/16`
- [ ] Install CNI plugin — Flannel or Calico
- [ ] Untaint control-plane node — allow workloads on single-node cluster
- [ ] Copy kubeconfig to local machine
- [ ] Smoke-test — `kubectl get nodes` — node should be Ready

### Ingress and TLS

- [ ] Deploy cert-manager — Helm or `kubectl apply`
- [ ] Create `ClusterIssuer` — ACME Let's Encrypt, HTTP-01 challenge
- [ ] Deploy nginx-ingress controller

### Demo app

- [ ] `Deployment` + `Service` + `Ingress` manifests — TLS via cert-manager annotation
- [ ] Verify — `curl -I https://<subdomain>.<domain>`

### CI/CD

- [ ] GitHub Actions — `tofu plan` on PR, `tofu apply` on merge
- [ ] GCP auth via Workload Identity Federation — no JSON key in secrets
- [ ] Tag `v0.1.0`