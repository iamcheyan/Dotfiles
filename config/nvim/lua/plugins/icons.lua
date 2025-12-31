return {
  -- 1. 禁用 mini.icons，防止它拦截图标请求或进行错误的 ASCII 回退
  {
    "nvim-mini/mini.icons",
    enabled = false,
  },

  -- 2. 启用经典的 nvim-web-devicons
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      -- 全局开启彩色图标
      color_icons = true,
      -- 开启默认图标支持
      default = true,
      -- 显式强制深色模式（适配您的主题）
      variant = "dark",
      -- 针对特定文件后缀的图标修正（解决您看到的问号问题）
      override = {
        md = {
          icon = "",
          color = "#ffffff",
          name = "Markdown",
        },
        sh = {
          icon = "",
          color = "#428850",
          name = "Shell",
        },
        zsh = {
          icon = "",
          color = "#428850",
          name = "Zsh",
        },
      },
    },
  },
}
