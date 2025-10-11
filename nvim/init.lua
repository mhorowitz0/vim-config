
-- ========================================================================== --
--  init.lua
--  Bootstraps lazy.nvim, then loads plugins, core config, LSP, and theme
-- ========================================================================== --

-- Set leaders *before* lazy so key-based lazy-loading uses the right keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 0) Bootstrap lazy.nvim (auto-installs on first run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 1) Load plugin specs (lua/plugins.lua)
require("lazy").setup("plugins")

-- 2) Core options & keymaps
require("config")

-- 2.1) Ensure state dirs exist (undo/backup)
local state = vim.fn.stdpath("state")
vim.fn.mkdir(state .. "/undo", "p")
vim.fn.mkdir(state .. "/backup", "p")

-- 2.2) Warn once if ripgrep is missing (for live_grep)
if vim.fn.executable("rg") == 0 then
  vim.schedule(function()
    vim.notify("ripgrep (rg) not found; install it for live_grep", vim.log.levels.WARN)
  end)
end

-- 3) Treesitter, LSP, completion, etc.
require("lsp")

-- 4) Theme (Solarized Dark default; toggle & cycle supported)
require("theme")

-- ========================================================================== --
--  GitHub Copilot (classic Vim plugin)
-- ========================================================================== --
-- Using the original github/copilot.vim plugin for smoother CoC integration.
-- This disables Copilot’s default <Tab> mapping and binds:
--   • <C-]>   → Accept Copilot suggestion
--   • <C-\>   → Dismiss suggestion
-- ========================================================================== --

vim.g.copilot_hide_during_completion = 0
vim.cmd([[
  let g:copilot_no_tab_map = v:true
  imap <silent><script><expr> <C-]> copilot#Accept("\<CR>")
  imap <silent> <C-\> <Plug>(copilot-dismiss)
]])

-- ========================================================================== --
--  CoC: auto-install & keep my extensions
--  CoC will install any missing items here on startup and update them with
--  :CocUpdate. This replaces manual :CocInstall steps.
-- ========================================================================== --
vim.g.coc_global_extensions = {
  -- Core stack
  "coc-pyright",
  "@yaegassy/coc-ruff",
  "coc-json",
  "coc-yaml",
  "coc-tsserver",
  "coc-sh",

  -- Optional extras
  "coc-snippets",
  "coc-html",
  "coc-css",
  "coc-lua",
}
