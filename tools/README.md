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

---
## 相关文档

- [Scripts README](../scripts/README.md) - Scripts 目录详细说明
