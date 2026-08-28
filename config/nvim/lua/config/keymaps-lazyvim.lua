-- LazyVim default keymaps, ported to our pure lazy.nvim setup.
-- Source of truth: lazyvim/lazyvim/lua/lazyvim/config/keymaps.lua (main branch).
-- Only calls APIs that exist in our setup: snacks.nvim, gitsigns.nvim, vim
-- builtins. API substitutions for the removed LazyVim runtime:
--   * LazyVim.safe_keymap_set      -> vim.keymap.set
--   * LazyVim.root.git() / root()  -> Snacks.git.get_root()
--   * LazyVim.format.snacks_toggle -> Snacks.toggle({...}) (vim.g.autoformat)
--   * Snacks.toggle.relative_number (absent) -> Snacks.toggle.option(...)
--   * Snacks.toggle.formatexpr (absent)      -> Snacks.toggle({...})
--   * gitsigns <leader>g* hunk ops stay in plugins/gitsigns.lua (NOT here, to
--     avoid clobbering the user's working blame bindings on <leader>gb/<leader>gB)
-- Your own custom keymaps live in config/keymaps.lua and are untouched.

local map = vim.keymap.set

local git_root = function()
  return Snacks.git.get_root() or vim.uv.cwd()
end

------------------- Find / Search -------------------------------------------
-- Provided by snacks picker (our replacement for LazyVim's snacks defaults).
map("n", "<leader><space>", function() Snacks.picker.pick("files") end, { desc = "Find Files (Root Dir)" })
map("n", "<leader>ff", function() Snacks.picker.pick("files") end, { desc = "Find Files" })
map("n", "<leader>fF", function()
  local root = vim.fs.root(0, ".git")
  Snacks.picker.pick("files", { dirs = { root or vim.uv.cwd() } })
end, { desc = "Find Files (Git Root)" })
map("n", "<leader>fb", function() Snacks.picker.pick("buffers") end, { desc = "Buffers" })
map("n", "<leader>fr", function() Snacks.picker.pick("recent") end, { desc = "Recent" })
map("n", "<leader>fR", function() Snacks.picker.resume() end, { desc = "Resume" })
map("n", "<leader>fg", function() Snacks.picker.pick("grep") end, { desc = "Grep" })
map("n", "<leader>fG", function() Snacks.picker.pick("grep") end, { desc = "Grep (Root Dir)" })
map("n", "<leader>fw", function() Snacks.picker.pick("grep", { search = vim.fn.expand("<cword>") }) end, { desc = "Grep Word (cwd)" })
map("n", "<leader>fW", function() Snacks.picker.pick("grep", { search = vim.fn.expand("<cword>") }) end, { desc = "Grep Word (Root)" })
map("n", "<leader>fc", function() Snacks.picker.pick("grep", { search = vim.fn.expand("<cword>") }) end, { desc = "Word under Cursor" })
map("n", "<leader>fh", function() Snacks.picker.pick("help") end, { desc = "Help Pages" })
map("n", "<leader>fS", function() Snacks.picker.pick("treesitter") end, { desc = "Treesitter Symbols" })
map("n", "<leader>/", function() Snacks.picker.pick("grep") end, { desc = "Grep" })
map("n", "<leader>,", function() Snacks.picker.pick("buffers") end, { desc = "Switch Buffer" })
map("n", "<leader>?", function() Snacks.picker.pick("help") end, { desc = "Help" })

------------------- Better up/down -------------------------------------------
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

------------------- Move to window using <ctrl> hjkl -------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

------------------- Resize window using <ctrl> arrow keys --------------------
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

------------------- Move Lines -------------------------------------------------
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

------------------- Buffers ---------------------------------------------------
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bi", function() Snacks.bufdelete.invisible() end, { desc = "Delete Invisible Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
-- convenience (non-LazyVim) linear buffer navigation
map("n", "<leader>bl", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bh", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

------------------- Clear search on escape -----------------------------------
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

------------------- Redraw / Clear hlsearch / Diff Update --------------------
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / Clear hlsearch / Diff Update" })

------------------- saner n/N ------------------------------------------------
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

------------------- Add undo break-points -----------------------------------
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

------------------- save file -------------------------------------------------
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

------------------- keywordprg ------------------------------------------------
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

------------------- better indenting ------------------------------------------
map("x", "<", "<gv")
map("x", ">", ">gv")

------------------- lazy ------------------------------------------------------
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

------------------- new file --------------------------------------------------
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

------------------- location / quickfix list ---------------------------------
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

------------------- formatting -------------------------------------------------
map({ "n", "x" }, "<leader>cf", function()
  if vim.g.autoformat ~= false then
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format" })

------------------- diagnostic -------------------------------------------------
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

------------------- toggle options (<leader>u) -------------------------------
local function setup_snacks_keymaps()
if not Snacks then
  return
end
Snacks.toggle({
  name = "Auto Format",
  get = function() return vim.g.autoformat == nil or vim.g.autoformat end,
  set = function(v) vim.g.autoformat = v end,
}):map("<leader>uf")
Snacks.toggle({
  name = "Auto Format (Off)",
  get = function() return vim.g.autoformat == false end,
  set = function(v) vim.g.autoformat = not v end,
}):map("<leader>uF")
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
end

if Snacks then
  setup_snacks_keymaps()
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = setup_snacks_keymaps,
  })
end

------------------- lazygit ---------------------------------------------------
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit({ cwd = git_root() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
end
map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = git_root() }) end, { desc = "Git Log" })
map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
map({ "n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })

------------------- quit ------------------------------------------------------
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

------------------- highlights under cursor ----------------------------------
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })

------------------- floating terminal ----------------------------------------
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = git_root() }) end, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-/>", function() Snacks.terminal.focus(nil, { cwd = git_root() }) end, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-_>", function() Snacks.terminal.focus(nil, { cwd = git_root() }) end, { desc = "which_key_ignore" })

------------------- windows ---------------------------------------------------
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
map("n", "<leader>ww", "<c-w><c-w>", { desc = "Other Window" })
map("n", "<leader>wh", "<c-w>h", { desc = "Window Left" })
map("n", "<leader>wj", "<c-w>j", { desc = "Window Down" })
map("n", "<leader>wk", "<c-w>k", { desc = "Window Up" })
map("n", "<leader>wl", "<c-w>l", { desc = "Window Right" })
map("n", "<leader>wH", "<c-w>H", { desc = "Move Window Left" })
map("n", "<leader>wJ", "<c-w>J", { desc = "Move Window Down" })
map("n", "<leader>wK", "<c-w>K", { desc = "Move Window Up" })
map("n", "<leader>wL", "<c-w>L", { desc = "Move Window Right" })
map("n", "<leader>s|", "<cmd>vsplit<cr>", { desc = "Split Right" })
map("n", "<leader>s-", "<cmd>split<cr>", { desc = "Split Below" })
map("n", "<leader>uz", function() pcall(Snacks.zen.zoom) end, { desc = "Zen Mode" })

------------------- tabs ------------------------------------------------------
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
