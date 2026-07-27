# Agent Wrappers

统一的 AI coding agent 启动脚本，自动安装、自动配置，默认恢复上次会话并跳过审批。

## 快速开始

```bash
# 所有 wrapper 无参数运行时，默认行为：恢复上次会话 + 跳过权限确认
cx        # Codex
cc        # Claude Code
agy       # Antigravity (Gemini)
grok      # Grok
aq        # Agent quota/status snapshot
pi        # Pi
mimo      # MiMo Code
oc        # OpenCode
copilot   # GitHub Copilot
kiro      # Kiro CLI
```

## 可用 Agent

| 别名 | 脚本 | 底层工具 | 默认行为 |
|------|------|----------|----------|
| `cx` | `codex.sh` | `codex` | `codex resume --last -a never` |
| `cc` | `claude-code.sh` | `claude` | `claude --dangerously-skip-permissions -c` |
| `agy` | `antigravity.sh` | `agy` | `agy --continue --dangerously-skip-permissions` |
| `grok` | `grok.sh` | `grok` | `grok --yolo --continue` |
| `aq` | `agent-quota.sh` | `codex` / `agy` / `grok` | show quota/status snapshot |
| `pi` | `pi.sh` | `pi` | `pi --continue` |
| `mimo` | `mimo.sh` | `mimo` | `mimo -c --dangerously-skip-permissions` |
| `oc` | `opencode.sh` | `opencode` | `opencode -c --dangerously-skip-permissions` |
| `copilot` | `copilot.sh` | `copilot` | `copilot` |
| `cur` | `cursor.sh` | `cursor` | `cursor` |
| `kiro` | `kiro.sh` | `kiro-cli` | `kiro-cli` |

## 通用功能

### 自动安装
所有脚本首次运行时会自动检测并安装对应的 CLI 工具，无需手动操作。

### 强制重装
任意 wrapper 都支持 `-f` 参数强制重新安装：

```bash
cx -f
cc -f
agy -f
grok -f
mimo -f
oc -f
copilot -f
kiro -f
```

### 传参透传
未被 wrapper 捕获的参数会原样透传给底层 CLI：

```bash
cx -m o3 "explain this project"
cc --model claude-opus-4-6 -p "fix the bug"
grok --model grok-4 "review this PR"
oc -m deepseek/deepseek-v4-flash "summarize"
```

---

## 各 Agent 详细用法

### cx — OpenAI Codex

```bash
cx                              # 恢复上次会话
cx -s                           # fzf 交互选择 profile
cx --profile work               # 切换到指定 profile
cx --save-profile personal      # 保存当前登录为 profile
cx --list-profiles              # 列出所有 profile
cx --delete-profile <name>      # 删除 profile
cx -n                           # 新建 profile（清除登录，重新登录）
cx -u                           # 更新 Codex
cx resume --last                # 恢复最近会话
cx exec "run tests"             # 非交互式执行
```

### cc — Claude Code

```bash
cc                              # 恢复上次会话
cc mimo-anthropic               # 使用 mimo provider
cc mimo-anthropic mimo-v2.5     # 指定模型
cc -s                           # fzf 选择 provider 模型
cc -s --auth                    # fzf 选择 Claude 原生模型
cc --auth                       # 使用登录账号（默认 Claude Sonnet 4）
cc --auth claude-opus-4-6       # 登录账号 + 指定模型
cc -p "fix the bug"             # 非交互模式
cc -r                           # 交互式选择会话恢复
cc -r abc123-def456             # 恢复指定会话
cc -v                           # 查看版本
cc --update                     # 更新
```

**Provider 模式 vs Auth 模式：**
- Provider 模式：使用 `opencode.json` 中配置的 API key，通过 wrapper 自动注入环境变量
- Auth 模式（`--auth`）：使用 Claude 官方登录账号，忽略 provider 配置

### agy — Antigravity (Google Gemini)

```bash
agy                             # 恢复上次会话
agy -s                          # 交互选择账号
agy --profile user@gmail.com    # 切换到指定账号
agy --list-profiles             # 列出所有账号
agy --switch user@gmail.com     # 切换活跃账号
agy -f                          # 强制重装
```

### grok — Grok (xAI)

```bash
grok                            # 恢复上次会话（yolo 模式）
grok setup                      # 初始化配置
grok -u                         # 更新
grok -v                         # 查看版本
grok models                     # 列出可用模型
grok --model grok-4.5 "review"  # 指定模型
```

### aq — Agent quota/status

```bash
aq                              # 查看 Codex / AGY(Gemini) / Grok 状态
aq --json                       # 输出 Codex app-server 原始 JSON
```

`aq` 会实时调用 Codex app-server 的 `account/rateLimits/read` 和 `account/usage/read`，显示限额使用百分比、重置时间、reset credits 和 token 使用摘要。AGY/Gemini 与 Grok 当前 CLI 没有公开稳定的 quota 子命令，脚本会展示已登录账号、可用模型，并明确标出限额接口不可用。

### pi — Pi

```bash
pi                              # 恢复上次会话
pi --reinstall                  # 完整重装（清理 + init + 同步 skills）
pi -p "list all files"          # 非交互模式
pi --provider openai --model gpt-4o   # 使用其他 provider
pi --model sonnet:high          # 指定模型 + thinking level
pi -r                           # 交互选择会话恢复
```

### mimo — MiMo Code

```bash
mimo                            # 恢复上次会话
mimo -i                         # fzf 交互选择模型（支持多选）
mimo kimi                       # 快捷切换到 kimi-k2.6
mimo deepseek                   # 快捷切换到 deepseek-v4-flash
mimo -m kimi-k2.6               # 直接指定模型 ID
mimo -f                         # 强制重装
```

### oc — OpenCode

```bash
oc                              # 恢复上次会话
oc zhipu                        # 使用 zhipu provider
oc deepseek                     # 使用 deepseek provider
oc -m mimo/mimo-v2.5-pro        # 指定模型
oc -s                           # fzf 选择模型
oc -p "explain this function"   # 非交互模式
oc -v                           # 查看版本
oc -f                           # 强制重装
```

### copilot — GitHub Copilot

```bash
copilot                         # 运行 Copilot
copilot -f                      # 强制重装
```

### kiro — Kiro CLI

```bash
kiro                            # 运行 Kiro CLI
kiro -f                         # 强制重装
```

---

## 完整 CLI 参考

每个脚本头部都包含对应 CLI 的完整参数参考，可通过 `head` 查看：

```bash
head -70 ~/.local/bin/cx       # Codex 参考
head -120 ~/.local/bin/cc      # Claude Code 参考
head -40 ~/.local/bin/agy      # Antigravity 参考
head -70 ~/.local/bin/grok     # Grok 参考
head -80 $HOME/dotfiles/agent/agent-quota.sh  # Agent quota/status
head -80 ~/.local/bin/pi       # Pi 参考
head -42 ~/.local/bin/mimo     # MiMo 参考
head -100 ~/.local/bin/oc      # OpenCode 参考
head -30 $HOME/dotfiles/agent/copilot.sh  # Copilot 参考
head -20 $HOME/dotfiles/agent/kiro.sh     # Kiro 参考
```

## 配置文件

| 文件 | 用途 |
|------|------|
| `~/dotfiles/aliases.conf` | 所有别名定义（chezmoi 管理） |
| `~/.config/opencode/opencode.json` | Provider / 模型配置（cc, oc 共用） |
| `~/.codex/auth.json` | Codex 认证 |
| `~/.codex/profiles/*.json` | Codex 多账号 profile |
| `~/.config/opencode/antigravity-accounts.json` | Antigravity 多账号 |
| `~/.cache/cc_last_model` | cc 上次使用的 provider/model |
| `~/.cache/cc_last_query` | cc 上次选择的模型显示名 |

## 安装要求

- **Node.js**：通过 `fnm` 管理（脚本自动配置）
- **fzf**：`-s` 交互选择功能需要
- **jq**：profile / 账号管理需要
- **npm**：Codex / Claude Code 安装需要
