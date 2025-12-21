# Power BI MCP Server - Detailed Setup Guide

> Complete step-by-step instructions for setting up the Power BI Model Context Protocol server.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Configuration](#configuration)
4. [Connecting to Power BI](#connecting-to-power-bi)
5. [Testing the Connection](#testing-the-connection)
6. [Advanced Configuration](#advanced-configuration)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Software | Minimum Version | Download |
|----------|----------------|----------|
| Power BI Desktop | November 2024+ | [Download](https://powerbi.microsoft.com/desktop/) |
| Node.js | 18.0+ | [Download](https://nodejs.org/) |
| VS Code | Latest | [Download](https://code.visualstudio.com/) |
| Git | Latest | [Download](https://git-scm.com/) |

### Verify Prerequisites

```bash
# Check Node.js version
node --version
# Should show v18.x or higher

# Check npm version
npm --version
# Should show 9.x or higher

# Check VS Code CLI (optional)
code --version
```

### Windows Specific
- Windows 10/11 with 64-bit
- Administrator access for initial setup
- Windows Terminal (recommended)

### macOS Specific
- macOS 12+ (Monterey or later)
- Power BI Desktop via Parallels or Windows VM
- Homebrew for Node.js installation

---

## Installation Methods

### Method 1: NPX (Recommended - No Install)

Best for trying out or occasional use:

```bash
# Run directly without installing
npx @anthropic/powerbi-mcp
```

### Method 2: Global NPM Install

Best for frequent use:

```bash
# Install globally
npm install -g @anthropic/powerbi-mcp

# Run from anywhere
powerbi-mcp
```

### Method 3: Local Project Install

Best for version control and team consistency:

```bash
# Create project directory
mkdir powerbi-mcp-setup
cd powerbi-mcp-setup

# Initialize npm project
npm init -y

# Install as dependency
npm install @anthropic/powerbi-mcp

# Run via npx
npx powerbi-mcp
```

### Method 4: Build from Source

For developers who want to customize:

```bash
# Clone the repository
git clone https://github.com/anthropics/powerbi-mcp.git
cd powerbi-mcp

# Install dependencies
npm install

# Build the project
npm run build

# Link globally
npm link
```

---

## Configuration

### Locate Power BI Desktop Path

Find your Power BI Desktop executable:

**Default Locations:**

```
# Microsoft Store Version
C:\Program Files\WindowsApps\Microsoft.MicrosoftPowerBIDesktop_<version>\bin\PBIDesktop.exe

# MSI Installer Version
C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe

# 32-bit (rare)
C:\Program Files (x86)\Microsoft Power BI Desktop\bin\PBIDesktop.exe
```

**Find via PowerShell:**

```powershell
# Find Power BI Desktop
Get-ChildItem -Path "C:\Program Files*" -Filter "PBIDesktop.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
```

### Environment Variables

Set up environment variables for the MCP server:

**Windows (PowerShell):**
```powershell
# Set for current session
$env:POWERBI_DESKTOP_PATH = "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"

# Set permanently (user level)
[Environment]::SetEnvironmentVariable("POWERBI_DESKTOP_PATH", "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe", "User")
```

**Windows (Command Prompt):**
```cmd
set POWERBI_DESKTOP_PATH=C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe
```

**macOS/Linux (if using remote):**
```bash
export POWERBI_DESKTOP_PATH="/path/to/PBIDesktop.exe"
```

### Configuration File

Create a configuration file for persistent settings:

**`mcp-config.json`:**
```json
{
    "powerbi": {
        "desktopPath": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe",
        "port": 8765,
        "timeout": 30000,
        "debug": false
    },
    "server": {
        "host": "localhost",
        "port": 3000,
        "cors": true
    },
    "security": {
        "allowRemoteConnections": false,
        "requireAuth": false
    }
}
```

---

## Connecting to Power BI

### Step 1: Open Power BI Desktop

1. Launch Power BI Desktop
2. Open your `.pbix` file
3. Wait for the model to fully load
4. Keep Desktop open (MCP connects to running instance)

### Step 2: Enable External Tools (if needed)

Power BI Desktop may require external tools to be enabled:

1. File → Options and Settings → Options
2. Security → Enable "Allow external tools to access semantic model"
3. Restart Power BI Desktop

### Step 3: Start MCP Server

Open a terminal and run:

```bash
# Using npx
npx @anthropic/powerbi-mcp

# Or if globally installed
powerbi-mcp

# With custom config
powerbi-mcp --config ./mcp-config.json

# With debug output
powerbi-mcp --debug
```

**Expected Output:**
```
Power BI MCP Server v1.0.0
Connecting to Power BI Desktop...
✓ Connected to model: SalesAnalysis.pbix
✓ Server running on localhost:3000
Ready to accept connections
```

### Step 4: Connect AI Assistant

Configure your AI tool to use the MCP server. See [VSCode_Integration.md](./VSCode_Integration.md) for VS Code setup.

---

## Testing the Connection

### Quick Test via CLI

```bash
# Test connection (requires jq for JSON formatting)
curl -X POST http://localhost:3000/api/query \
  -H "Content-Type: application/json" \
  -d '{"query": "list tables"}' | jq
```

### Test via Built-in Health Check

```bash
curl http://localhost:3000/health
# Expected: {"status": "healthy", "model": "SalesAnalysis.pbix"}
```

### Test Commands

Try these in your AI assistant:

```
"List all tables in the model"
"Show me the measures in the Sales table"
"What relationships exist in this model?"
"Run DAX: EVALUATE ROW(\"Test\", 1)"
```

---

## Advanced Configuration

### Multiple Models

Support multiple open PBIX files:

```json
{
    "powerbi": {
        "multiModel": true,
        "defaultModel": "Sales.pbix"
    }
}
```

Switch models in conversation:
```
"Switch to the Finance.pbix model"
```

### Custom Port

Change server port if 3000 is in use:

```bash
powerbi-mcp --port 8080
```

Or in config:
```json
{
    "server": {
        "port": 8080
    }
}
```

### Logging

Enable detailed logging for troubleshooting:

```bash
# Debug mode
powerbi-mcp --debug --log-file ./mcp-debug.log

# Log levels: error, warn, info, debug
powerbi-mcp --log-level debug
```

### Performance Tuning

For large models, adjust timeouts:

```json
{
    "powerbi": {
        "queryTimeout": 60000,
        "connectionRetries": 3,
        "retryDelay": 2000
    }
}
```

### Proxy Configuration

If behind a corporate proxy:

```json
{
    "proxy": {
        "http": "http://proxy.company.com:8080",
        "https": "https://proxy.company.com:8080",
        "bypass": ["localhost", "127.0.0.1"]
    }
}
```

---

## Troubleshooting

### Connection Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot find Power BI Desktop` | Wrong path | Verify POWERBI_DESKTOP_PATH |
| `No model loaded` | PBIX not open | Open a PBIX file in Desktop |
| `Connection refused` | Desktop not ready | Wait for model to fully load |
| `Timeout` | Large model | Increase timeout in config |

### Common Fixes

**Reset Connection:**
```bash
# Kill existing server
pkill -f powerbi-mcp
# or on Windows: taskkill /F /IM node.exe

# Restart fresh
powerbi-mcp
```

**Clear Cache:**
```bash
# Remove node modules and reinstall
rm -rf node_modules
npm install
```

**Verify Power BI Port:**
```powershell
# Check if Power BI is listening
netstat -an | findstr "8765"
```

### Debug Mode

Run with maximum verbosity:

```bash
DEBUG=* powerbi-mcp --debug --log-level debug
```

### Known Limitations

1. **Single Session:** Only connects to one Power BI Desktop instance
2. **Local Only:** Cannot connect to Power BI Service (web) directly
3. **Read-Heavy:** Write operations may have restrictions
4. **Model Size:** Very large models (>1GB) may have performance issues

### Getting Help

- **GitHub Issues:** Report bugs and feature requests
- **Power BI Community:** Ask questions in forums
- **MCP Documentation:** [modelcontextprotocol.io](https://modelcontextprotocol.io)

---

## Uninstallation

### Remove Global Install

```bash
npm uninstall -g @anthropic/powerbi-mcp
```

### Remove Environment Variables

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("POWERBI_DESKTOP_PATH", $null, "User")
```

### Clean Up Config Files

```bash
rm ~/.powerbi-mcp-config.json  # if created
rm ./mcp-config.json           # if local
```

---

## Next Steps

- [VS Code Integration Guide](./VSCode_Integration.md)
- [MCP Use Cases](./UseCases/README.md)
- [MCP Prompt Templates](../../PromptLibrary/MCPPrompts.md)

---

*Last Updated: December 2024*
