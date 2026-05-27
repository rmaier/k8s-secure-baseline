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

## Setup the cluster

## Deploy a demo workload

## Harden