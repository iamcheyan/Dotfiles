-- ============================================
-- Keymaps Configuration
-- ============================================

-- Define common options
local opts = {
  noremap = true, -- non-recursive
  silent = true,  -- do not show message
}

-- Options for keymaps that don't need noremap
local silent_opts = {
  silent = true,
}

-- ============================================
-- Normal Mode Keymaps
-- ============================================

-- Window Navigation
-- Better window navigation using Ctrl + h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Window Resize
-- Resize windows with arrow keys (delta: 2 lines)
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- File Tree
-- Toggle nvim-tree (default leader key: Space)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Terminal
-- Open terminal in split windows
vim.keymap.set("n", "<leader>tr", function()
  vim.cmd("vsplit | terminal")
end, { desc = "Terminal Right" })

vim.keymap.set("n", "<leader>tb", function()
  vim.cmd("split | terminal")
end, { desc = "Terminal Bottom" })

-- File Operations
-- Save file
vim.keymap.set("n", "<C-s>", ":w<CR>", silent_opts)

-- Open file
vim.keymap.set("n", "<C-o>", ":e<CR>", silent_opts)

-- New file
vim.keymap.set("n", "<C-n>", ":enew<CR>", silent_opts)

-- Close current window
vim.keymap.set("n", "<C-w>", ":q<CR>", silent_opts)

-- Quit without saving
vim.keymap.set("n", "<C-q>", ":q!<CR>", silent_opts)

-- Tab Operations
-- Open new tab
vim.keymap.set("n", "<C-t>", ":tabnew<CR>", silent_opts)

-- Buffer Operations
-- Next buffer
vim.keymap.set("n", "<C-f>", ":bnext<CR>", silent_opts)

-- Previous buffer
vim.keymap.set("n", "<C-b>", ":bprevious<CR>", silent_opts)

-- Undo/Redo
-- Undo
vim.keymap.set("n", "<C-z>", "u", silent_opts)

-- Redo
vim.keymap.set("n", "<C-y>", "<C-r>", silent_opts)

-- Copy/Paste
-- Paste from system clipboard
vim.keymap.set("n", "<C-v>", '"+p', silent_opts)

-- Comment Toggle
-- Toggle comment on current line or selected lines
vim.keymap.set("n", "<C-/>", ":CommentToggle<CR>", silent_opts)

-- ============================================
-- Visual Mode Keymaps
-- ============================================

-- Indentation
-- Keep selection after indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Copy/Cut to System Clipboard
-- Copy to system clipboard
vim.keymap.set("v", "<C-c>", '"+y', silent_opts)

-- Cut to system clipboard
vim.keymap.set("v", "<C-x>", '"+d', silent_opts)
