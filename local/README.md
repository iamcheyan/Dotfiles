# Local Zsh configuration

这里放只对当前用户生效的 Zsh 配置，例如个人 alias、函数和环境变量。

## 使用方法

在本目录创建 `zshrc`：

```bash
cd ~/dotfiles
touch local/zshrc
$EDITOR local/zshrc
```

示例：

```zsh
alias work='cd ~/work'
export PROJECTS_DIR="$HOME/projects"
```

公开的 `zshrc` 会在公共 aliases 和插件之后加载 `local/zshrc`，所以这里
可以覆盖公共配置。文件不存在时会自动跳过。

## 注意

- `local/zshrc` 不会提交到 Git，也不会被更新仓库覆盖。
- 只有本 `README.md` 会被 Git 跟踪。
- 不要在这里保存密码、API Key、Token 或其它敏感凭据。
- 修改后重新打开终端，或运行 `source ~/dotfiles/local/zshrc`。