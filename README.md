<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:16213e&height=200&section=header&text=OpenCode%20Roblox&fontSize=60&fontColor=58a6ff&animation=fadeIn">
  <img alt="OpenCode Roblox" src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:16213e&height=200&section=header&text=OpenCode%20Roblox&fontSize=60&fontColor=58a6ff&animation=fadeIn" width="100%">
</picture>

<p align="center">
  <b>AI-powered Roblox Studio integration.</b><br>
  Connect intelligent models directly to your Roblox projects.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-active-success" alt="Status">
  <img src="https://img.shields.io/badge/platform-linux--x64-blue" alt="Platform">
  <img src="https://img.shields.io/badge/license-proprietary-red" alt="License">
  <img src="https://img.shields.io/badge/build-nuitka--compiled-8A2BE2" alt="Build">
</p>

---

## Overview

OpenCode Roblox bridges AI language models with Roblox Studio, enabling intelligent script generation, editing, inspection, and automation — all within your Studio environment.

```
  AI Models  ⇄  Bridge Service  ⇄  Roblox Studio
```

## Features

- **Script Generation** — Create scripts from natural language descriptions
- **Live Editing** — Read and modify scripts inside running Studio sessions
- **Object Inspection** — Browse and inspect the game object hierarchy
- **Property Management** — Read and modify instance properties in real time
- **Code Execution** — Execute Lua code directly in the game environment
- **Search & Discovery** — Find objects and scripts across the entire game tree

## Quick Start

### 1. Start the Bridge Service

```bash
./opencode-server
```

The service will display a connection URL and authentication token.

### 2. Install the Studio Plugin

Copy the compiled plugin file to your Roblox Plugins folder:

- **Windows:** `%LOCALAPPDATA%\Roblox\Plugins\`
- **Mac:** `~/Library/Application Support/Roblox/Plugins/`

### 3. Connect

In Roblox Studio, open the plugin panel, enter the server URL and auth token, then click **Connect**.

### 4. Use the CLI

```bash
./opencode-cli --token <TOKEN> ping
./opencode-cli --token <TOKEN> get_hierarchy --depth 2
./opencode-cli --token <TOKEN> run_script --code 'print("hello world")'
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `ping` | Test connection to the bridge service |
| `get_hierarchy` | Browse the game object tree |
| `read_script` | Read a script's source |
| `write_script` | Write or create a script |
| `create_object` | Create a new instance |
| `delete_object` | Remove an instance |
| `set_property` | Modify an object property |
| `get_object` | Inspect object details |
| `search` | Find objects by name or class |
| `run_script` | Execute Lua code in-game |
| `move_object` | Reparent an object |
| `rename_object` | Rename an object |
| `get_instances` | List all instances of a class |
| `select_object` | Select an object in Studio |

## System Requirements

- **OS:** Linux x86_64
- **Roblox Studio** (via Wine, Sober, or native)
- **Bridge service:** Standalone binary — no Python or dependencies required

## Architecture

The system consists of three components:

1. **Bridge Service** — A lightweight local server that manages the communication layer
2. **Studio Plugin** — Connects Roblox Studio to the bridge service
3. **CLI Tool** — Command-line interface for interacting with the bridge

## License

This project is **proprietary software**. All rights reserved.

See [LICENSE.md](LICENSE.md) for full terms.

---

<p align="center">
  <sub>Built with Nuitka compiled binaries for integrity and performance.</sub>
</p>
