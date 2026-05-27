#!/usr/bin/env bash
# Generates vendor-specific MCP configs from .agents/mcp/servers.json.
# Run after editing the central servers file.

set -euo pipefail

AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_DIR="$(cd "$AGENTS_DIR/.." && pwd)"
SERVERS="$AGENTS_DIR/mcp/servers.json"

# Claude Code reads .mcp.json at the project root (project-scoped MCP config)
jq '
  .servers | to_entries | map(
    if .value.transport == "sse" then
      {key: .key, value: {type: "sse", url: .value.url}}
    else
      {key: .key, value: ({type: "stdio", command: .value.command, args: (.value.args // [])} + (if .value.env then {env: .value.env} else {} end))}
    end
  ) | from_entries | {mcpServers: .}
' "$SERVERS" > "$ROOT_DIR/.mcp.json"

# OpenCode reads opencode.json at the project root
jq '
  {
    "$schema": "https://opencode.ai/config.json",
    mcp: (
      .servers | to_entries | map(
        if .value.transport == "sse" then
          {key: .key, value: {type: "remote", url: .value.url, enabled: true}}
        else
          {key: .key, value: ({type: "local", command: .value.command, args: (.value.args // [])} + (if .value.env then {env: .value.env} else {} end))}
        end
      ) | from_entries
    )
  }
' "$SERVERS" > "$ROOT_DIR/opencode.json"

echo "Synced MCP configs:"
echo "  -> $ROOT_DIR/.mcp.json        (Claude Code)"
echo "  -> $ROOT_DIR/opencode.json    (OpenCode)"
