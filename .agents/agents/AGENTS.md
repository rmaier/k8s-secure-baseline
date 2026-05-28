# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Agent setup

`.claude` is a symlink to `.agents/`. All agent config (skills, MCP servers, settings) lives in `.agents/` and is shared between Claude Code and other runtimes (OpenCode, etc.). On a fresh clone:

```bash
ln -s .agents .claude
```

## MCP servers

The source of truth for MCP servers is `.agents/mcp/servers.json`. **Never edit `.mcp.json` or `opencode.json` directly** — they are generated outputs. After changing `servers.json`, regenerate:

```bash
.agents/scripts/sync-mcp.sh
```

This writes `.mcp.json` (Claude Code) and `opencode.json` (OpenCode) from the single vendor-agnostic config.

## Infrastructure (OpenTofu)

This repo uses **OpenTofu**, not Terraform. Use `tofu` commands, not `terraform`.

State is local, root module is flat at `infra/`. No Terragrunt, no remote state.

```bash
cd infra
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

### Modules

| Module | Purpose |
|---|---|
| `infra/modules/vps` | GCP Compute Engine instance + ingress firewall rules (for_each over `allowed_ports` map) |
| `infra/modules/dns` | deSEC A record via `timofurrer/desec` provider; exposes `fqdn` output |

`infra/main.tf` is two module calls: `module "vps"` and `module "dns"`. The DNS module depends on `module.vps.external_ip` — no explicit `depends_on` needed.

Provider versions are pinned in `infra/versions.tf`. Current: `hashicorp/google ~> 7.33`, `timofurrer/desec ~> 0.6`.

## Ansible

Run all playbooks from the `ansible/` directory — `ansible.cfg` sets roles path and inventory relative to that directory.

```bash
cd ansible

# Kubernetes bootstrap (kubeadm + Flannel CNI)
ansible-playbook playbooks/k8s.yml
```

Cluster variables (k8s version, pod CIDR, Flannel manifest URL) live in `ansible/inventory/group_vars/k8s_control_plane.yml` — single source of truth, not duplicated in role defaults.

## Skills

Skills are in `.agents/skills/` and load automatically when their description matches the request:

| Skill | When it loads |
|---|---|
| `iac` | OpenTofu / Terragrunt patterns |
| `ansible` | Ansible playbook work |
| `k8s` | Kubernetes manifests |
| `devsecops` | Trivy + OWASP scanning, NIS2/DORA gates |
| `commit` | Creating git commits (Conventional Commits format) |

## Commits

Use the `/commit` skill. Commits follow Conventional Commits with a why-focused body and a `Co-Authored-By: Claude` trailer.
