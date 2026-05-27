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

- [x] Init Git repo — README.md, .gitignore (`*.tfstate*`, `.terraform/`, `.terragrunt-cache/`)
- [ ] Define folder layout — `infra/gcp/vm/`, `infra/gcp/dns/`, `infra/k8s/`, `modules/`
- [x] Install OpenTofu 
- [x] Install Terragrunt
- [x] Install gcloud CLI — authenticate + set default project
- [ ] Install kubectl + kubeadm locally — for later smoke-testing

### Remote state (skip)

- [ ] Create GCS bucket for remote state — manual bootstrap, one-time
- [ ] Write root `terragrunt.hcl` — `remote_state` block pointing to GCS
- [ ] Enable GCP APIs (`compute.googleapis.com`, `secretmanager.googleapis.com`)

### VM provisioning

- [ ] Write VM module `modules/gcp-vm/main.tf` — `google_compute_instance`, `e2-standard-2` or similar
- [ ] Configure OS — Ubuntu 22.04 LTS image, 20 GB boot disk
- [ ] Add firewall rules — ports 22 (SSH), 80, 443, 6443 (k8s API)
- [ ] Assign static external IP (`google_compute_address`) — needed for DNS
- [ ] Output external IP — consumed by DNS module via Terragrunt dependency
- [ ] Add SSH key to metadata — or use OS Login
- [ ] Wire via Terragrunt `infra/gcp/vm/terragrunt.hcl`
- [ ] Run `tofu apply` — verify VM accessible via SSH

### Kubernetes bootstrap

- [ ] Write cloud-init / startup script `modules/gcp-vm/files/k8s-bootstrap.sh`
- [ ] Install container runtime — containerd via apt, configure cgroup driver = systemd
- [ ] Install kubeadm, kubelet, kubectl — pin to a specific version e.g. 1.30
- [ ] Run `kubeadm init` — `--pod-network-cidr=10.244.0.0/16` for Flannel
- [ ] Install CNI plugin — Flannel or Calico via `kubectl apply`
- [ ] Untaint control-plane node — allow workloads on single-node cluster
- [ ] Copy kubeconfig to `/root/.kube/config` and to local machine
- [ ] Bake script into VM via `google_compute_instance` `metadata_startup_script` — or use `null_resource` + `remote-exec`
- [ ] Smoke-test — `kubectl get nodes` — node should be Ready

### DNS

- [ ] Get deSEC API token from desec.io
- [ ] Store token in GCP Secret Manager or `.envrc` — never commit to repo
- [ ] Add deSEC provider `modules/dns/main.tf` — `registry.opentofu.org/registry/desec` or community fork
- [ ] Create A record pointing to static VM IP — `desec_rrset` resource, TTL 300
- [ ] Wire via Terragrunt `infra/gcp/dns/terragrunt.hcl` — dependency on vm module output

### Ingress and TLS

- [ ] Deploy cert-manager to cluster — `kubectl apply` or Helm via tofu `helm_release`
- [ ] Create ClusterIssuer `infra/k8s/cert-manager/issuer.yaml` — ACME Let's Encrypt, HTTP-01 or DNS-01 challenge
- [ ] Choose ingress controller — nginx-ingress — deploy via Helm or static manifest

### Demo app

- [ ] Write Deployment `infra/k8s/demo-app/deployment.yaml` — e.g. `nginxdemos/hello` or `gcr.io/google-samples/hello-app:1.0`
- [ ] Write Service `infra/k8s/demo-app/service.yaml` — ClusterIP (ingress handles external traffic)
- [ ] Write Ingress `infra/k8s/demo-app/ingress.yaml` — TLS block + cert-manager annotation
- [ ] Manage manifests via OpenTofu `modules/k8s-app/main.tf` — kubernetes provider, auth from kubeconfig output
- [ ] Wire via Terragrunt `infra/k8s/demo-app/terragrunt.hcl` — dependency on vm + dns modules
- [ ] Apply and verify — `curl -I https://demo.yourdomain.de`

### CI/CD and docs

- [ ] Add GitHub Actions workflow `.github/workflows/tofu-plan.yml` — plan on PR, apply on merge to main
- [ ] Authenticate GHA to GCP via Workload Identity Federation — no JSON key in secrets
- [ ] Add `CODEOWNERS` — + branch protection on main
- [ ] Write `docs/architecture.md` — short diagram: VM → k8s → ingress → workload
- [ ] Tag `v0.1.0` — first working release