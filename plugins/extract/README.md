# extract - 自动解压插件

## 简介

extract 是一个 Zsh 插件，提供了一个 `extract` 函数，可以自动识别并解压各种格式的压缩文件。您无需记住不同格式的解压命令，只需使用 `extract <文件名>` 即可。

**官方仓库**: https://github.com/le0me55i/zsh-extract

## 安装

extract 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/plugins/plugins.zsh`。

## 基本使用

### 解压文件

```bash
# 基本用法
extract <文件名>

# 示例
extract archive.tar.gz
extract file.zip
extract archive.7z
extract document.rar
```

插件会自动识别文件格式并使用相应的解压命令。

## 支持的格式

extract 插件支持以下压缩格式：

| 格式 | 扩展名 | 说明 |
|------|--------|------|
| 7zip | `.7z` | 7zip 压缩文件 |
| Z | `.Z` | Z 压缩文件（LZW） |
| Android | `.apk`, `.aar` | Android 应用和库文件 |
| Bzip2 | `.bz2` | Bzip2 压缩文件 |
| Debian | `.deb` | Debian 软件包 |
| Gzip | `.gz` | Gzip 压缩文件 |
| iOS | `.ipsw` | iOS 固件文件 |
| Java | `.jar`, `.war` | Java 归档文件 |
| LZMA | `.lzma` | LZMA 压缩文件 |
| RAR | `.rar` | WinRAR 压缩文件 |
| RPM | `.rpm` | RPM 软件包 |
| Sublime | `.sublime-package` | Sublime Text 包 |
| Tar | `.tar` | Tar 归档文件 |
| Tar + Bzip2 | `.tar.bz2`, `.tbz`, `.tbz2` | Tar + Bzip2 压缩 |
| Tar + Gzip | `.tar.gz`, `.tgz` | Tar + Gzip 压缩 |
| Tar + Lzip | `.tar.lz`, `.tlz` | Tar + Lzip 压缩 |
| Tar + LZMA | `.tar.xz`, `.txz` | Tar + LZMA2 压缩 |
| Tar + LZMA | `.tar.zma`, `.tzst` | Tar + LZMA 压缩 |
| Tar + Zstd | `.tar.zst` | Tar + Zstd 压缩 |
| XPI | `.xpi` | Mozilla XPI 模块文件 |
| XZ | `.xz` | LZMA2 压缩文件 |
| Zip | `.zip` | Zip 压缩文件 |
| Zstandard | `.zst` | Zstandard 压缩文件 |

## 使用示例

### 解压常见格式

```bash
# 解压 zip 文件
extract archive.zip

# 解压 tar.gz 文件
extract archive.tar.gz

# 解压 7z 文件
extract archive.7z

# 解压 rar 文件
extract archive.rar

# 解压 tar.bz2 文件
extract archive.tar.bz2
```

### 解压到当前目录

所有文件都会解压到当前目录：

```bash
cd ~/Downloads
extract file.zip
# 文件会解压到 ~/Downloads 目录
```

## 与现有 extract.sh 脚本的区别

本 dotfiles 中已经存在一个 `extract.sh` 脚本（位于 `~/.dotfiles/scripts/utils/extract.sh`），两者功能类似但有一些区别：

| 特性 | zsh-extract 插件 | extract.sh 脚本 |
|------|-----------------|-----------------|
| **实现方式** | Zsh 函数 | Bash 脚本 |
| **加载方式** | Zsh 启动时加载 | 通过别名调用 |
| **性能** | 更快（函数调用） | 稍慢（脚本执行） |
| **格式支持** | 更多格式（30+） | 基础格式（10+） |
| **错误处理** | Zsh 原生 | Bash 脚本 |
| **可定制性** | 可修改函数 | 可修改脚本 |

### 推荐使用

- **推荐使用 zsh-extract 插件**：功能更全面，性能更好，支持更多格式
- **extract.sh 作为后备**：如果插件未加载或需要独立脚本时使用

### 冲突处理

如果两个 `extract` 命令都存在：

1. **Zsh 函数优先**：zsh-extract 插件定义的函数会优先于别名
2. **可以禁用别名**：如果需要只使用插件，可以在 `aliases.conf` 中注释掉 `extract` 别名

## 前置要求

某些格式需要特定的解压工具：

### 必需工具

- **tar**: 大多数系统自带，用于 `.tar`, `.tar.gz`, `.tar.bz2` 等
- **unzip**: 用于 `.zip` 文件
- **gunzip**: 用于 `.gz` 文件
- **bunzip2**: 用于 `.bz2` 文件

### 可选工具

- **7z** 或 **p7zip**: 用于 `.7z` 文件
  ```bash
  # Debian/Ubuntu
  sudo apt install p7zip-full
  
  # macOS
  brew install p7zip
  ```

- **unrar**: 用于 `.rar` 文件
  ```bash
  # Debian/Ubuntu
  sudo apt install unrar
  
  # macOS
  brew install unrar
  ```

- **xz**: 用于 `.xz` 文件
  ```bash
  # Debian/Ubuntu
  sudo apt install xz-utils
  
  # macOS (通常已安装)
  ```

## 高级用法

### 查看支持的格式

插件会自动识别文件扩展名，无需手动指定格式。

### 错误处理

如果文件格式不支持或缺少解压工具，插件会显示相应的错误信息：

```bash
$ extract unknown.xyz
# 会显示错误信息，提示格式不支持或需要安装工具
```

### 批量解压

可以结合其他命令批量解压：

```bash
# 解压当前目录下所有 zip 文件
for file in *.zip; do extract "$file"; done

# 解压多个文件
extract file1.zip && extract file2.tar.gz
```

## 故障排除

### extract 命令未找到

1. **检查插件是否加载**:
   ```bash
   zinit list | grep extract
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查函数定义**:
   ```bash
   type extract
   ```

### 解压失败

1. **检查文件是否存在**:
   ```bash
   ls -la <文件名>
   ```

2. **检查文件格式**:
   ```bash
   file <文件名>
   ```

3. **检查解压工具**:
   ```bash
   # 检查 7z
   command -v 7z
   
   # 检查 unrar
   command -v unrar
   ```

4. **安装缺失的工具**:
   ```bash
   # 安装常用解压工具
   sudo apt install p7zip-full unrar xz-utils
   ```

### 与 extract.sh 冲突

如果遇到冲突：

1. **检查别名**:
   ```bash
   alias | grep extract
   ```

2. **禁用别名**（如果需要）:
   在 `~/.dotfiles/aliases.conf` 中注释掉：
   ```zsh
   # alias extract="bash ${HOME}/.dotfiles/scripts/utils/extract.sh"
   ```

3. **使用完整路径**:
   ```bash
   # 使用插件函数
   extract file.zip
   
   # 使用脚本
   bash ~/.dotfiles/scripts/utils/extract.sh file.zip
   ```

## 相关资源

- **现有脚本**: `~/.dotfiles/scripts/utils/extract.sh` - Bash 解压脚本
- **官方仓库**: https://github.com/le0me55i/zsh-extract

## 参考资源

- [zsh-extract GitHub](https://github.com/le0me55i/zsh-extract)
- [压缩格式列表](https://en.wikipedia.org/wiki/List_of_archive_formats)

