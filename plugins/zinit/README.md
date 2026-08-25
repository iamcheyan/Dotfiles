# Zinit 初始化配置

## 简介

此文件负责初始化 Zinit 插件管理器。Zinit 是一个快速且灵活的 Zsh 插件管理器，支持插件、主题和二进制工具的安装和管理。

**官方仓库**: https://github.com/zdharma-continuum/zinit

## 文件位置

- **配置文件**: `~/dotfiles/plugins/zinit/zinit.zsh`
- **加载位置**: 在 `~/.zshrc` 中最早加载（在其他插件之前）

## 功能

### 自动安装 Zinit

如果 Zinit 未安装，此文件会自动从 GitHub 克隆到 `~/.zinit/bin`：

```zsh
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi
```

### 加载 Zinit

加载 Zinit 核心文件：

```zsh
source ~/.zinit/bin/zinit.zsh
```

### `zz` 目录选择函数

定义了 `zz` 函数，用于交互式选择目录并 `cd` 过去：

```zsh
zz           # 从 HOME 范围搜索目录
zz .         # 从当前目录范围搜索目录
zz ~/work    # 从指定目录范围搜索目录
```

特点：

- 不显示预览窗口
- 默认在 `HOME` 下搜索，同时混入 zoxide 历史目录
- 传入目录参数后，只在该目录树下搜索

## 使用说明

### 首次使用

首次运行时会自动安装 Zinit，无需手动操作。

### 手动更新 Zinit

```bash
# 更新 Zinit 到最新版本
zinit self-update
```

### 查看已安装的插件

```bash
# 列出所有已安装的插件
zinit list

# 查看插件状态
zinit report
```

### 清理未使用的插件

```bash
# 删除未使用的插件
zinit delete --clean
```

## 相关文件

- **统一插件配置**: `~/dotfiles/plugins/zsh-plugins.zsh` - 所有 Zsh 功能插件、对应配置和加载状态
- **工具配置**: `~/dotfiles/plugins/tools/tools.zsh` - CLI 工具安装
- **补全配置**: `~/dotfiles/plugins/completion/completion.zsh` - 补全系统配置

## 参考资源

- [Zinit 官方文档](https://github.com/zdharma-continuum/zinit)
- [Zinit Wiki](https://github.com/zdharma-continuum/zinit/wiki)
