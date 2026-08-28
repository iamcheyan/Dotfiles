-- nvim/lua/lazy.lua

-- Set leader keys before lazy.nvim loads. lazy.nvim warns (and <leader>
-- mappings created by plugins would bind to the wrong key) if these aren't
-- set first. Values match LazyVim's defaults (lazyvim/config/options.lua).
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load our options early (previously done by LazyVim's config.init()).
require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Optional private extensions are kept outside the public dotfiles tree.
local private_nvim = vim.fn.expand("~/.config/nvim-private")
local spec = { { import = "plugins" } }
local private_spec_file = private_nvim .. "/lua/plugins/vimquest.lua"
if vim.fn.filereadable(private_spec_file) == 1 then
  local ok, private_specs = pcall(dofile, private_spec_file)
  if ok and type(private_specs) == "table" then
    if private_specs[1] ~= nil then
      vim.list_extend(spec, private_specs)
    else
      table.insert(spec, private_specs)
    end
  end
end

-- Register the "LazyFile" pseudo-event so plugin specs using
-- `event = "LazyFile"` keep working. Mirrors LazyVim's original registration.
local Event = require("lazy.core.handler.event")
Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local function ensure_lockfile(path)
  local dir = vim.fn.fnamemodify(path, ":p:h")
  vim.fn.mkdir(dir, "p")
  if vim.fn.filereadable(path) == 0 then
    pcall(vim.fn.writefile, { "{}" }, path)
  end
  return path
end

local lockfile = ensure_lockfile(vim.fn.stdpath("config") .. "/lazy-lock.json")
if vim.fn.filewritable(lockfile) ~= 1 then
  lockfile = ensure_lockfile(vim.fn.stdpath("state") .. "/lazy-lock.json")
end

require("lazy").setup({
  -- Import public plugins and append the optional private layer.
  spec = spec,
  -- Force a concrete lockfile path to avoid nil/invalid values
  lockfile = lockfile,
  -- Don't open lockfile on startup
  open = false,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "single",
  },
})

-- LazyVim's default <leader> keymaps (find/buffers/git/windows/UI/quit...),
-- ported to our plugins (snacks picker, gitsigns, vim builtins).
require("config.keymaps-lazyvim")
-- Load personal keymaps last so they intentionally override compatibility
-- mappings when the same lhs is used.
require("config.keymaps")
require("config.autocmds")
