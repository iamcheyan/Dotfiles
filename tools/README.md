# Tools 工具文档

专业工具和工作流脚本目录，包含复杂、特定用途的工具。

## 工具列表

### 1. `packtar.sh` - 目录打包工具

**功能**：将当前目录打包为 `tar.gz` 文件，并放置到父目录。

**用法**：
```bash
packtar myarchive                  # 打包为 myarchive.tar.gz
packtar backup-$(date +%Y%m%d)    # 使用日期命名
```

**别名**：`packtar`, `sh:packtar`

---

### 2. `unzip_here.sh` - 批量解压工具

**功能**：递归查找当前目录下的所有 `.zip` 文件并自动解压。

**用法**：
```bash
unzip:here                         # 解压当前目录下所有 .zip
sh:unzip                           # 同上
```

**别名**：`unzip:here`, `sh:unzip`, `sh:unzip_here`

---

### 3. `open_windows_folder.sh` - WSL Windows 文件夹打开工具

**功能**：在 WSL 环境中使用 Windows 的 `explorer.exe` 打开文件夹。

**用法**：
```bash
win:open                          # 打开当前目录
win:open /path/to/folder          # 打开指定目录
```

**别名**：`win:open`, `sh:open_windows_folder`

---

### 4. `winetricks.sh` - Winetricks 工具

**功能**：智能运行 Winetricks，支持 Flatpak 和系统安装版本。

**用法**：
```bash
winetricks <command>              # 运行 winetricks 命令
winetricks corefonts              # 安装核心字体
```

**别名**：`winetricks`

---

### 5. `agent-quota.sh` - 代理配额查看工具

**功能**：实时查看 Codex / AGY(Gemini) / Grok 的 API 配额、使用量和重置时间。

**用法**：
```bash
aq                              # 查看所有配额状态
aq --json                       # 输出 Codex 原始 JSON
```

**别名**：`aq`

---

### 6. `opencode_config.py` - opencode.json 配置编辑器

**功能**： curses TUI 编辑器，浏览和修改 `~/.config/opencode/opencode.json` 中的 provider、模型、权限等配置。**仅依赖 Python 标准库**，无需额外安装。

**用法**：
```bash
ocfg                            # 编辑默认配置
ocfg /path/to/opencode.json     # 编辑指定配置
```

**操作**：方向键导航，Enter 编辑，s 保存（自动备份），r 重载，q 退出，/ 搜索。编辑 Provider 或模型时 Tab 切换字段。

**别名**：`ocfg`

---
## 相关文档

- [主 README](../README.md) - 整体目录结构说明
- [Scripts README](../scripts/README.md) - Scripts 目录详细说明
