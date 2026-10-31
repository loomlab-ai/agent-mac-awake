# agent-mac-awake

agent-mac-awake 在长时间 Cursor 与 Grok Bot 任务期间保持 Mac 不休眠，适合在 Mac 上持续跑 Agent 的人。它是 macOS `caffeinate` 的薄封装，可选 LaunchAgent。MIT License。

[English](README.md)

## 用途

长时间 Cursor 与 Grok Bot 任务会在息屏或 Mac 空闲睡眠时停滞，常表现为「本机 Mac 无法连接」。agent-mac-awake 用 `-dimsu` 封装 `/usr/bin/caffeinate`，一直运行到你 stop、卸载或进程退出。可选 LaunchAgent 标签为 `com.lofisu.agent-awake`，登录时加载，KeepAlive 会重新建立断言。合盖往往仍会强制睡眠；长时间任务请开盖。

## 快速开始

仅限 macOS（系统自带 `/usr/bin/caffeinate`）。克隆后：

```bash
git clone https://github.com/loomlab-ai/agent-mac-awake.git
cd agent-mac-awake
./scripts/install.sh
"$HOME/Library/Application Support/agent-mac-awake/bin/agent-awake" status
```

## 功能

- 封装 `caffeinate -dimsu`：阻止显示器睡眠、空闲睡眠、磁盘睡眠，接通电源时阻止系统睡眠，并声明用户处于活动状态。无超时。
- 可选 LaunchAgent `com.lofisu.agent-awake`，带 `RunAtLoad`、`KeepAlive` 和参数 `start-foreground`，登录后重新建立断言。
- 不安装 LaunchAgent 也能一次性保活（`start`、`status`、`stop`）。
- `enable-lid-guard` 与 `disable-lid-guard` 打印 `pmset` 命令，仅在 `AGENT_AWAKE_I_UNDERSTAND=1` 时执行。
- 无网络请求，无遥测。PID 与状态文件位于 `~/Library/Application Support/agent-mac-awake/`。

## 安装

`scripts/install.sh` 调用 `bin/agent-awake install`，它会：

1. 把 CLI 复制到 `~/Library/Application Support/agent-mac-awake/bin/agent-awake`
2. 写入 `~/Library/LaunchAgents/com.lofisu.agent-awake.plist`（`RunAtLoad`、`KeepAlive`，参数为 `start-foreground`）
3. 用 `launchctl bootstrap gui/$(id -u)` 加载；失败则改用 `launchctl load -w`

仓库里的 `launchd/com.lofisu.agent-awake.plist` 是模板。安装时按你的主目录改写程序路径，标签仍为 `com.lofisu.agent-awake`。

当前 shell 的可选 PATH：

```bash
export PATH="$HOME/Library/Application Support/agent-mac-awake/bin:$PATH"
agent-awake status
```

LaunchAgent 日志：`~/Library/Application Support/agent-mac-awake/launchd.out.log` 与 `launchd.err.log`。

不安装 LaunchAgent，只临时保活：

```bash
./bin/agent-awake start
./bin/agent-awake status
./bin/agent-awake stop
```

## 用法

| 命令 | 含义 |
|------|------|
| `start` | 后台 `caffeinate`（LaunchAgent 已加载时 kickstart） |
| `start-foreground` | launchd 使用的前台入口 |
| `stop` | 停止进程。unload 或 uninstall 之前，KeepAlive 可能再次启动 |
| `status` | 运行状态、PID、运行时间、LaunchAgent 是否已加载 |
| `install` | 安装 CLI 并加载 LaunchAgent |
| `uninstall [--purge]` | 卸载并删除 plist。`--purge` 删除支持目录 |
| `enable-lid-guard` / `disable-lid-guard` | 打印 `pmset` 命令；`AGENT_AWAKE_I_UNDERSTAND=1` 时才执行 |

标签：`com.lofisu.agent-awake`  
plist：`~/Library/LaunchAgents/com.lofisu.agent-awake.plist`

`KeepAlive` 已开启。`agent-awake stop` 可以结束当前进程，launchd 会再次启动它。暂停请 unload，移除请 uninstall。

取消加载，plist 留在磁盘上：

```bash
launchctl bootout "gui/$(id -u)/com.lofisu.agent-awake"
```

较旧 macOS：

```bash
launchctl unload -w "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
```

重新加载：

```bash
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
launchctl enable "gui/$(id -u)/com.lofisu.agent-awake"
launchctl kickstart -k "gui/$(id -u)/com.lofisu.agent-awake"
```

较旧 macOS：

```bash
launchctl load -w "$HOME/Library/LaunchAgents/com.lofisu.agent-awake.plist"
```

`agent-awake install` 若标签已加载，会先 bootout 再 bootstrap。`agent-awake uninstall` 会 bootout、删除 plist，并停掉已记录的 `caffeinate`。`--purge` 同时删除支持目录。

```bash
./scripts/uninstall.sh
./scripts/uninstall.sh --purge
```

MacBook 上，合盖睡眠与空闲睡眠不是一回事，`caffeinate -dimsu` 经常无法在合盖后保持唤醒。蛤壳（合盖当台式机）同样常常进入睡眠。合盖后通常要同时接上电源、外接显示器，一般还要键鼠，机器才会保持唤醒。本仓库不配置蛤壳模式。长时间跑 Agent 请开盖。

```bash
AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
# sudo pmset -a disablesleep 1

AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
# sudo pmset -a disablesleep 0
```

## 配置

安装不会修改 `pmset`。没有配置文件。

| 项 | 值 |
|------|--------|
| LaunchAgent 标签 | `com.lofisu.agent-awake` |
| caffeinate 参数 | `-dimsu` |
| 支持目录 | `~/Library/Application Support/agent-mac-awake/` |
| 环境变量 | `AGENT_AWAKE_I_UNDERSTAND=1` 才会真正执行 `sudo pmset` |

| 参数 | 作用 |
|------|------|
| `-d` | 阻止显示器睡眠 |
| `-i` | 阻止空闲睡眠 |
| `-m` | 阻止磁盘睡眠 |
| `-s` | 在接通电源时阻止系统睡眠 |
| `-u` | 声明用户处于活动状态 |

`-s` 在接通电源时生效。`sudo pmset -a disablesleep 1` 可能导致发热和耗电。lid-guard 命令会打印该行并退出，除非设置了 `AGENT_AWAKE_I_UNDERSTAND=1`。

## 许可证

[MIT License](LICENSE)（SPDX：MIT）。Copyright (c) 2026 LofiSu。

## 联系

[loomlab-ai](https://github.com/loomlab-ai) · [LofiSu](https://github.com/LofiSu) · [lofisuchat@gmail.com](mailto:lofisuchat@gmail.com) · GitHub Sponsors · [X @su_lofi](https://x.com/su_lofi)
