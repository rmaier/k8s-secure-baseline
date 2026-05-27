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

Environment-specific state lives under `infra/environments/{dev,prod}/`. Each environment directory is a standalone root module that references shared modules from `infra/modules/`.

```bash
cd infra/environments/dev
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

Modules (`infra/modules/vpc`, `infra/modules/gke`, `infra/modules/dns`) are stubs — implement them before referencing from environment roots.

Provider versions are pinned in `infra/versions.tf`. Current: `hashicorp/google ~> 7.33`.

## Ansible

Playbooks are in `ansible/playbooks/`, inventory in `ansible/inventory/hosts.yml`.

```bash
# Provision all hosts
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml

# Harden (CIS / NIS2 baseline)
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/harden.yml
```

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
