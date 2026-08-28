-- Omarchy owns the generated theme file; the public config only opts into it
-- when running on an Omarchy system.
local theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(theme_file) == 1 then
  local ok, specs = pcall(dofile, theme_file)
  if ok and type(specs) == "table" then
    return specs
  end
end

return {}
