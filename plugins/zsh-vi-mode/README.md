# zsh-vi-mode - Zsh Vim 模式插件使用文档

## 简介

`zsh-vi-mode` 是一个更好、更友好的 VI（vim）模式插件，适用于 ZSH。它提供了接近原生的 vim 键绑定体验，解决了 Zsh 默认 Vi 模式的许多问题。

## 特性

- **纯 Zsh 脚本**：没有任何第三方依赖
- **接近原生的 vim 模式**：更好的使用体验
- **低延迟**：更快的模式切换和响应速度
- **模式指示**：不同光标样式显示当前模式
- **光标移动**：完整的 vim 导航功能
- **插入与替换**：完整的 Insert 模式支持
- **文本对象**：支持单词、内在单词等文本对象
- **历史搜索**：强大的历史命令搜索
- **撤销/重做/剪切/复制/粘贴/删除**：完整的编辑功能
- **环绕功能**：添加、替换、删除、移动和高亮环绕
- **关键词切换**：数字、布尔值、工作日、月份等切换
- **打开 URL/文件**：使用 `gx` 打开光标下的 URL 或文件路径
- **外部编辑器**：使用 `vv` 在外部编辑器中编辑当前命令行
- **重复命令**：支持 `10p`、`4fa` 等重复命令
- **系统剪贴板集成**：复制/粘贴到系统剪贴板

## 安装

本插件已通过 Zinit 自动安装，配置在 `~/.dotfiles/plugins/plugins/plugins.zsh` 中：

```zsh
zinit light jeffreytse/zsh-vi-mode
```

**注意**：插件必须在 `zsh-autosuggestions` 之前加载，因为它会影响键绑定。

## 使用方法

### 基本操作

#### 进入 Normal 模式
- 按 `ESC` 或 `CTRL-[` 进入 Normal 模式
- 默认使用 Normal 模式光标（方块样式）

#### 进入 Insert 模式
- 按 `i` 在光标前插入
- 按 `a` 在光标后追加
- 按 `I` 在行首插入
- 按 `A` 在行尾追加
- 按 `o` 在当前行下方插入新行
- 按 `O` 在当前行上方插入新行

### 光标移动

#### 行内移动
- `h` / `l` - 左/右移动一个字符
- `0` - 移动到行首
- `^` - 移动到第一个非空白字符
- `$` - 移动到行尾

#### 按词移动
- `w` - 向前移动到下一个单词开头
- `W` - 向前移动到下一个 WORD 开头（忽略标点）
- `e` - 向前移动到单词末尾
- `E` - 向前移动到 WORD 末尾
- `b` - 向后移动到上一个单词开头
- `B` - 向后移动到上一个 WORD 开头

#### 字符搜索
- `f{char}` - 向右移动到第 `{count}` 个 `{char}`
- `F{char}` - 向左移动到第 `{count}` 个 `{char}`
- `t{char}` - 向右移动到第 `{count}` 个 `{char}` 之前
- `T{char}` - 向左移动到第 `{count}` 个 `{char}` 之前
- `;` - 重复上一次 `f`、`t`、`F` 或 `T`
- `,` - 反向重复上一次 `f`、`t`、`F` 或 `T`

### 编辑操作

#### 删除
- `x` - 删除光标下的字符
- `X` - 删除光标前的字符
- `dd` - 删除整行
- `dw` - 删除到单词末尾
- `d$` - 删除到行尾
- `di"` - 删除引号内的内容
- `da"` - 删除引号及其内容

#### 复制（Yank）
- `yy` - 复制整行
- `yw` - 复制到单词末尾
- `y$` - 复制到行尾
- `yi"` - 复制引号内的内容
- `ya"` - 复制引号及其内容

#### 粘贴
- `p` - 在光标后粘贴
- `P` - 在光标前粘贴

#### 撤销/重做
- `u` - 撤销
- `CTRL-R` - 重做

#### 替换
- `r{char}` - 替换光标下的字符为 `{char}`
- `R` - 进入替换模式（覆盖模式）

### 环绕操作（Surround）

环绕操作有两种模式：**经典模式**（默认）和 **s-前缀模式**。

#### 经典模式

- `S"` - 为选中文本添加双引号
- `ys"` - 为选中文本添加双引号
- `cs"'` - 将双引号改为单引号
- `ds"` - 删除双引号

#### s-前缀模式

需要先设置 `ZVM_VI_SURROUND_BINDKEY=s-prefix`：

- `sa"` - 为选中文本添加双引号
- `sd"` - 删除双引号
- `sr"'` - 将双引号改为单引号

#### 文本对象选择

- `vi"` - 选择引号内的文本对象
- `va"` - 选择引号及其内容
- `vi(` - 选择括号内的文本对象
- `va(` - 选择括号及其内容

**示例：**
```bash
vi" -> S[ 或 sa[  => "object" -> "[object]"
va" -> S[ 或 sa[  => "object" -> ["object"]
di( 或 vi( -> d   => 删除括号内的内容
ca( 或 va( -> c   => 修改括号及其内容
yi( 或 vi( -> y   => 复制括号内的内容
```

### 历史搜索

- `/` - 向后搜索历史
- `n` - 重复上一次搜索
- `CTRL-P` - 上一条历史命令
- `CTRL-N` - 下一条历史命令

### 数字增减

在 Normal 模式下：

- `CTRL-A` - 增加下一个关键词
- `CTRL-X` - 减少下一个关键词

支持的关键词类型：
- **数字**：十进制、十六进制、二进制等
- **布尔值**：`true`/`false`、`yes`/`no`、`on`/`off`
- **工作日**：`Sunday`、`Monday`、`Tuesday` 等
- **月份**：`January`、`February`、`March` 等
- **运算符**：`&&`、`||`、`++`、`--`、`==`、`!==`、`and`、`or` 等

**示例：**
```bash
9 => 10
aa99bb => aa100bb
true => false
yes => no
on => off
Monday => Tuesday
January => February
&& => ||
and => or
```

### 打开 URL/文件

在 Normal 模式下，使用 `gx` 打开光标下的 URL 或文件路径：

- 如果是 URL（`http://`、`https://`、`ftp://`、`file://`），会在默认浏览器中打开
- 如果是有效的文件或目录路径，会用系统默认应用程序打开

### 外部编辑器编辑

在 Normal 模式下，使用 `vv` 在外部编辑器中编辑当前命令行：

- 默认使用 `$EDITOR` 环境变量指定的编辑器
- 可以通过 `ZVM_VI_EDITOR` 选项自定义编辑器

### 重复命令

支持 vim 风格的重复命令：

- `10p` - 粘贴 10 次
- `4fa` - 向右移动到第 4 个 `a` 字符
- `3dw` - 删除 3 个单词

## 配置选项

### 自定义退出键

可以自定义退出键，例如使用 `jk` 或 `jj`：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 只在 Insert 模式下使用 jk 退出，其他模式仍使用默认 ESC
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# 或者在所有模式下都使用 jk
ZVM_VI_ESCAPE_BINDKEY=jk
```

可用的配置选项：
- `ZVM_VI_ESCAPE_BINDKEY` - 所有模式的退出键（默认：`^[` => ESC）
- `ZVM_VI_INSERT_ESCAPE_BINDKEY` - Insert 模式的退出键
- `ZVM_VI_VISUAL_ESCAPE_BINDKEY` - Visual 模式的退出键
- `ZVM_VI_OPPEND_ESCAPE_BINDKEY` - Operator Pending 模式的退出键

### 配置函数

使用 `zvm_config` 函数进行统一配置：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

function zvm_config() {
  # 设置初始模式为 Insert 模式
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  
  # 设置退出键为 jk
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
  
  # 设置环绕模式为 s-前缀模式
  ZVM_VI_SURROUND_BINDKEY=s-prefix
}
```

### 光标样式

自定义不同模式的光标样式：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 禁用光标样式功能
ZVM_CURSOR_STYLE_ENABLED=false

# 或者自定义光标样式
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM        # Insert 模式：光束
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK       # Normal 模式：方块
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE   # Visual 模式：下划线
```

支持的光标样式：
- `ZVM_CURSOR_BLOCK` - 方块
- `ZVM_CURSOR_UNDERLINE` - 下划线
- `ZVM_CURSOR_BEAM` - 光束
- `ZVM_CURSOR_BLINKING_BLOCK` - 闪烁方块
- `ZVM_CURSOR_BLINKING_UNDERLINE` - 闪烁下划线
- `ZVM_CURSOR_BLINKING_BEAM` - 闪烁光束

### 系统剪贴板集成

启用系统剪贴板集成（默认禁用）：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 启用系统剪贴板
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# 自定义复制/粘贴命令（可选）
# macOS
ZVM_CLIPBOARD_COPY_CMD='pbcopy'
ZVM_CLIPBOARD_PASTE_CMD='pbpaste'

# Linux (Wayland)
ZVM_CLIPBOARD_COPY_CMD='wl-copy'
ZVM_CLIPBOARD_PASTE_CMD='wl-paste -n'

# Linux (X11)
ZVM_CLIPBOARD_COPY_CMD='xclip -selection clipboard'
ZVM_CLIPBOARD_PASTE_CMD='xclip -selection clipboard -o'
```

**键绑定：**
- Normal 模式：`gp` 在光标后粘贴剪贴板，`gP` 在光标前粘贴
- Visual 模式：`gp`/`gP` 用剪贴板内容替换选中文本

**注意**：`p`/`P` 仍使用 ZLE 的 CUTBUFFER；`gp`/`gP` 使用系统剪贴板。

### 打开命令自定义

自定义 `gx` 打开 URL/文件的命令：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 覆盖默认打开命令
ZVM_OPEN_CMD='xdg-open'

# 分别设置 URL 和文件的打开命令
ZVM_OPEN_URL_CMD='firefox'                    # URL 用 Firefox 打开
ZVM_OPEN_FILE_CMD='code'                       # 文件用 VS Code 打开

# macOS 示例
ZVM_OPEN_URL_CMD='open -a "Safari"'
ZVM_OPEN_FILE_CMD='open -a "Visual Studio Code"'
```

### 外部编辑器设置

自定义 `vv` 使用的编辑器：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 使用 nvim 作为外部编辑器
ZVM_VI_EDITOR='nvim'
```

### 初始模式

设置命令行的初始模式：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 总是以 Insert 模式开始
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

# 总是以 Normal 模式开始
ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL

# 使用上次的模式（默认）
ZVM_LINE_INIT_MODE=$ZVM_MODE_LAST
```

### 高亮样式

自定义高亮样式（surround、visual-line 等）：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 前景色（颜色名或十六进制值）
ZVM_VI_HIGHLIGHT_FOREGROUND=green
ZVM_VI_HIGHLIGHT_FOREGROUND=#008800

# 背景色
ZVM_VI_HIGHLIGHT_BACKGROUND=red
ZVM_VI_HIGHLIGHT_BACKGROUND=#ff0000

# 额外样式（粗体、下划线等）
ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold,underline
```

### 延迟键绑定

默认启用延迟键绑定功能，可以提升启动速度。要禁用它：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加（必须在插件加载前设置）

ZVM_LAZY_KEYBINDINGS=false
```

### 键输入超时

调整键输入超时时间（默认 0.4 秒）：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

ZVM_KEYTIMEOUT=0.5  # 0.5 秒
```

### 读取键引擎

选择读取键引擎：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 使用 NEX 引擎（默认，Beta 版本，性能更好）
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_NEX

# 使用 Zsh 默认的 ZLE 引擎
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE

# 使用默认引擎（当前是 NEX）
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_DEFAULT
```

## 高级用法

### 自定义 Widget 和键绑定

定义自定义 widget 和键绑定：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 自定义 widget 函数
function my_custom_widget() {
  echo 'Hello, ZSH!'
}

# 在 zvm_after_lazy_keybindings 函数中定义
function zvm_after_lazy_keybindings() {
  # 定义自定义 widget
  zvm_define_widget my_custom_widget
  
  # 在 Normal 模式下，按 Ctrl-E 调用此 widget
  zvm_bindkey vicmd '^E' my_custom_widget
}
```

### 模式指示器

使用 `ZVM_MODE` 变量获取当前模式并显示指示器：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      # Normal 模式时的操作
      # 例如：更新提示符
    ;;
    $ZVM_MODE_INSERT)
      # Insert 模式时的操作
    ;;
    $ZVM_MODE_VISUAL)
      # Visual 模式时的操作
    ;;
    $ZVM_MODE_VISUAL_LINE)
      # Visual Line 模式时的操作
    ;;
    $ZVM_MODE_REPLACE)
      # Replace 模式时的操作
    ;;
  esac
}
```

### 执行额外命令

插件提供了多个钩子函数来执行额外命令：

```zsh
# 在 ~/.dotfiles/plugins/local/local.zsh 中添加

# 在插件初始化前执行
zvm_before_init_commands+=('echo "Before init"')

# 在插件初始化后执行
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

# 在延迟键绑定后执行（推荐用于自定义键绑定）
function zvm_after_lazy_keybindings() {
  # 自定义键绑定
  bindkey -M vicmd 's' your_normal_widget
  bindkey -M visual 'n' your_visual_widget
}
```

## 常用场景示例

### 场景 1：快速编辑命令行

1. 输入命令：`ls -la /home/user`
2. 按 `ESC` 进入 Normal 模式
3. 使用 `h`/`l` 移动光标到需要修改的位置
4. 按 `i` 进入 Insert 模式进行编辑
5. 编辑完成后按 `ESC` 返回 Normal 模式

### 场景 2：复制粘贴历史命令

1. 按 `/` 搜索历史命令
2. 输入关键字找到需要的命令
3. 按 `ESC` 进入 Normal 模式
4. 使用 `yy` 复制整行
5. 按 `Enter` 执行命令，或按 `p` 粘贴到当前命令行

### 场景 3：快速修改路径

1. 输入命令：`cd /home/user/documents`
2. 按 `ESC` 进入 Normal 模式
3. 使用 `f/` 快速跳转到下一个 `/`
4. 使用 `dw` 删除单词，或 `cw` 修改单词
5. 输入新路径后按 `ESC` 完成

### 场景 4：使用环绕功能修改引号

1. 输入命令：`echo "hello world"`
2. 按 `ESC` 进入 Normal 模式
3. 使用 `cs"'` 将双引号改为单引号：`echo 'hello world'`
4. 或使用 `ds"` 删除引号：`echo hello world`

### 场景 5：在外部编辑器中编辑长命令

1. 输入长命令
2. 按 `ESC` 进入 Normal 模式
3. 按 `vv` 在外部编辑器（如 nvim）中打开
4. 在编辑器中编辑完成后保存退出
5. 命令会自动回到命令行

## 故障排除

### 问题 1：键绑定不工作

**可能原因：**
- 插件加载顺序问题
- 与其他插件冲突

**解决方法：**
- 确保 `zsh-vi-mode` 在 `zsh-autosuggestions` 之前加载
- 检查 `local.zsh` 中是否有冲突的键绑定

### 问题 2：光标样式不显示

**可能原因：**
- 终端不支持光标样式
- 配置被禁用

**解决方法：**
```zsh
# 检查是否启用
ZVM_CURSOR_STYLE_ENABLED=true

# 设置终端类型
ZVM_TERM=xterm-256color  # 或其他支持的终端类型
```

### 问题 3：系统剪贴板不工作

**可能原因：**
- 未启用剪贴板集成
- 缺少必要的工具（`xclip`、`wl-copy` 等）

**解决方法：**
```zsh
# 启用剪贴板
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# 安装必要的工具（Ubuntu/Debian）
sudo apt-get install xclip  # X11
# 或
sudo apt-get install wl-clipboard  # Wayland
```

### 问题 4：与其他插件冲突

**解决方法：**
使用 `zvm_after_init_commands` 或 `zvm_after_lazy_keybindings` 钩子：

```zsh
# 在 local.zsh 中
function zvm_after_init() {
  # 重新加载其他插件的键绑定
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}
```

## 更多资源

- **官方仓库**：https://github.com/jeffreytse/zsh-vi-mode
- **官方文档**：https://github.com/jeffreytse/zsh-vi-mode#readme
- **问题反馈**：https://github.com/jeffreytse/zsh-vi-mode/issues

## 配置示例

完整的配置示例（`~/.dotfiles/plugins/local.zsh`）：

```zsh
# zsh-vi-mode 配置
function zvm_config() {
  # 初始模式：Insert
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  
  # 退出键：jk
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
  
  # 环绕模式：s-前缀模式
  ZVM_VI_SURROUND_BINDKEY=s-prefix
  
  # 光标样式
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  
  # 系统剪贴板（Linux X11）
  ZVM_SYSTEM_CLIPBOARD_ENABLED=true
  ZVM_CLIPBOARD_COPY_CMD='xclip -selection clipboard'
  ZVM_CLIPBOARD_PASTE_CMD='xclip -selection clipboard -o'
  
  # 外部编辑器
  ZVM_VI_EDITOR='nvim'
}

# 延迟键绑定后的自定义键绑定
function zvm_after_lazy_keybindings() {
  # 可以在这里添加自定义键绑定
  # zvm_bindkey vicmd '^E' my_custom_widget
}

# 模式切换后的操作
function zvm_after_select_vi_mode() {
  # 可以在这里更新提示符或其他 UI 元素
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      # Normal 模式
    ;;
    $ZVM_MODE_INSERT)
      # Insert 模式
    ;;
  esac
}
```

---

**最后更新**: 2025-01-XX

