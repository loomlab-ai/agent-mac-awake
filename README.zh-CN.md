# agent-mac-awake

agent-mac-awake 在长时间的 Cursor 与 Grok Bot 任务期间保持 Mac 不休眠。它是面向需要在 Mac 上长时间跑 Agent 的人的系统 caffeinate 薄封装，并可选用 LaunchAgent。MIT License。

[English](README.md)

## 用途

长时间的 Cursor 与 Grok Bot 任务会在息屏或 Mac 进入空闲睡眠时停滞，常常表现为本机 Mac 无法连接。agent-mac-awake 封装 `/usr/bin/caffeinate`，使用参数 `-dimsu`，直到你 stop、卸载或进程退出。可选的 LaunchAgent 标签为 `com.lofisu.agent-awake`，登录时加载，并用 KeepAlive 把断言拉回来。合上盖子往往仍会强制睡眠；长时间跑任务时请开盖。

## 快速开始

仅适用于 macOS（系统自带 `/usr/bin/caffeinate`）。在克隆下来的仓库里：

```bash
git clone https://github.com/loomlab-ai/agent-mac-awake.git
cd agent-mac-awake
./scripts/install.sh
"$HOME/Library/Application Support/agent-mac-awake/bin/agent-awake" status
```

## 功能

- 封装 `caffeinate -dimsu`：阻止显示器睡眠、空闲睡眠、磁盘睡眠，在接通电源时阻止系统睡眠，并声明用户处于活动状态。没有超时。
- 可选 LaunchAgent `com.lofisu.agent-awake`，带 `RunAtLoad`、`KeepAlive`，参数为 `start-foreground`，登录后恢复断言。
- 不安装 LaunchAgent 也可以一次性保活（`start`、`status`、`stop`）。
- `enable-lid-guard` 与 `disable-lid-guard` 会打印 `pmset` 命令，只有在 `AGENT_AWAKE_I_UNDERSTAND=1` 时才会执行。
- 没有网络请求，也没有遥测。PID 和状态文件只在 `~/Library/Application Support/agent-mac-awake/`。

## 安装

`scripts/install.sh` 会调用 `bin/agent-awake install`：

1. 把 CLI 复制到 `~/Library/Application Support/agent-mac-awake/bin/agent-awake`
2. 写入 `~/Library/LaunchAgents/com.lofisu.agent-awake.plist`（`RunAtLoad`、`KeepAlive`，参数为 `start-foreground`）
3. 用 `launchctl bootstrap gui/$(id -u)` 加载；失败则改用 `launchctl load -w`

仓库里的 `launchd/com.lofisu.agent-awake.plist` 是模板。安装时会按你的主目录重写程序路径。标签保持 `com.lofisu.agent-awake`。

当前 shell 可选 PATH：

```bash
export PATH="$HOME/Library/Application Support/agent-mac-awake/bin:$PATH"
agent-awake status
```

LaunchAgent 日志：`~/Library/Application Support/agent-mac-awake/launchd.out.log` 与 `launchd.err.log`。

不安装 LaunchAgent、只临时保活：

```bash
./bin/agent-awake start
./bin/agent-awake status
./bin/agent-awake stop
```

## 用法

| 命令 | 含义 |
|------|------|
| `start` | 后台 `caffeinate`（若 LaunchAgent 已加载则 kickstart） |
| `start-foreground` | 前台运行，供 launchd 调用 |
| `stop` | 停止进程。在 unload 或 uninstall 之前，KeepAlive 可能再次启动 |
| `status` | 是否在跑、PID、运行时间、LaunchAgent 是否已加载 |
| `install` | 安装 CLI 并加载 LaunchAgent |
| `uninstall [--purge]` | 卸载并删除 plist。`--purge` 删除支持目录 |
| `enable-lid-guard` / `disable-lid-guard` | 打印 `pmset` 命令；设置 `AGENT_AWAKE_I_UNDERSTAND=1` 后才会执行 |

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

`caffeinate -dimsu` 经常无法在合盖后保持 MacBook 唤醒。蛤壳（合盖当台式机）同样常常会睡。合盖后通常要同时接上电源、外接显示器，并且一般还要键鼠，机器才会保持醒着。本仓库不会配置蛤壳模式。长时间跑 Agent 时，把盖子打开。

```bash
AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
# sudo pmset -a disablesleep 1

AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
# sudo pmset -a disablesleep 0
```

## 配置

安装过程不会修改 `pmset`。没有配置文件。

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

`-s` 在接通电源时生效。`sudo pmset -a disablesleep 1` 可能导致发热和耗电。合盖相关命令会打印该行并退出，除非设置了 `AGENT_AWAKE_I_UNDERSTAND=1`。

## 常见问题

### 合上 MacBook 盖子还能保持唤醒吗？

合上盖子往往仍会强制睡眠。MacBook 的合盖睡眠和空闲睡眠不是一回事，`caffeinate -dimsu` 经常无法在合盖后保持唤醒。长时间跑 Agent 时请开盖。蛤壳模式通常要同时接上电源、外接显示器，并且一般还要键鼠。agent-mac-awake 不会配置蛤壳模式。

### 为什么 stop 之后 agent-awake 又会启动？

LaunchAgent 打开了 `KeepAlive`。`agent-awake stop` 可以结束当前进程，launchd 会再把它拉起来。要暂停请 unload（`launchctl bootout`），要卸掉请运行 `./scripts/uninstall.sh`。

### agent-mac-awake 会联网或改睡眠设置吗？

没有网络请求，也没有遥测。PID 和状态文件只在 `~/Library/Application Support/agent-mac-awake/`。安装不会执行 `pmset`。`enable-lid-guard` 会打印 `sudo pmset -a disablesleep 1`，只有在 `AGENT_AWAKE_I_UNDERSTAND=1` 时才会执行。

## 许可证

[MIT License](LICENSE)（SPDX：MIT）。Copyright (c) 2026 LofiSu。

## 联系

[loomlab-ai](https://github.com/loomlab-ai) · [LofiSu](https://github.com/LofiSu) · [lofisuchat@gmail.com](mailto:lofisuchat@gmail.com) · GitHub Sponsors · [X @su_lofi](https://x.com/su_lofi)
