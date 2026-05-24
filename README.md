<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:16213e&height=200&section=header&text=OpenCode%20Roblox&fontSize=60&fontColor=58a6ff&animation=fadeIn">
  <img alt="OpenCode Roblox" src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:16213e&height=200&section=header&text=OpenCode%20Roblox&fontSize=60&fontColor=58a6ff&animation=fadeIn" width="100%">
</picture>

<p align="center">
  <b>AI-powered Roblox Studio integration.</b><br>
  Connect intelligent models directly to your Roblox projects for script generation, live editing, and game automation.
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/status-active-success" alt="Status"></a>
  <a href="#"><img src="https://img.shields.io/badge/platform-linux--x64-blue" alt="Platform"></a>
  <a href="#"><img src="https://img.shields.io/badge/release-v1.0.0--beta-8A2BE2" alt="Release"></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-proprietary-red" alt="License"></a>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [CLI Reference](#cli-reference)
- [Plugin Usage](#plugin-usage)
- [Server Configuration](#server-configuration)
- [API Reference](#api-reference)
- [Use Cases](#use-cases)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Building from Source](#building-from-source)
- [License](#license)

---

## Overview

OpenCode Roblox is a bridge system that connects AI language models to Roblox Studio. It enables real-time script generation, editing, inspection, and automation through a lightweight local server that communicates between your AI tooling and Roblox Studio via a custom plugin.

The system is distributed as compiled binaries — no Python runtime or dependencies are required to run it. All Lua plugin files are compiled to bytecode for integrity.

---

## Features

### Script Operations
| Feature | Description |
|---------|-------------|
| Generate Scripts | Create new scripts from descriptions or templates |
| Read Scripts | View source of any LuaSourceContainer in the game |
| Edit Scripts | Modify scripts in real time with change history tracking |
| Create Scripts | Generate new scripts with auto-parenting |
| Run Lua Code | Execute arbitrary Lua in the game environment |

### Game Object Management
| Feature | Description |
|---------|-------------|
| Hierarchy Browsing | Navigate the full game object tree with configurable depth |
| Object Creation | Spawn any Roblox class instance with properties |
| Property Editing | Read and modify instance properties |
| Object Search | Find objects by name or class name across the entire tree |
| Object Deletion | Remove instances with proper cleanup |
| Reparenting | Move objects between parents |
| Renaming | Rename any game object |

### Studio Integration
| Feature | Description |
|---------|-------------|
| Live Polling | Plugin polls the bridge every second for new commands |
| Selection Control | Programmatically select objects in the Studio viewport |
| Change History | All modifications create undo points |
| Instance Enumeration | List every instance of a given class |

---

## Architecture

```
┌──────────────────┐     HTTP/JSON      ┌──────────────────┐
│   AI / CLI Tool  │  ◄──────────────►  │  Bridge Server   │
│  (opencode-cli)  │    port 9120       │  (opencode-server)│
└──────────────────┘                    └────────┬─────────┘
                                                 │ polling
                                                 │ (1s interval)
                                        ┌────────▼─────────┐
                                        │  Roblox Studio    │
                                        │  Plugin (.luac)   │
                                        └──────────────────┘
```

The system uses a **poll-based architecture**:

1. The **Bridge Server** runs locally and maintains a command queue
2. The **Roblox Studio Plugin** polls the server every second for pending commands
3. When a command is found, the plugin executes it in the Studio environment
4. Results are posted back to the server
5. The **CLI Tool** (or any HTTP client) sends commands and retrieves results

All communication is authenticated via a server-generated token.

---

## Quick Start

### Prerequisites

- Linux x86_64 system
- Roblox Studio (via Wine, Sober, or native installation)
- The compiled plugin file (`.luac`) placed in your Roblox Plugins folder

### Step 1: Start the Bridge Server

```bash
./opencode-server
```

You'll see output like:
```
  OpenCode AI - Roblox Bridge Server
  ─────────────────────────────────────
  Server:  http://127.0.0.1:9120
  Token:   a1b2c3d4
  ─────────────────────────────────────
  Plugin setup:
    Server URL: http://127.0.0.1:9120
    Auth Token: a1b2c3d4
  ─────────────────────────────────────
  Ctrl+C to stop
```

> **Note:** The token is randomly generated each time the server starts. You can set a fixed token with `--token YOUR_TOKEN`.

### Step 2: Install the Studio Plugin

Copy the plugin file to your Roblox Plugins directory:

| Platform | Path |
|----------|------|
| Windows | `%LOCALAPPDATA%\Roblox\Plugins\` |
| macOS | `~/Library/Application Support/Roblox/Plugins/` |
| Linux (Wine) | `~/.wine/drive_c/users/$USER/AppData/Local/Roblox/Plugins/` |

Use any of the provided plugin versions (they are functionally identical):
- `plugin.luac`
- `plugin2.luac`
- `plugin-v2.luac`

### Step 3: Connect in Studio

1. Launch Roblox Studio and open a project
2. Go to the **Plugins** tab → **OpenCode AI** → Click **Toggle** to show the panel
3. Enter the **Server URL** (`http://127.0.0.1:9120`)
4. Enter the **Auth Token** (displayed when you started the server)
5. Click **Connect**

The status indicator will turn green and show "Connected".

### Step 4: Use the CLI

```bash
# Test the connection
./opencode-cli --token a1b2c3d4 ping

# Browse the game hierarchy
./opencode-cli --token a1b2c3d4 get_hierarchy game --depth 3

# Read a script
./opencode-cli --token a1b2c3d4 read_script game.ServerScriptService.MyScript

# Run Lua code
./opencode-cli --token a1b2c3d4 run_script --code 'print("Hello from AI!")'

# Search for all Script instances
./opencode-cli --token a1b2c3d4 get_instances Script
```

---

## CLI Reference

### Global Options

| Option | Description |
|--------|-------------|
| `--server <URL>` | Bridge server URL (default: `http://127.0.0.1:9120`) |
| `--token <TOKEN>` | Authentication token **(required)** |
| `--no-wait` | Don't wait for command result, return immediately |

### Commands

#### `ping`
Test the connection to the bridge server.

```bash
./opencode-cli --token TOKEN ping
```
Returns server status, version, and queue info.

#### `get_hierarchy`
Traverse the game object tree.

```bash
# Browse from the root
./opencode-cli --token TOKEN get_hierarchy game --depth 2

# Browse a specific path
./opencode-cli --token TOKEN get_hierarchy game.Workspace --depth 3
```

| Argument | Description |
|----------|-------------|
| `path` | Starting path (default: `game`) |
| `--depth N` | Maximum recursion depth (default: 3) |

#### `read_script`
Read the source code of a script.

```bash
./opencode-cli --token TOKEN read_script game.ServerScriptService.MyScript
```

| Argument | Description |
|----------|-------------|
| `path` | Full path to the script **(required)** |

#### `write_script`
Write or create a script.

```bash
# Write content to an existing script
./opencode-cli --token TOKEN write_script game.ServerScriptService.MyScript --content "print('hello')"

# Create a new script
./opencode-cli --token TOKEN write_script game.ServerScriptService.NewScript --content "print('new')" --create

# Read from a file
./opencode-cli --token TOKEN write_script game.ServerScriptService.MyScript --file script.lua

# Pipe from stdin
echo "print('stdin')" | ./opencode-cli --token TOKEN write_script game.ServerScriptService.MyScript --from-stdin
```

| Argument | Description |
|----------|-------------|
| `path` | Full path to the script **(required)** |
| `--content <code>` | Inline source code |
| `--file <path>` | Read source from a file |
| `--from-stdin` | Read source from standard input |
| `--create` | Create the script if it doesn't exist |

#### `create_object`
Create a new Roblox instance.

```bash
# Create a part in workspace
./opencode-cli --token TOKEN create_object Part game.Workspace

# Create with properties
./opencode-cli --token TOKEN create_object Part game.Workspace --props '{"Name":"MyPart","Color":"Bright red"}'
```

| Argument | Description |
|----------|-------------|
| `ClassName` | Roblox class name **(required)** |
| `parent_path` | Parent path **(required)** |
| `--props <json>` | JSON object of properties to set |

#### `delete_object`
Delete an instance from the game.

```bash
./opencode-cli --token TOKEN delete_object game.Workspace.MyPart
```

| Argument | Description |
|----------|-------------|
| `path` | Full path to the object **(required)** |

#### `set_property`
Set a property on an object. Values are auto-detected as string, number, or boolean.

```bash
./opencode-cli --token TOKEN set_property game.Workspace.Part Transparency 0.5
./opencode-cli --token TOKEN set_property game.Workspace.Part Anchored true
./opencode-cli --token TOKEN set_property game.Workspace.Part Name "NewName"
```

| Argument | Description |
|----------|-------------|
| `path` | Full path to the object **(required)** |
| `property` | Property name **(required)** |
| `value` | Property value **(required)** |

#### `get_object`
Get detailed information about an object.

```bash
./opencode-cli --token TOKEN get_object game.Workspace.Part
```

Returns name, class, path, children count, and type-specific info (size, position, color for parts; source length for scripts).

| Argument | Description |
|----------|-------------|
| `path` | Full path to the object **(required)** |

#### `search`
Search for objects by name or class.

```bash
# Search by name
./opencode-cli --token TOKEN search --query "Part"

# Search by class
./opencode-cli --token TOKEN search --class BasePart

# Combine both
./opencode-cli --token TOKEN search --query "Door" --class Part
```

| Argument | Description |
|----------|-------------|
| `--query <text>` | Name filter (case-insensitive) |
| `--class <name>` | Class name filter |

#### `run_script`
Execute Lua code in the game environment.

```bash
# Inline code
./opencode-cli --token TOKEN run_script --code 'print(game.Name)'

# From a file
./opencode-cli --token TOKEN run_script --file script.lua

# From stdin
echo 'print("runtime")' | ./opencode-cli --token TOKEN run_script --from-stdin
```

| Argument | Description |
|----------|-------------|
| `--code <lua>` | Inline Lua code |
| `--file <path>` | Read Lua from a file |
| `--from-stdin` | Read Lua from standard input |

#### `move_object`
Reparent an object to a new parent.

```bash
./opencode-cli --token TOKEN move_object game.Workspace.Part game.ServerStorage
```

| Argument | Description |
|----------|-------------|
| `path` | Object to move **(required)** |
| `new_parent_path` | Destination parent **(required)** |

#### `rename_object`
Rename an object.

```bash
./opencode-cli --token TOKEN rename_object game.Workspace.Part "RenamedPart"
```

| Argument | Description |
|----------|-------------|
| `path` | Object to rename **(required)** |
| `new_name` | New name **(required)** |

#### `get_instances`
List all instances of a specific class in the game.

```bash
./opencode-cli --token TOKEN get_instances Script
./opencode-cli --token TOKEN get_instances LocalScript
./opencode-cli --token TOKEN get_instances Part
```

| Argument | Description |
|----------|-------------|
| `ClassName` | Roblox class name to search for **(required)** |

#### `select_object`
Select an object in the Studio viewport.

```bash
./opencode-cli --token TOKEN select_object game.Workspace.Part
```

| Argument | Description |
|----------|-------------|
| `path` | Object to select **(required)** |

---

## Plugin Usage

### Plugin Interface

The Roblox Studio plugin provides a GUI panel with:

- **Status Indicator** — Green/red dot showing connection state
- **Server URL Field** — Configure the bridge server address
- **Token Field** — Enter the authentication token
- **Connect/Disconnect Button** — Toggle connection
- **Log Output** — Real-time command log with timestamps
- **Clear Button** — Clear the log

### Connection Flow

1. Enter the server URL and token
2. Click **Connect** — the plugin validates the connection via `/status`
3. On success, polling begins (1-second interval)
4. The plugin automatically saves connection settings locally
5. Use **Toggle** button to show/hide the panel

### Change History

All destructive operations (write, create, delete, move, rename, set property) create undo points in Studio's change history, prefixed with `OpenCode:`. You can undo any AI action with Ctrl+Z.

---

## Server Configuration

### Command-Line Options

```bash
./opencode-server [--port PORT] [--host HOST] [--token TOKEN]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--port` | `9120` | Port to listen on |
| `--host` | `127.0.0.1` | Host address to bind to |
| `--token` | (random) | Fixed authentication token |

### Setting a Fixed Token

For automation or scripting, set a predictable token:

```bash
./opencode-server --token my-fixed-token
```

### Custom Port

If port 9120 is in use:

```bash
./opencode-server --port 9121
```

Then update your CLI commands and plugin to use the new port.

---

## API Reference

The bridge server exposes a REST API at `http://<host>:<port>/`.

All authenticated endpoints require `?token=<TOKEN>` as a query parameter.

### `GET /status`
Get server status and info.

**Response:**
```json
{
  "status": "running",
  "token": "a1b2c3d4",
  "version": "1.0.0",
  "pending_cmds": 0,
  "pending_results": 0
}
```

### `GET /poll?after=N`
Get the next pending command with ID greater than N.

**Response:**
```json
{
  "command": {
    "id": "1",
    "cmd": "ping",
    "params": {}
  }
}
```
Returns `{"command": null}` if no commands are pending.

### `POST /command`
Queue a new command for the plugin to execute.

**Request body:**
```json
{
  "cmd": "read_script",
  "params": {
    "path": "game.ServerScriptService.MyScript"
  }
}
```

**Response:**
```json
{
  "status": "queued",
  "id": "1"
}
```

### `POST /result`
Post a command result back to the server (plugin-side).

**Request body:**
```json
{
  "id": "1",
  "success": true,
  "data": { ... },
  "error": null
}
```

### `GET /result?id=N`
Poll for the result of a specific command.

**Response:**
```json
{
  "id": "1",
  "success": true,
  "data": { ... }
}
```
Returns `{"status": "pending"}` while the command is still executing.

---

## Use Cases

### AI-Assisted Script Development
Generate, review, and iterate on scripts directly within Studio. An AI model can read existing scripts for context, then write new ones or modify existing code.

### Automated Game Testing
Use the `run_script` and `get_hierarchy` commands to automate testing workflows — spawn test objects, verify properties, and execute validation scripts.

### Bulk Operations
Script repetitive tasks like renaming hundreds of objects, setting properties across multiple instances, or restructuring the object hierarchy.

### Live Debugging
Inspect object states, read script sources, and execute diagnostic Lua code without leaving your development environment.

### Studio Automation
Combine CLI commands with shell scripts to create complex Studio automation pipelines.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Server won't start | Check if port 9120 is in use: `lsof -i :9120`. Use `--port` to change. |
| Plugin can't connect | Verify the server is running and the token matches. Check the URL format. |
| Commands return timeout | Ensure the plugin is connected in Studio. Increase wait time with `--no-wait` and manual polling. |
| Script write fails | The parent path must exist for write operations. Use `--create` to auto-create. |
| Permission errors | The plugin runs with the same permissions as Studio. Some operations may require specific permissions. |
| Binary won't execute | Ensure the binary has execute permissions: `chmod +x opencode-server` |

---

## Security

- **Local-Only Binding** — The server binds to `127.0.0.1` by default, accepting connections only from the local machine
- **Token Authentication** — All API requests require a valid auth token
- **Anti-Debugging** — Binaries include runtime integrity checks and anti-debugging measures
- **No External Dependencies** — The bridge server is fully self-contained with no network calls to external services
- **Change History** — All Studio modifications create undo points for safe rollback

---

## Building from Source

Building requires the build toolchain (compiled binaries are available in releases).

### Prerequisites
- Python 3.13+
- GCC/G++
- Lua 5.5+
- Nuitka 4.x
- patchelf

### Build Steps

```bash
# Ensure the venv is set up
python3 -m venv venv
source venv/bin/activate
pip install nuitka patchelf

# Run the build script
./build/build.sh
```

Output appears in `dist/`.

---

## License

This project is **proprietary software**. All rights reserved.

See [LICENSE.md](LICENSE.md) for complete terms. The license prohibits reverse engineering, redistribution, and unauthorized modification.

---

<p align="center">
  <sub>Built with Nuitka compiled binaries for integrity and performance.<br>
  Version 1.0.0-beta</sub>
</p>
