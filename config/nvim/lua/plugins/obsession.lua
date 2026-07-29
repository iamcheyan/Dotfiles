return {
  {
    "tpope/vim-obsession",
    -- 启动时如果当前目录有 Session.vim，自动加载（tmux-persist 用 nvim -S 恢复，
    -- 但直接手动启动 nvim 时也能自动恢复）
    init = function()
      -- 只在没有打开文件的情况下自动恢复（避免覆盖命令行指定的文件）
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
          -- 没有带文件参数启动，且当前目录有 Session.vim
          if vim.fn.argc() == 0 and vim.fn.filereadable("Session.vim") == 1 then
            vim.cmd("source Session.vim")
          end
        end,
      })
    end,
  },
}
