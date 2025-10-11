
-- -------------------------------------------------------------------------- --
--  Theme setup: solarized (default), zenburn, habamax
-- -------------------------------------------------------------------------- --

-- Prevent double-loading this module (e.g., on :source or reload)
if vim.g.loaded_theme_module then return end
vim.g.loaded_theme_module = true

-- Utility: consistent notifications
local function notify(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "Theme" })
end

-- List your preferred themes in order
local themes = { "solarized", "zenburn", "habamax" }
local current_index = 1

-- Safely apply a colorscheme; fall back gracefully if missing
local function apply_colors(name)
  local ok = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify(("colorscheme '%s' not found; falling back"):format(name), vim.log.levels.WARN, { title = "Theme" })
    if not pcall(vim.cmd.colorscheme, "habamax") then
      pcall(vim.cmd.colorscheme, "default")
    end
  end
end

-- Default: Solarized Dark
vim.o.background = "dark"
apply_colors(themes[current_index])

-- Toggle background (dark ↔ light)
local function toggle_background()
  vim.o.background = (vim.o.background == "dark") and "light" or "dark"
  apply_colors(themes[current_index])
  notify("background=" .. vim.o.background)
end

-- Cycle to the next theme in the list
local function cycle_theme()
  current_index = (current_index % #themes) + 1
  apply_colors(themes[current_index])
  notify("theme=" .. themes[current_index] .. " (background=" .. vim.o.background .. ")")
end

-- Explicitly set a theme by name
local function set_theme(name)
  for i, th in ipairs(themes) do
    if th == name then current_index = i break end
  end
  apply_colors(name)
  notify("theme=" .. name .. " (background=" .. vim.o.background .. ")")
end

-- Keymaps
vim.keymap.set("n", "<leader>td", toggle_background, { desc = "Toggle dark/light background" })
vim.keymap.set("n", "<leader>th", cycle_theme,       { desc = "Cycle themes (solarized/zenburn/habamax)" })

-- User commands
vim.api.nvim_create_user_command("ThemeNext", cycle_theme, {})
vim.api.nvim_create_user_command("ThemeDark", function()
  vim.o.background = "dark"; apply_colors(themes[current_index])
end, {})
vim.api.nvim_create_user_command("ThemeLight", function()
  vim.o.background = "light"; apply_colors(themes[current_index])
end, {})
vim.api.nvim_create_user_command("Theme", function(opts)
  set_theme(opts.args)
end, {
  nargs = 1,
  complete = function() return themes end,
})
