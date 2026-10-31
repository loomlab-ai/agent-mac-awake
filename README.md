# agent-mac-awake

agent-mac-awake keeps a Mac awake during long Cursor and Grok Bot runs. It is a thin wrapper around macOS caffeinate, with an optional LaunchAgent, for people who leave an agent running on a Mac. MIT License.

[简体中文](README.zh-CN.md)

## Purpose

Long Cursor and Grok Bot runs stall when the display sleeps or the Mac goes idle, often as a local machine that cannot connect. agent-mac-awake wraps `/usr/bin/caffeinate` with flags `-dimsu` and runs until you stop it, uninstall it, or the process exits. An optional LaunchAgent labeled `com.lofisu.agent-awake` loads at login and uses KeepAlive so the assertion comes back. Closing the lid still often forces sleep; leave the lid open for long runs.

## Quick start

macOS only (`/usr/bin/caffeinate` is part of the system). From a clone:

```bash
git clone https://github.com/loomlab-ai/agent-mac-awake.git
cd agent-mac-awake
./scripts/install.sh
"$HOME/Library/Application Support/agent-mac-awake/bin/agent-awake" status
```

## Features

- Wraps `caffeinate -dimsu`: prevent display sleep, idle sleep, disk sleep, and system sleep on AC power, and declare the user active. No timeout.
- Optional LaunchAgent `com.lofisu.agent-awake` with `RunAtLoad`, `KeepAlive`, and argument `start-foreground`, so the assertion returns at login.
- One-shot keep-awake without installing the LaunchAgent (`start`, `status`, `stop`).
- `enable-lid-guard` and `disable-lid-guard` print the `pmset` line, and run it only when `AGENT_AWAKE_I_UNDERSTAND=1`.
- No network calls and no telemetry. PID and status files stay under `~/Library/Application Support/agent-mac-awake/`.

## Install

`scripts/install.sh` runs `bin/agent-awake install`, which:

1. Copies the CLI to `~/Library/Application Support/agent-mac-awake/bin/agent-awake`
2. Writes `~/Library/LaunchAgents/com.lofisu.agent-awake.plist` (`RunAtLoad`, `KeepAlive`, arguments `start-foreground`)
3. Loads it with `launchctl bootstrap gui/$(id -u)` and falls back to `launchctl load -w`

The file `launchd/com.lofisu.agent-awake.plist` in this repo is a template. Install rewrites the program path for your home directory. The label stays `com.lofisu.agent-awake`.

Optional PATH for the current shell:

```bash
export PATH="$HOME/Library/Application Support/agent-mac-awake/bin:$PATH"
agent-awake status
```

LaunchAgent logs: `~/Library/Application Support/agent-mac-awake/launchd.out.log` and `launchd.err.log`.

One-shot keep-awake, without installing the LaunchAgent:

```bash
./bin/agent-awake start
./bin/agent-awake status
./bin/agent-awake stop
```

## Usage

| Command | Meaning |
|---------|---------|
| `start` | Background `caffeinate` (kickstarts the LaunchAgent when it is loaded) |
| `start-foreground` | Foreground entry point used by launchd |
| `stop` | Stop the process. KeepAlive can restart it until you unload or uninstall |
| `status` | Running state, PID, uptime, whether the LaunchAgent is loaded |
| `install` | Install the CLI and load the LaunchAgent |
| `uninstall [--purge]` | Unload and delete the plist. `--purge` deletes the support directory |
| `enable-lid-guard` / `disable-lid-guard` | Print the `pmset` line, or apply it when `AGENT_AWAKE_I_UNDERSTAND=1` |

Label: `com.lofisu.agent-awake`  
Plist: `~/Library/LaunchAgents/com.lofisu.agent-awake.plist`

`KeepAlive` is enabled. `agent-awake stop` can end the current process, and launchd starts it again. Unload the agent to pause it. Uninstall to remove it.

Unload, leaving the plist on disk:

```bash
launchctl bootout "gui/$(id -u)/com.lofisu.agent-awake"
```

Older macOS:

```bash
launchctl unload -w "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
```

Load again:

```bash
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
launchctl enable "gui/$(id -u)/com.lofisu.agent-awake"
launchctl kickstart -k "gui/$(id -u)/com.lofisu.agent-awake"
```

Older macOS:

```bash
launchctl load -w "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
```

`agent-awake install` boots the label out if it is already loaded, then bootstraps it. `agent-awake uninstall` boots it out, deletes the plist, and stops a tracked `caffeinate`. `--purge` also deletes the support directory.

```bash
./scripts/uninstall.sh
./scripts/uninstall.sh --purge
```

`caffeinate -dimsu` often does not keep a MacBook awake with the lid shut. Clamshell use still often sleeps. A closed lid usually stays awake only with AC power, an external display, and typically a keyboard and mouse. This repo does not configure clamshell mode. For long agent runs, leave the lid open.

```bash
AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
# sudo pmset -a disablesleep 1

AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
# sudo pmset -a disablesleep 0
```

## Configuration

Install does not change `pmset`. There is no config file.

| Item | Value |
|------|--------|
| LaunchAgent label | `com.lofisu.agent-awake` |
| caffeinate flags | `-dimsu` |
| Support directory | `~/Library/Application Support/agent-mac-awake/` |
| Env var | `AGENT_AWAKE_I_UNDERSTAND=1` to actually run `sudo pmset` |

| Flag | Effect |
|------|--------|
| `-d` | Prevent display sleep |
| `-i` | Prevent idle sleep |
| `-m` | Prevent disk sleep |
| `-s` | Prevent system sleep while on AC power |
| `-u` | Declare the user active |

`-s` applies while the Mac is on AC power. `sudo pmset -a disablesleep 1` can heat the machine and drain the battery. The lid-guard commands print that line and exit unless `AGENT_AWAKE_I_UNDERSTAND=1`.

## FAQ

### Does closing the MacBook lid keep it awake?

Closing the lid still often forces sleep. On a MacBook, lid-close sleep is separate from idle sleep, and `caffeinate -dimsu` frequently does not keep the machine awake with the lid shut. Leave the lid open for long agent runs. Clamshell mode usually needs AC power, an external display, and typically a keyboard and mouse. agent-mac-awake does not configure clamshell mode.

### Why does agent-awake start again after stop?

The LaunchAgent has `KeepAlive`. `agent-awake stop` can end the current process, and launchd starts it again. Unload the agent to pause it (`launchctl bootout`), or run `./scripts/uninstall.sh` to remove it.

### Does agent-mac-awake phone home or change sleep settings?

No network calls and no telemetry. PID and status files stay under `~/Library/Application Support/agent-mac-awake/`. Install does not run `pmset`. `enable-lid-guard` prints `sudo pmset -a disablesleep 1` and runs it only when `AGENT_AWAKE_I_UNDERSTAND=1`.

## License

[MIT License](LICENSE) (SPDX: MIT). Copyright (c) 2026 LofiSu.

## Contact

[loomlab-ai](https://github.com/loomlab-ai) · [LofiSu](https://github.com/LofiSu) · [lofisuchat@gmail.com](mailto:lofisuchat@gmail.com) · GitHub Sponsors · [X @su_lofi](https://x.com/su_lofi)
