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

## Linting and pre commit

### tflint and tofu fmt

tflint [repo](https://github.com/terraform-linters/tflint)

```bash
curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip
unzip tflint_linux_amd64.zip
sudo install -c -v tflint /usr/local/bin/
```

create the config file `infra/.tflint.hcl`

```bash
tofu fmt -diff
tflint --recursive
```

### trivy

[website](https://trivy.dev/docs/latest/getting-started/installation/)

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.70.0
# check
trivy fs --scanners misconfig --exit-code 1 --severity HIGH,CRITICAL .
```

### pre commit hook

[website](https://pre-commit.com/)

The tool pre-commit: De facto standard for IaC; huge hook ecosystem; language: system for local tools

```bash
sudo apt install pre-commit
# Install pre-commit hooks into the repo
pre-commit install 
pre-commit run --all-files
```

## Setup the Cluster (Ansible)

See [ansible/README.md](ansible/README.md) for full details. Run from the `ansible/` directory:

```bash
cd ansible

# Check SSH connectivity
ansible k8s_control_plane -m ping

# Apply
ansible-playbook playbooks/k8s.yml
```
