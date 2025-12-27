# git-open - Git 仓库浏览器打开插件

## 简介

git-open 是一个 Git 插件，可以在浏览器中快速打开 GitHub、GitLab、Bitbucket 等托管服务的仓库页面。无需手动复制 URL 或记住仓库地址，只需运行 `git open` 即可在浏览器中打开当前仓库。

**官方仓库**: https://github.com/paulirish/git-open

## 安装

git-open 已通过 Zinit 自动安装和管理。插件配置位于 `~/.dotfiles/plugins/plugins/plugins.zsh`。

## 基本使用

### 打开当前分支

```bash
# 在 Git 仓库目录中运行
git open

# 会在浏览器中打开当前分支的页面
# 例如: https://github.com/owner/repo/tree/main
```

### 打开指定远程仓库

```bash
# 打开指定远程的分支页面
git open origin
git open upstream

# 打开指定远程的指定分支
git open origin develop
git open upstream main
```

### 打开当前提交

```bash
# 打开当前提交的页面
git open --commit
git open -c

# 例如: https://github.com/owner/repo/commit/abc123
```

### 打开 Issue

```bash
# 如果分支名类似 issue/#123，会打开对应的 Issue
git open --issue
git open -i

# 例如: https://github.com/owner/repo/issues/123
```

**注意**: `--issue` 选项目前仅支持 GitHub、Visual Studio Team Services 和 Team Foundation Server。

### 仅打印 URL

```bash
# 只打印 URL，不打开浏览器
git open --print
git open -p

# 输出: https://github.com/owner/repo/tree/main
```

### 打开特定页面

```bash
# 打开 Pull Requests 页面
git open --suffix pulls

# 打开 Issues 页面
git open --suffix issues

# 打开 Actions 页面
git open --suffix actions
```

## 使用示例

### 基本场景

```bash
# 在仓库目录中
cd ~/my-project
git open
# 打开: https://github.com/username/my-project/tree/main

# 切换到其他分支
git checkout feature/new-feature
git open
# 打开: https://github.com/username/my-project/tree/feature/new-feature
```

### 查看远程仓库

```bash
# 查看所有远程
git remote -v

# 打开 upstream 远程
git open upstream

# 打开 origin 的特定分支
git open origin develop
```

### 查看提交

```bash
# 查看当前提交
git log -1
git open --commit
# 打开提交详情页面
```

### 打开 Issue

```bash
# 创建分支
git checkout -b issue/123-fix-bug

# 打开对应的 Issue
git open --issue
# 打开: https://github.com/owner/repo/issues/123
```

## 支持的托管服务

git-open 自动识别以下 Git 托管服务：

- **GitHub**: `github.com`, `gist.github.com`
- **GitLab**: `gitlab.com` 和自定义 GitLab 实例
- **Bitbucket**: `bitbucket.org` 和 Atlassian Bitbucket Server
- **Visual Studio Team Services**: Azure DevOps
- **Team Foundation Server**: 本地 TFS 实例
- **AWS CodeCommit**: AWS 代码仓库
- **cnb.cool**: 其他托管服务

## 配置

### 自定义远程

默认情况下，git-open 使用 `origin` 远程。可以通过 Git 配置指定其他远程：

```bash
# 设置默认远程
git config --global git-open.remote upstream
```

### 自定义 GitLab 域名

如果使用自定义 GitLab 实例：

```bash
# 设置 GitLab 域名
git config --global git-open.gitlab.domain gitlab.example.com
```

### 自定义浏览器

git-open 会自动检测系统默认浏览器。如果需要指定浏览器：

```bash
# Linux
export BROWSER=firefox
git open

# macOS
export BROWSER="open -a Safari"
git open
```

## 高级用法

### 结合其他 Git 命令

```bash
# 查看远程 URL 后打开
git remote get-url origin
git open

# 查看分支后打开
git branch -a
git open origin feature-branch
```

### 在脚本中使用

```bash
#!/bin/bash
# 打开仓库的 Pull Requests 页面
git open --suffix pulls
```

### 打印 URL 用于其他用途

```bash
# 复制 URL 到剪贴板（Linux）
git open --print | xclip -selection clipboard

# 复制 URL 到剪贴板（macOS）
git open --print | pbcopy

# 在终端中显示
echo "Repository URL: $(git open --print)"
```

## 与 gh CLI 的区别

| 特性 | git-open | gh CLI |
|------|----------|--------|
| **功能** | 打开仓库页面 | 完整的 GitHub CLI |
| **支持服务** | 多个（GitHub、GitLab、Bitbucket 等） | 仅 GitHub |
| **安装** | 轻量级脚本 | 需要安装二进制 |
| **使用场景** | 快速打开页面 | 完整的 GitHub 操作 |

**推荐**:
- 使用 `git-open` 快速打开仓库页面
- 使用 `gh` CLI 进行完整的 GitHub 操作（如创建 PR、查看 Issue 等）

## 故障排除

### git open 命令未找到

1. **检查插件是否加载**:
   ```bash
   zinit list | grep git-open
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查函数定义**:
   ```bash
   type git-open
   ```

### 无法打开浏览器

1. **检查是否在 Git 仓库中**:
   ```bash
   git rev-parse --git-dir
   ```

2. **检查远程配置**:
   ```bash
   git remote -v
   ```

3. **检查浏览器环境变量**:
   ```bash
   echo $BROWSER
   ```

4. **手动设置浏览器**:
   ```bash
   # Linux
   export BROWSER=xdg-open
   git open
   
   # macOS
   export BROWSER=open
   git open
   ```

### URL 不正确

1. **检查远程 URL**:
   ```bash
   git remote get-url origin
   ```

2. **检查分支名称**:
   ```bash
   git branch --show-current
   ```

3. **使用 --print 查看 URL**:
   ```bash
   git open --print
   ```

### 不支持的自定义域名

如果使用自定义 Git 托管服务，可能需要配置：

```bash
# 查看 git-open 支持的配置
git config --global --list | grep git-open

# 参考官方文档配置自定义域名
```

## 实用技巧

### 1. 创建别名

可以在 `~/.dotfiles/aliases.conf` 中添加别名：

```zsh
# 快速打开仓库
alias gop='git open'

# 打开 Pull Requests
alias gopr='git open --suffix pulls'

# 打开 Issues
alias goi='git open --suffix issues'
```

### 2. 结合其他工具

```bash
# 使用 fzf 选择分支后打开
git open origin $(git branch -a | fzf | sed 's/remotes\/origin\///')

# 打开当前提交的 GitHub 页面
git log -1 --pretty=format:"%H" | xargs -I {} git open --commit
```

### 3. 快速分享链接

```bash
# 复制当前分支 URL 到剪贴板
git open --print | xclip -selection clipboard
# 然后粘贴到聊天工具或文档中
```

## 相关资源

- **GitHub CLI**: `gh` 命令 - 完整的 GitHub 操作
- **Lazygit**: 终端 Git UI - 在终端中管理 Git

## 参考资源

- [git-open GitHub](https://github.com/paulirish/git-open)
- [Git 远程仓库文档](https://git-scm.com/book/zh/v2/Git-基础-远程仓库的使用)

