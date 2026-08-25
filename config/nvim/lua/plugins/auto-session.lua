return {
  {
    "rmagatti/auto-session",
    enabled = true,
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      -- 自动保存和恢复
      enabled = true,
      auto_save = true,
      auto_restore = true,
      auto_create = true,
      auto_restore_last_session = false,

      -- 不自动保存的目录
      suppressed_dirs = { "/", "~/.cache/*" },

      -- 忽略 dashboard 等文件类型
      bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },

      -- Git 支持
      git_use_branch_name = false,
      git_auto_restore_on_branch_change = false,

      -- 关闭不支持自动保存的窗口
      close_unsupported_windows = true,

      -- 空会话自动删除
      auto_delete_empty_sessions = true,

      -- session_lens 配置（会话选择器）
      session_lens = {
        picker = nil, -- 自动检测 telescope/snacks/fzf
        load_on_setup = true,
        shorten_paths = true,
        mappings = {
          delete_session = { "i", "<C-d>" },
          alternate_session = { "i", "<C-s>" },
          copy_session = { "i", "<C-y>" },
        },
      },

      -- 日志级别
      log_level = "error",
    },

    -- 推荐设置 sessionoptions
    init = function()
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,

    -- 快捷键
    keys = {
      { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
      { "<leader>ws", "<cmd>AutoSession save<CR>", desc = "Save session" },
      { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
      { "<leader>wd", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
    },
  },
}
