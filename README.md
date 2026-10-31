# agent-mac-awake

Keep a Mac awake during long Grok Bot / Cursor agent runs. Thin wrapper around the built-in `caffeinate`, plus an optional LaunchAgent so the assertion returns at login.

基于系统自带 `caffeinate`，可选 LaunchAgent 在登录后拉起，减少息屏或空闲睡眠时「本机 Mac 无法连接」、任务停滞。

License: [MIT](LICENSE).

---

## English

### Install

macOS only (`/usr/bin/caffeinate` is part of the system). From a clone:

```bash
git clone https://github.com/LofiSu/agent-mac-awake.git
cd agent-mac-awake
./scripts/install.sh
```

`scripts/install.sh` runs `bin/agent-awake install`, which:

1. Copies the CLI to `~/Library/Application Support/agent-mac-awake/bin/agent-awake`
2. Writes `~/Library/LaunchAgents/com.lofisu.agent-awake.plist` (`RunAtLoad`, `KeepAlive`, arguments `start-foreground`)
3. Loads it with `launchctl bootstrap gui/$(id -u)` and falls back to `launchctl load -w`

Confirm:

```bash
"$HOME/Library/Application Support/agent-mac-awake/bin/agent-awake" status
```

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

### LaunchAgent unload and load

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

### What it asserts

`caffeinate -dimsu` (see `man caffeinate`). No timeout: it runs until stop, uninstall, or the process exits.

| Flag | Effect |
|------|--------|
| `-d` | Prevent display sleep |
| `-i` | Prevent idle sleep |
| `-m` | Prevent disk sleep |
| `-s` | Prevent system sleep while on AC power |
| `-u` | Declare the user active |

### Limitations

Closing the lid still often forces sleep. On a MacBook, lid-close sleep is separate from idle sleep, and `caffeinate -dimsu` frequently does not keep the machine awake with the lid shut.

Clamshell use (lid closed) still often sleeps as well. A closed lid usually stays awake only with AC power, an external display, and typically a keyboard and mouse. This repo does not configure clamshell mode.

`-s` applies while the Mac is on AC power.

`pmset` is untouched by install. `sudo pmset -a disablesleep 1` is an optional, advanced choice you turn on yourself. It can heat the machine and drain the battery. The commands below only run `pmset` when `AGENT_AWAKE_I_UNDERSTAND=1`. Otherwise they print the exact line and exit.

```bash
AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
# sudo pmset -a disablesleep 1

AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
# sudo pmset -a disablesleep 0
```

For long agent runs, leave the lid open.

### Commands

| Command | Meaning |
|---------|---------|
| `start` | Background `caffeinate` (kickstarts the LaunchAgent when it is loaded) |
| `start-foreground` | Foreground entry point used by launchd |
| `stop` | Stop the process. KeepAlive can restart it until you unload or uninstall |
| `status` | Running state, PID, uptime, whether the LaunchAgent is loaded |
| `install` | Install the CLI and load the LaunchAgent |
| `uninstall [--purge]` | Unload and delete the plist. `--purge` deletes the support directory |
| `enable-lid-guard` / `disable-lid-guard` | Print the `pmset` line, or apply it when `AGENT_AWAKE_I_UNDERSTAND=1` |

### Privacy

No network calls and no telemetry. PID and status files stay under `~/Library/Application Support/agent-mac-awake/`.

### License

[MIT License](LICENSE). Copyright (c) 2026 LofiSu.

### Topics

When this repository is listed publicly later, suggested GitHub topics are `macos`, `caffeinate`, `cursor`, `ai-agent`, `keep-awake`, `launchd`, and `macbook`.

---

## 中文

### 安装

仅适用于 macOS（系统自带 `/usr/bin/caffeinate`）。在克隆下来的仓库里：

```bash
git clone https://github.com/LofiSu/agent-mac-awake.git
cd agent-mac-awake
./scripts/install.sh
```

`scripts/install.sh` 会调用 `bin/agent-awake install`：

1. 把 CLI 复制到 `~/Library/Application Support/agent-mac-awake/bin/agent-awake`
2. 写入 `~/Library/LaunchAgents/com.lofisu.agent-awake.plist`（`RunAtLoad`、`KeepAlive`，参数为 `start-foreground`）
3. 用 `launchctl bootstrap gui/$(id -u)` 加载；失败则改用 `launchctl load -w`

确认状态：

```bash
"$HOME/Library/Application Support/agent-mac-awake/bin/agent-awake" status
```

当前 shell 可选 PATH：

```bash
export PATH="$HOME/Library/Application Support/agent-mac-awake/bin:$PATH"
```

LaunchAgent 日志：`~/Library/Application Support/agent-mac-awake/launchd.out.log` 与 `launchd.err.log`。

不安装 LaunchAgent、只临时保活：

```bash
./bin/agent-awake start
./bin/agent-awake status
./bin/agent-awake stop
```

### 卸载与重新加载 LaunchAgent

标签：`com.lofisu.agent-awake`  
plist：`~/Library/LaunchAgents/com.lofisu.agent-awake.plist`

已打开 `KeepAlive`。`agent-awake stop` 结束后，launchd 会再把它拉起来。要暂停请 unload；要卸掉请 uninstall。

卸掉加载、保留 plist：

```bash
launchctl bootout "gui/$(id -u)/com.lofisu.agent-awake"
```

较旧系统：

```bash
launchctl unload -w "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
```

重新加载：

```bash
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
launchctl enable "gui/$(id -u)/com.lofisu.agent-awake"
launchctl kickstart -k "gui/$(id -u)/com.lofisu.agent-awake"
```

较旧系统：

```bash
launchctl load -w "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
```

`install` 会先 bootout 再 bootstrap。`uninstall` 会 bootout、删除 plist，并停掉已记录的 `caffeinate`。`--purge` 再删除支持目录。

```bash
./scripts/uninstall.sh
./scripts/uninstall.sh --purge
```

### 断言了什么

`caffeinate -dimsu`（见 `man caffeinate`）。没有超时，直到 stop、卸载或进程退出。

| 参数 | 作用 |
|------|------|
| `-d` | 阻止显示器睡眠 |
| `-i` | 阻止空闲睡眠 |
| `-m` | 阻止磁盘睡眠 |
| `-s` | 在接通电源时阻止系统睡眠 |
| `-u` | 声明用户处于活动状态 |

### 限制

合上盖子往往仍会强制睡眠。MacBook 的合盖睡眠和空闲睡眠不是一回事，`caffeinate -dimsu` 经常无法在合盖后保持唤醒。

蛤壳（合盖当台式机）同样常常会睡。合盖后通常要同时接上电源、外接显示器，并且一般还要键鼠，机器才会保持醒着。本仓库不会配置蛤壳模式。

`-s` 在接通电源时生效。

安装过程不会修改 `pmset`。`sudo pmset -a disablesleep 1` 是可选的进阶设置，由你自己决定是否打开，可能导致发热和耗电。下面的命令只有在 `AGENT_AWAKE_I_UNDERSTAND=1` 时才会执行 `pmset`，否则只打印将要运行的命令然后退出。

```bash
AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
```

长时间跑 Agent 时，把盖子打开。

### 命令

| 命令 | 含义 |
|------|------|
| `start` | 后台 `caffeinate`（若 LaunchAgent 已加载则 kickstart） |
| `start-foreground` | 前台运行，供 launchd 调用 |
| `stop` | 停止进程。在 unload 或 uninstall 之前，KeepAlive 可能再次启动 |
| `status` | 是否在跑、PID、运行时间、LaunchAgent 是否已加载 |
| `install` | 安装 CLI 并加载 LaunchAgent |
| `uninstall [--purge]` | 卸载并删除 plist。`--purge` 删除支持目录 |
| `enable-lid-guard` / `disable-lid-guard` | 打印 `pmset` 命令；设置 `AGENT_AWAKE_I_UNDERSTAND=1` 后才会执行 |

### 隐私

没有网络请求，也没有遥测。PID 和状态文件只在 `~/Library/Application Support/agent-mac-awake/`。

### 许可

[MIT License](LICENSE)。Copyright (c) 2026 LofiSu。

### 主题

以后若把仓库公开列出，建议的 GitHub topics：`macos`、`caffeinate`、`cursor`、`ai-agent`、`keep-awake`、`launchd`、`macbook`。
