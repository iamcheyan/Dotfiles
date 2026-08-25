-- 私有个人插件：只由 chezmoi 部署，不进入公开 dotfiles。
return {
  dir = vim.fn.stdpath("config"),
  name = "VimQuest.nvim",
  cmd = {
    "VimQuestStart",
    "VimQuestStop",
    "VimQuestNext",
    "VimQuestPrev",
    "VimQuestNextRound",
  },
  config = function()
    require("vimquest").setup()
  end,
}
