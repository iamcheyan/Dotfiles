-- VimQuest is a private chezmoi-managed plugin.
-- Keep the public Neovim config usable without ~/chezmoi.
local vimquest_dir = vim.fn.stdpath("config") .. "/lua/vimquest"

return {
  dir = vim.fn.stdpath("config"),
  name = "VimQuest.nvim",
  enabled = vim.fn.isdirectory(vimquest_dir) == 1,
  cmd = { "VimQuestStart", "VimQuestStop", "VimQuestNext", "VimQuestPrev", "VimQuestNextRound" },
  config = function()
    require("vimquest").setup()
  end,
}
