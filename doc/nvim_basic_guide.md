# Neovim 基本操作指南 / Basic Neovim Guide / Neovim基本操作ガイド

> **多语言互动教程 / Multilingual Interactive Tutorial / 多言語インタラクティブチュートリアル**

このガイドは、Neovim の基本操作を学ぶための実践的なチュートリアルです。
This guide is a practical tutorial for learning basic Neovim operations.
---


## 🎯 移动操作 / Movement / 移動操作

### 基础移动 / Basic Movement / 基本移動

#### 字符移动 / Character Movement / 文字移動

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `h` | 左移 / Move left / 左へ移動 | 向左移动一个字符 |
| `l` | 右移 / Move right / 右へ移動 | 向右移动一个字符 |
| `j` | 下移 / Move down / 下へ移動 | 向下移动一行 |
| `k` | 上移 / Move up / 上へ移動 | 向上移动一行 |

**练习 / Practice / 練習：**
1. 使用 `h`, `j`, `k`, `l` 在文本中移动
2. Use `h`, `j`, `k`, `l` to move around the text
3. `h`, `j`, `k`, `l`を使ってテキスト内を移動する

#### 单词移动 / Word Movement / 単語移動

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `w` | 下一个单词开头 / Next word start / 次の単語の先頭 | 移动到下一个单词的开头 |
| `e` | 单词末尾 / Word end / 単語の末尾 | 移动到当前或下一个单词的末尾 |
| `b` | 上一个单词开头 / Previous word start / 前の単語の先頭 | 移动到上一个单词的开头 |
| `W` | 下一个大单词 / Next WORD / 次のWORD | 忽略标点符号 |
| `E` | 大单词末尾 / WORD end / WORDの末尾 | 忽略标点符号 |
| `B` | 上一个大单词 / Previous WORD / 前のWORD | 忽略标点符号 |

**练习 / Practice / 練習：**
在文本中尝试使用 `w`, `e`, `b` 快速移动
Try using `w`, `e`, `b` to move quickly in the text
テキスト内で`w`, `e`, `b`を使って素早く移動してみる

#### 行移动 / Line Movement / 行移動

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `0` | 行首 / Line start / 行の先頭 | 移动到当前行的开头 |
| `^` | 行首非空白 / Line start (non-blank) / 行の先頭（空白以外） | 移动到第一个非空白字符 |
| `$` | 行尾 / Line end / 行の末尾 | 移动到当前行的末尾 |
| `g_` | 行尾非空白 / Line end (non-blank) / 行の末尾（空白以外） | 移动到最后一个非空白字符 |

**练习 / Practice / 練習：**
1. 使用 `0` 和 `$` 在行首和行尾之间移动
2. Use `0` and `$` to move between line start and end
3. `0`と`$`を使って行の先頭と末尾の間を移動する

#### 文档移动 / Document Movement / 文書移動

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `gg` | 文档开头 / Document start / 文書の先頭 | 移动到文档的第一行 |
| `G` | 文档末尾 / Document end / 文書の末尾 | 移动到文档的最后一行 |
| `{数字}G` | 跳转到指定行 / Go to line number / 指定行へ移動 | 例如 `5G` 跳转到第5行 |
| `Ctrl+f` | 向下翻页 / Page down / ページダウン | 向前翻一页 |
| `Ctrl+b` | 向上翻页 / Page up / ページアップ | 向后翻一页 |
| `Ctrl+d` | 向下半页 / Half page down / 半ページダウン | 向下滚动半页 |
| `Ctrl+u` | 向上半页 / Half page up / 半ページアップ | 向上滚动半页 |

**练习 / Practice / 練習：**
1. 使用 `gg` 跳转到文档开头
2. 使用 `G` 跳转到文档末尾
3. 使用 `5G` 跳转到第5行
4. Use `gg` to go to document start
5. Use `G` to go to document end
6. Use `5G` to go to line 5
7. `gg`で文書の先頭へ移動
8. `G`で文書の末尾へ移動
9. `5G`で5行目へ移動

---

## ✏️ 编辑操作 / Editing / 編集操作

### 插入文本 / Insert Text / テキスト挿入

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `i` | 当前位置插入 / Insert at cursor / カーソル位置に挿入 | 在光标前插入 |
| `a` | 光标后插入 / Insert after cursor / カーソルの後に挿入 | 在光标后插入 |
| `I` | 行首插入 / Insert at line start / 行の先頭に挿入 | 在行首非空白字符前插入 |
| `A` | 行尾插入 / Insert at line end / 行の末尾に挿入 | 在行尾插入 |
| `o` | 下一行插入 / Insert new line below / 次の行に挿入 | 在当前行下方插入新行 |
| `O` | 上一行插入 / Insert new line above / 前の行に挿入 | 在当前行上方插入新行 |

**练习 / Practice / 練習：**
1. 将光标移动到任意位置，按 `i` 开始输入
2. 按 `a` 在光标后输入
3. 按 `I` 在行首输入
4. 按 `A` 在行尾输入
5. 按 `o` 在下方插入新行
6. Move cursor and press `i` to start typing
7. Press `a` to insert after cursor
8. Press `I` to insert at line start
9. Press `A` to insert at line end
10. Press `o` to insert new line below
11. カーソルを移動して`i`を押して入力開始
12. `a`を押してカーソルの後に挿入
13. `I`を押して行の先頭に挿入
14. `A`を押して行の末尾に挿入
15. `o`を押して下に新しい行を挿入

### 删除操作 / Delete Operations / 削除操作

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `x` | 删除字符 / Delete character / 文字削除 | 删除光标下的字符 |
| `X` | 删除前一个字符 / Delete previous character / 前の文字削除 | 删除光标前的字符 |
| `dw` | 删除单词 / Delete word / 単語削除 | 删除从光标到单词末尾 |
| `diw` | 删除整个单词 / Delete inner word / 単語全体削除 | 删除整个单词（包括周围空格） |
| `dd` | 删除整行 / Delete line / 行削除 | 删除当前行 |
| `D` | 删除到行尾 / Delete to line end / 行末まで削除 | 删除从光标到行尾 |
| `d$` | 删除到行尾 / Delete to line end / 行末まで削除 | 同 `D` |
| `d0` | 删除到行首 / Delete to line start / 行頭まで削除 | 删除从光标到行首 |

**练习 / Practice / 練習：**
在以下文本中练习删除操作：
Practice delete operations on the following text:
以下のテキストで削除操作を練習する：

```
Hello, this is a test file.
こんにちは、これはテストファイルです。
你好，这是一个测试文件。
```

1. 使用 `x` 删除单个字符
2. 使用 `dw` 删除单词
3. 使用 `dd` 删除整行
4. Use `x` to delete single character
5. Use `dw` to delete word
6. Use `dd` to delete entire line
7. `x`で1文字削除
8. `dw`で単語削除
9. `dd`で行全体削除

### 复制和粘贴 / Copy and Paste / コピーとペースト

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `yy` | 复制整行 / Yank line / 行をヤンク | 复制当前行 |
| `yw` | 复制单词 / Yank word / 単語をヤンク | 复制从光标到单词末尾 |
| `y$` | 复制到行尾 / Yank to line end / 行末までヤンク | 复制从光标到行尾 |
| `y0` | 复制到行首 / Yank to line start / 行頭までヤンク | 复制从光标到行首 |
| `p` | 粘贴 / Paste / ペースト | 在光标后粘贴 |
| `P` | 粘贴在前 / Paste before / 前にペースト | 在光标前粘贴 |

**练习 / Practice / 練習：**
1. 使用 `yy` 复制一行
2. 移动到其他位置，按 `p` 粘贴
3. 使用 `yw` 复制一个单词并粘贴
4. Use `yy` to copy a line
5. Move to another position and press `p` to paste
6. Use `yw` to copy a word and paste it
7. `yy`で行をコピー
8. 他の位置に移動して`p`でペースト
9. `yw`で単語をコピーしてペースト

---

## 🔄 替换操作 / Replacement / 置換操作

### 字符替换 / Character Replacement / 文字置換

| 按键 | 功能 / Function / 機能 | 说明 / Description / 説明 |
|------|----------------------|-------------------------|
| `r` | 替换单个字符 / Replace character / 文字置換 | 替换光标下的字符 |
| `R` | 进入替换模式 / Replace mode / 置換モード | 连续替换多个字符 |
| `s` | 删除并插入 / Substitute / 置換 | 删除字符并进入插入模式 |
| `S` | 删除整行并插入 / Substitute line / 行置換 | 删除整行并进入插入模式 |
| `cc` | 删除行并插入 / Change line / 行変更 | 删除整行并进入插入模式（同 `S`） |
| `cw` | 删除单词并插入 / Change word / 単語変更 | 删除单词并进入插入模式 |

**练习 / Practice / 練習：**
在以下文本中练习：
Practice on the following text:
以下のテキストで練習する：

```
Replace this text.
このテキストを置き換える。
替换这段文本。
```

1. 将光标放在 "Replace" 上，按 `r` 然后输入 `C`，将 R 替换为 C
2. 将光标放在 "this" 上，按 `cw` 然后输入 `that`
3. Place cursor on "Replace", press `r` then type `C` to replace R with C
4. Place cursor on "this", press `cw` then type `that`
5. "Replace"の上にカーソルを置き、`r`を押して`C`を入力し、RをCに置換
6. "this"の上にカーソルを置き、`cw`を押して`that`を入力

### 标点符号替换 / Punctuation Replacement / 句読点置換

**这是一个非常重要的技巧！/ This is a very important skill! / これは非常に重要なスキルです！**

#### 替换引号 / Replace Quotes / 引用符置換

**场景 / Scenario / シナリオ：** 将单引号替换为双引号 / Replace single quotes with double quotes / シングルクォートをダブルクォートに置換

**方法 1：使用查找替换 / Method 1: Find and Replace / 方法1：検索置換**

1. 按 `:` 进入命令模式 / Press `:` to enter command mode / `:`を押してコマンドモードに入る
2. 输入以下命令 / Type the following command / 以下のコマンドを入力：

```vim
:%s/'/"/g
```

**解释 / Explanation / 説明：**
- `%` - 整个文件 / entire file / ファイル全体
- `s` - 替换命令 / substitute command / 置換コマンド
- `'` - 查找单引号 / find single quote / シングルクォートを検索
- `"` - 替换为双引号 / replace with double quote / ダブルクォートに置換
- `g` - 全局替换 / global (all occurrences) / グローバル（すべての出現）

**方法 2：使用可视模式 / Method 2: Visual Mode / 方法2：ビジュアルモード**

1. 按 `v` 进入可视模式 / Press `v` to enter visual mode / `v`を押してビジュアルモードに入る
2. 选择包含引号的文本 / Select text with quotes / 引用符を含むテキストを選択
3. 按 `:` 自动输入 `:'<,'>` / Press `:` to auto-enter `:'<,'>` / `:`を押して自動入力`:'<,'>`
4. 输入 `s/'/"/g` / Type `s/'/"/g` / `s/'/"/g`を入力

**练习文本 / Practice Text / 練習テキスト：**

```
'Hello' and 'World'
'こんにちは' と '世界'
'你好' 和 '世界'
```

**练习步骤 / Practice Steps / 練習手順：**

1. 将上述文本输入到 Neovim 中
2. 按 `Esc` 确保在 Normal Mode
3. 按 `:` 进入命令模式
4. 输入 `:%s/'/"/g` 并按 `Enter`
5. 观察所有单引号都被替换为双引号
6. Type the text above in Neovim
7. Press `Esc` to ensure Normal Mode
8. Press `:` to enter command mode
9. Type `:%s/'/"/g` and press `Enter`
10. Observe all single quotes replaced with double quotes
11. 上記のテキストをNeovimに入力
12. `Esc`を押してNormal Modeを確認
13. `:`を押してコマンドモードに入る
14. `:%s/'/"/g`を入力して`Enter`を押す
15. すべてのシングルクォートがダブルクォートに置換されることを確認

#### 替换其他标点 / Replace Other Punctuation / 他の句読点置換

**替换逗号为分号 / Replace comma with semicolon / カンマをセミコロンに置換：**

```vim
:%s/,/;/g
```

**替换句号为感叹号 / Replace period with exclamation / ピリオドを感嘆符に置換：**

```vim
:%s/\./!/g
```

**注意：** 句号 `.` 需要转义为 `\.` / Note: Period `.` needs to be escaped as `\.` / 注意：ピリオド`.`は`\.`としてエスケープが必要

**替换中文标点 / Replace Chinese punctuation / 中国語の句読点置換：**

```vim
:%s/，/,/g    " 中文逗号替换为英文逗号
:%s/。/./g    " 中文句号替换为英文句号
```

**练习文本 / Practice Text / 練習テキスト：**

```
Hello, world. This is a test, and it works.
こんにちは、世界。これはテストです、そして動作します。
你好，世界。这是一个测试，它有效。
```

**练习 / Practice / 練習：**

1. 将逗号替换为分号：`:%s/,/;/g`
2. 将句号替换为感叹号：`:%s/\./!/g`
3. Replace comma with semicolon: `:%s/,/;/g`
4. Replace period with exclamation: `:%s/\./!/g`
5. カンマをセミコロンに置換：`:%s/,/;/g`
6. ピリオドを感嘆符に置換：`:%s/\./!/g`

### 高级替换技巧 / Advanced Replacement / 上級置換テクニック

#### 确认替换 / Confirm Replacement / 確認置換

在替换命令后添加 `c` 可以逐个确认：
Add `c` after the replace command to confirm one by one:
置換コマンドの後に`c`を追加すると、1つずつ確認できます：

```vim
:%s/'/"/gc
```

**提示信息 / Prompt / プロンプト：**
- `y` - 替换 / replace / 置換
- `n` - 跳过 / skip / スキップ
- `a` - 全部替换 / replace all / すべて置換
- `q` - 退出 / quit / 終了

#### 仅替换单词 / Replace Word Only / 単語のみ置換

使用单词边界 `\<` 和 `\>`：
Use word boundaries `\<` and `\>`:
単語境界`\<`と`\>`を使用：

```vim
:%s/\<hello\>/world/g
```

这只会替换完整的单词 "hello"，不会替换 "hello123" 中的 "hello"
This only replaces the complete word "hello", not "hello" in "hello123"
これは完全な単語"hello"のみを置換し、"hello123"の"hello"は置換しません

#### 使用正则表达式 / Use Regular Expressions / 正規表現を使用

**替换多个空格为单个空格 / Replace multiple spaces with single space / 複数のスペースを1つのスペースに置換：**

```vim
:%s/  \+/ /g
```

**替换行尾空格 / Replace trailing spaces / 行末のスペースを置換：**

```vim
:%s/\s\+$//g
```

**练习文本 / Practice Text / 練習テキスト：**

```
This    has    multiple    spaces.
これには    複数の    スペースが    あります。
这有    多个    空格。
```

**练习 / Practice / 練習：**

1. 替换多个空格：`:%s/  \+/ /g`
2. Replace multiple spaces: `:%s/  \+/ /g`
3. 複数のスペースを置換：`:%s/  \+/ /g`

---

## 🎨 高级技巧 / Advanced Tips / 上級テクニック

### 组合操作 / Combining Operations / 操作の組み合わせ

**删除并进入插入模式 / Delete and enter insert mode / 削除して挿入モードに入る：**

| 按键 | 功能 / Function / 機能 |
|------|----------------------|
| `ci"` | 删除引号内的内容并插入 / Delete content inside quotes and insert / 引用符内の内容を削除して挿入 |
| `ci(` | 删除括号内的内容并插入 / Delete content inside parentheses and insert / 括弧内の内容を削除して挿入 |
| `ci[` | 删除方括号内的内容并插入 / Delete content inside brackets and insert / 角括弧内の内容を削除して挿入 |
| `ci{` | 删除花括号内的内容并插入 / Delete content inside braces and insert / 波括弧内の内容を削除して挿入 |
| `cit` | 删除标签内的内容并插入 / Delete content inside tags and insert / タグ内の内容を削除して挿入 |

**练习文本 / Practice Text / 練習テキスト：**

```
"Hello World"
(Test Content)
[Array Item]
{Object Key}
```

**练习 / Practice / 練習：**

1. 将光标放在引号内的任意位置
2. 按 `ci"` 删除引号内的内容
3. 输入新内容，按 `Esc` 完成
4. Place cursor anywhere inside quotes
5. Press `ci"` to delete content inside quotes
6. Type new content, press `Esc` to finish
7. 引用符内の任意の位置にカーソルを置く
8. `ci"`を押して引用符内の内容を削除
9. 新しい内容を入力し、`Esc`で完了

### 文本对象 / Text Objects / テキストオブジェクト

| 按键 | 功能 / Function / 機能 |
|------|----------------------|
| `diw` | 删除整个单词 / Delete inner word / 単語全体を削除 |
| `daw` | 删除单词及空格 / Delete a word with space / 単語とスペースを削除 |
| `ciw` | 删除单词并插入 / Change inner word / 単語を削除して挿入 |
| `yiw` | 复制单词 / Yank inner word / 単語をヤンク |
| `viw` | 选择单词 / Visual select word / 単語を選択 |

### 重复操作 / Repeat Operations / 操作の繰り返し

| 按键 | 功能 / Function / 機能 |
|------|----------------------|
| `.` | 重复上次操作 / Repeat last operation / 最後の操作を繰り返し |
| `@:` | 重复上次命令 / Repeat last command / 最後のコマンドを繰り返し |

**练习 / Practice / 練習：**

1. 使用 `dd` 删除一行
2. 按 `.` 重复删除操作
3. Use `dd` to delete a line
4. Press `.` to repeat the delete operation
5. `dd`で行を削除
6. `.`を押して削除操作を繰り返す

### 撤销和重做 / Undo and Redo / 元に戻すとやり直し

| 按键 | 功能 / Function / 機能 |
|------|----------------------|
| `u` | 撤销 / Undo / 元に戻す |
| `Ctrl+r` | 重做 / Redo / やり直し |
| `U` | 撤销整行 / Undo line / 行を元に戻す |

---

## 📝 综合练习 / Comprehensive Practice / 総合練習

### 练习任务 1：文本清理 / Practice Task 1: Text Cleanup / 練習タスク1：テキストクリーンアップ

**目标 / Goal / 目標：** 清理以下文本，替换所有标点符号
Clean up the following text, replace all punctuation
以下のテキストをクリーンアップし、すべての句読点を置換する

**原始文本 / Original Text / 元のテキスト：**

```
'Hello', 'World'!
This is a test, and it works.
こんにちは、世界。
你好，世界。
```

**任务 / Tasks / タスク：**

1. 将单引号替换为双引号：`:%s/'/"/g`
2. 将逗号替换为分号：`:%s/,/;/g`
3. 将句号替换为感叹号：`:%s/\./!/g`
4. Replace single quotes with double quotes: `:%s/'/"/g`
5. Replace commas with semicolons: `:%s/,/;/g`
6. Replace periods with exclamation: `:%s/\./!/g`
7. シングルクォートをダブルクォートに置換：`:%s/'/"/g`
8. カンマをセミコロンに置換：`:%s/,/;/g`
9. ピリオドを感嘆符に置換：`:%s/\./!/g`

**预期结果 / Expected Result / 期待される結果：**

```
"Hello"; "World"!
This is a test; and it works.
こんにちは;世界!
你好;世界!
```

### 练习任务 2：引号替换 / Practice Task 2: Quote Replacement / 練習タスク2：引用符置換

**目标 / Goal / 目標：** 将中文引号替换为英文引号
Replace Chinese quotes with English quotes
中国語の引用符を英語の引用符に置換する

**原始文本 / Original Text / 元のテキスト：**

```
「这是中文引号」
『这也是中文引号』
```

**任务 / Tasks / タスク：**

1. 替换左引号：`:%s/「/"/g` 和 `:%s/『/"/g`
2. 替换右引号：`:%s/」/"/g` 和 `:%s/』/"/g`
3. Replace left quotes: `:%s/「/"/g` and `:%s/『/"/g`
4. Replace right quotes: `:%s/」/"/g` and `:%s/』/"/g`
5. 左引用符を置換：`:%s/「/"/g`と`:%s/『/"/g`
6. 右引用符を置換：`:%s/」/"/g`と`:%s/』/"/g`

### 练习任务 3：快速编辑 / Practice Task 3: Quick Editing / 練習タスク3：クイック編集

**目标 / Goal / 目標：** 使用组合操作快速编辑
Use combined operations for quick editing
組み合わせ操作で素早く編集する

**原始文本 / Original Text / 元のテキスト：**

```
function test() {
    return "old value";
}
```

**任务 / Tasks / タスク：**

1. 将光标放在 "old value" 上
2. 按 `ci"` 删除引号内的内容
3. 输入 "new value"
4. 按 `Esc` 完成
5. Place cursor on "old value"
6. Press `ci"` to delete content inside quotes
7. Type "new value"
8. Press `Esc` to finish
9. "old value"の上にカーソルを置く
10. `ci"`を押して引用符内の内容を削除
11. "new value"を入力
12. `Esc`で完了

---

## 🎓 总结 / Summary / まとめ

### 核心概念 / Core Concepts / コアコンセプト

1. **Normal Mode 是基础 / Normal Mode is the foundation / Normal Modeが基礎**
   - 大部分操作都在 Normal Mode 进行
   - Most operations happen in Normal Mode
   - ほとんどの操作はNormal Modeで行う

2. **移动 + 操作 = 高效 / Movement + Operation = Efficiency / 移動 + 操作 = 効率**
   - 先移动到目标位置，再执行操作
   - Move to target first, then execute operation
   - まず目標位置に移動し、その後操作を実行

3. **组合键更强大 / Combined keys are more powerful / 組み合わせキーがより強力**
   - `ci"`, `diw`, `yiw` 等组合操作
   - Combined operations like `ci"`, `diw`, `yiw`
   - `ci"`, `diw`, `yiw`などの組み合わせ操作

4. **命令模式处理批量操作 / Command mode for batch operations / コマンドモードでバッチ操作**
   - 使用 `:%s/` 进行查找替换
   - Use `:%s/` for find and replace
   - `:%s/`で検索置換を行う

### 常用命令速查 / Quick Reference / クイックリファレンス

| 操作 | 命令 | 说明 |
|------|------|------|
| 替换引号 | `:%s/'/"/g` | 单引号→双引号 |
| 替换标点 | `:%s/,/;/g` | 逗号→分号 |
| 删除引号内容 | `ci"` | 删除并插入 |
| 删除单词 | `diw` | 删除整个单词 |
| 复制行 | `yy` | 复制当前行 |
| 粘贴 | `p` | 在光标后粘贴 |

---

## 🚀 下一步 / Next Steps / 次のステップ

### 推荐学习资源 / Recommended Resources / おすすめの学習リソース

1. **Vim Tutor / Vimチュートリアル**
   ```bash
   vimtutor
   ```
   在终端运行此命令开始交互式教程
   Run this command in terminal to start interactive tutorial
   ターミナルでこのコマンドを実行してインタラクティブチュートリアルを開始

2. **实践练习 / Practice / 実践練習**
   - 每天使用 Neovim 编辑文件
   - Use Neovim to edit files daily
   - 毎日Neovimでファイルを編集する

3. **自定义配置 / Customize Configuration / 設定をカスタマイズ**
   - 学习配置 `init.vim` 或 `init.lua`
   - Learn to configure `init.vim` or `init.lua`
   - `init.vim`または`init.lua`の設定を学ぶ

---

**祝学习愉快！/ Happy Learning! / 楽しい学習を！**

**记住：熟能生巧 / Remember: Practice makes perfect / 覚えておく：習うより慣れろ**

---

*最后更新 / Last Updated / 最終更新: 2025-01-XX*

