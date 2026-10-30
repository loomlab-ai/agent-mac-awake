# agent-mac-awake

Keep your Mac awake during long **Grok Bot / Cursor** agent runs so tasks don’t stall with “Mac cannot connect” when the screen sleeps or the machine idles.

基于系统自带 `caffeinate` + 可选 LaunchAgent，在长时 Agent 任务期间阻止息屏 / 空闲睡眠，减少「本机 Mac 无法连接」、任务停滞。

---

## English

### Problem

Remote / local agent sessions need the Mac reachable. If the display sleeps, the system idles into sleep, or (on a MacBook) the lid closes, the session can drop and the agent errors or hangs.

### What this does

| Layer | Behavior |
|--------|----------|
| `caffeinate -dimsu` | Asserts no **d**isplay sleep, **i**dle sleep, disk (**m**) sleep, **s**ystem sleep (on AC), and **u**ser-active |
| `agent-awake start` | Background caffeinate; PID in `~/Library/Application Support/agent-mac-awake/` |
| `agent-awake install` | Copies CLI + installs LaunchAgent `com.lofisu.agent-awake` with **KeepAlive** |
| Lid helpers | Documented only by default; `pmset` changes need `AGENT_AWAKE_I_UNDERSTAND=1` |

**Flags used:** `-dimsu` (see `man caffeinate`). No timeout — runs until `stop` / uninstall / process death (LaunchAgent restarts it).

### Install (MacBook Air / any Mac)

```bash
# From this folder on the Mac:
./scripts/install.sh
# or:
./bin/agent-awake install
```

Optional PATH:

```bash
export PATH="$HOME/Library/Application Support/agent-mac-awake/bin:$PATH"
```

One-shot without LaunchAgent:

```bash
./bin/agent-awake start
./bin/agent-awake status
./bin/agent-awake stop
```

### Commands

| Command | Meaning |
|---------|---------|
| `start` | Background keep-awake |
| `start-foreground` | Foreground (used by launchd) |
| `stop` | Stop caffeinate (LaunchAgent KeepAlive may restart — uninstall to disable) |
| `status` | Running?, PID, uptime, LaunchAgent loaded? |
| `install` | Install CLI + LaunchAgent (`bootstrap` / fallback `load -w`) |
| `uninstall [--purge]` | Unload plist; `--purge` deletes support dir |
| `enable-lid-guard` | Print / optionally apply `pmset` lid helpers |
| `disable-lid-guard` | Restore sleep defaults |

### Lid-close limits (important)

On a **MacBook**, **closing the lid often forces sleep**. `caffeinate` alone frequently **does not** survive lid close.

Practical options:

1. **Leave the lid open** during long agent runs (simplest, recommended).
2. **Clamshell mode**: AC power + external display (often + keyboard/mouse), then close lid.
3. **Advanced (risk)**: system-wide disable sleep — **battery drain / heat**:

   ```bash
   AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
   # runs: sudo pmset -a disablesleep 1
   ```

   Revert when done:

   ```bash
   AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
   # sudo pmset -a disablesleep 0
   ```

Without `AGENT_AWAKE_I_UNDERSTAND=1`, lid-guard commands only **print** the exact `sudo` lines — they never silently escalate.

### Uninstall

```bash
./scripts/uninstall.sh
# or remove support files too:
./scripts/uninstall.sh --purge
```

### Privacy

No network calls. No telemetry. PID/status files stay under your home `Application Support` folder only.

### License

MIT © 2026 LofiSu

---

## 中文

### 解决什么问题

Grok Bot / Cursor 的本机 Agent 任务依赖 Mac 在线。息屏、空闲睡眠或（笔记本）合盖后，容易出现「本机 Mac 无法连接」、任务卡住或报错。

### 怎么做

| 层级 | 行为 |
|------|------|
| `caffeinate -dimsu` | 阻止显示睡眠、空闲睡眠、磁盘睡眠、系统睡眠（接电时）并声明用户活跃 |
| `agent-awake start` | 后台保活；PID 写在 `~/Library/Application Support/agent-mac-awake/` |
| `agent-awake install` | 安装 CLI + LaunchAgent（KeepAlive 守护） |
| 合盖辅助 | 默认只说明；真正改 `pmset` 需 `AGENT_AWAKE_I_UNDERSTAND=1` |

**选用参数：** `-dimsu`（详见 `man caffeinate`）。无超时，直到 `stop` / 卸载。

### 安装（MacBook Air 等）

```bash
./scripts/install.sh
# 或
./bin/agent-awake install
```

可选加入 PATH：

```bash
export PATH="$HOME/Library/Application Support/agent-mac-awake/bin:$PATH"
```

不装 LaunchAgent、临时开一次：

```bash
./bin/agent-awake start
./bin/agent-awake status
./bin/agent-awake stop
```

### 合盖限制（必读）

**合上 MacBook 盖子通常仍会强制睡眠**；仅靠 `caffeinate` **往往挡不住合盖休眠**。

实用建议：

1. **长时间跑 Agent 时开盖**（最稳妥）。
2. **蛤壳模式**：电源 + 外接显示器（通常还需键鼠）后再合盖。
3. **进阶（有风险）**：全局禁用睡眠（耗电/发热）：

   ```bash
   AGENT_AWAKE_I_UNDERSTAND=1 agent-awake enable-lid-guard
   ```

   用完务必恢复：

   ```bash
   AGENT_AWAKE_I_UNDERSTAND=1 agent-awake disable-lid-guard
   ```

未设置环境变量时，只会打印要你手动执行的 `sudo` 命令，**不会偷偷提权**。

### 卸载

```bash
./scripts/uninstall.sh
./scripts/uninstall.sh --purge   # 连支持目录一并删掉
```

### 隐私

无联网、无埋点；状态文件仅在本机用户目录。

### 许可

MIT © 2026 LofiSu
