# Obsidian MCP Server Configuration

## Overview

This document describes how to configure the [cyanheads/obsidian-mcp-server](https://github.com/cyanheads/obsidian-mcp-server) for use with Opencode. This MCP server enables AI agents to interact with the Obsidian vault via the Local REST API plugin.

## Prerequisites

1. **Obsidian Desktop App** - Must be running
2. **Local REST API Plugin** - Installed and enabled in Obsidian
3. **API Key** - Generated from plugin settings

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `OBSIDIAN_API_KEY` | API key from Local REST API plugin | - | Yes |
| `OBSIDIAN_BASE_URL` | Base URL for REST API | `http://127.0.0.1:27123` | No |
| `OBSIDIAN_VERIFY_SSL` | Verify SSL certificates | `false` | No |
| `OBSIDIAN_ENABLE_CACHE` | Enable vault caching | `true` | No |

## opencode.json Configuration

Add this to your `programs.opencode.settings.mcp` in your Nix home-manager config:

```json
"Obsidian-Vault": {
  "command": ["npx", "obsidian-mcp-server"],
  "environment": {
    "OBSIDIAN_API_KEY": "<your-api-key>",
    "OBSIDIAN_BASE_URL": "http://127.0.0.1:27123",
    "OBSIDIAN_VERIFY_SSL": "false",
    "OBSIDIAN_ENABLE_CACHE": "true"
  },
  "enabled": true,
  "type": "local"
}
```

**Note**: Replace `<your-api-key>` with the key from Obsidian Settings → Local REST API.

## Nix Home-Manager Integration

In your NixOS/home-manager configuration:

```nix
programs.opencode.settings.mcp = {
  # ... other MCP servers ...

  "Obsidian-Vault" = {
    command = ["npx" "obsidian-mcp-server"];
    environment = {
      OBSIDIAN_API_KEY = "<your-api-key>";
      OBSIDIAN_BASE_URL = "http://127.0.0.1:27123";
      OBSIDIAN_VERIFY_SSL = "false";
      OBSIDIAN_ENABLE_CACHE = "true";
    };
    enabled = true;
    type = "local";
  };
};
```

After updating, run:
```bash
home-manager switch
```

## Getting the API Key

1. Open Obsidian Settings
2. Navigate to Community Plugins → Local REST API
3. Copy the API key shown in settings
4. Paste into your configuration

## Available MCP Tools

Once configured, these tools are available:

| Tool | Description |
|------|-------------|
| `obsidian_read_note` | Read a note's content |
| `obsidian_update_note` | Create or update a note |
| `obsidian_global_search` | Search the entire vault |
| `obsidian_manage_frontmatter` | Get/set frontmatter fields |
| `obsidian_manage_tags` | Add/remove tags |
| `obsidian_list_notes` | List notes in a folder |
| `obsidian_delete_note` | Delete a note |
| `obsidian_search_replace` | Search and replace in a note |

## Troubleshooting

### Server not responding
- Ensure Obsidian desktop app is running
- Check Local REST API plugin is enabled
- Verify API key matches

### Connection refused
- Check the base URL (default: `http://127.0.0.1:27123`)
- Some setups use port 27124 - check plugin settings

### npx not found
- Ensure Node.js is installed
- Run `npm install -g npx` if needed

## References

- [cyanheads/obsidian-mcp-server GitHub](https://github.com/cyanheads/obsidian-mcp-server)
- [Obsidian Local REST API Plugin](https://github.com/czottmann/obsidian-local-rest-api)
