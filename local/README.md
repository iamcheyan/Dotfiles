# Local Zsh configuration

这里放只对当前用户生效的 Zsh 配置，例如个人 alias、函数和环境变量。

## 使用方法

在本目录创建任意配置文件，例如 `custom.zsh`：

```bash
cd ~/dotfiles
touch local/custom.zsh
$EDITOR local/custom.zsh
```

示例：

```zsh
alias work='cd ~/work'
export PROJECTS_DIR="$HOME/projects"
```

公开的 `zshrc` 会在公共 aliases 和插件之后加载 `local/` 下的所有普通
文件（本 README 除外），所以可以按需要拆分多个配置文件并覆盖公共配置。

## 注意

- `local/` 下自己创建的配置文件不会提交到 Git，也不会被更新仓库覆盖。
- 只有本 `README.md` 会被 Git 跟踪。
- 不要在这里保存密码、API Key、Token 或其它敏感凭据。
- 修改后重新打开终端，或在当前终端手动 `source` 对应的配置文件。