
-- ========================================================================== --
--  Neovim Configuration (config.lua)
--  Mirrors your classic Vim setup with modern Neovim bits
-- ========================================================================== --

-- ========================================================================== --
--  Core Settings (ordered)
-- ========================================================================== --

local o, wo = vim.o, vim.wo

-- Appearance & UI
o.termguicolors = true
o.number = true
wo.relativenumber = false
wo.signcolumn = "yes"

-- Enable mouse support (clickable bufferline tabs, etc.)
vim.opt.mouse = "a"

-- Search behavior
o.ignorecase = true
o.smartcase  = true
o.incsearch  = true
o.hlsearch   = true

-- Window splits
o.splitbelow = true
o.splitright = true

-- Indentation & tabs
o.tabstop      = 4
o.shiftwidth   = 4
o.softtabstop  = 4
o.expandtab    = true
o.smartindent = true

-- Clipboard (pick your preference; uncomment ONE)
vim.opt.clipboard = "unnamed"      -- matches what you preferred in Vim
-- vim.opt.clipboard = "unnamedplus"  -- full OS clipboard for all yanks/puts

-- Performance
o.updatetime = 200

-- ========================================================================== --
--  Editing Safety & File History
-- ========================================================================== --

-- No .swp clutter
o.swapfile = false

-- Persistent undo (modern safety)
o.undofile = true
o.undodir  = vim.fn.stdpath("state") .. "/undo"   -- ~/.local/state/nvim/undo

-- Optional backups (pre-write snapshots). Keep them out of your projects.
o.backup      = true
o.writebackup = true
o.backupdir   = vim.fn.stdpath("state") .. "/backup"  -- ~/.local/state/nvim/backup

-- ========================================================================== --
--  Optional Niceties (completion UX, diagnostics)
-- ========================================================================== --

-- Better completion popup behavior (used by nvim-cmp)
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Rounded borders for diagnostic floats
vim.diagnostic.config({ float = { border = "rounded" } })

-- Avoid showing extra messages while completing
vim.opt.shortmess:append("c")

-- Dictionary / spell (explicit completion: <C-x><C-k> for dictionary, <C-x><C-s> for spell)
vim.opt.spell = false                         -- start off by default
vim.opt.spelllang = { "en_us" }

-- Add a system dictionary if present (adjust path if needed)
if vim.fn.filereadable("/usr/share/dict/words") == 1 then
  vim.opt.dictionary:append("/usr/share/dict/words")
end

-- If you ALSO want dictionary & spell suggestions included in generic <C-n>/<C-p>:
-- vim.opt.complete:append("k")  -- dictionary
-- vim.opt.complete:append("s")  -- spell

-- Handy toggle for spell checking
vim.keymap.set("n", "<leader>ts", function()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("spell=" .. tostring(vim.opt.spell:get()))
end, { desc = "Toggle spell checking" })

-- ========================================================================== --
--  Keymaps (general)
-- ========================================================================== --

local map = vim.keymap.set

-- Basic commands
map("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Write file" })
map("n", "<leader>q", "<cmd>q<cr>", { silent = true, desc = "Quit window" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { silent = true, desc = "Clear highlights" })

-- Window navigation (same as Vim)
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Buffer navigation (Tab / Shift-Tab)
map("n", "<Tab>",   ":bnext<CR>",     { silent = true, desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })

-- Optional fallbacks if <S-Tab> isn’t recognized by your terminal
map("n", "<leader>bn", ":bnext<CR>",     { silent = true, desc = "Next buffer (leader)" })
map("n", "<leader>bp", ":bprevious<CR>", { silent = true, desc = "Prev buffer (leader)" })

-- Close current buffer (Bufferline-aware; keeps layout intact)
map("n", "<leader>bd", "<cmd>bdelete<CR>", { silent = true, desc = "Delete buffer" })

-- Pick a buffer to close using Bufferline's visual selector
map("n", "<leader>bD", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" })

-- Jump directly to Nth buffer in bufferline with <leader>1..9
for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    require("bufferline").go_to_buffer(i, true)
  end, { desc = "Go to buffer " .. i })
end

-- ========================================================================== --
--  Git (vim-fugitive): smarter vertical diff / close                         --
-- ========================================================================== --

-- Helper: detect fugitive buffers (old revisions like fugitive://...)
local function is_fugitive_buffer(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name:match("^fugitive://") ~= nil
end

-- Helper: vertical Gdiffsplit but keep cursor on the original (local) buffer
local function git_diff_vertical_keep_local()
  local orig_buf = vim.api.nvim_get_current_buf()

  vim.cmd("vertical Gdiffsplit")

  -- If diff didn't actually activate (e.g. error), bail
  if not vim.wo.diff then
    return
  end

  -- Jump back to the window showing the original buffer (local file)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_set_current_win(win)
    if vim.api.nvim_win_get_buf(win) == orig_buf then
      break
    end
  end
end

-- Helper: close the *fugitive* side of a diff, keep the local file
local function close_other_diff_buffer()
  -- Only act in diff mode; outside, do nothing
  if not vim.wo.diff then
    return
  end

  local cur_win  = vim.api.nvim_get_current_win()
  local cur_buf  = vim.api.nvim_win_get_buf(cur_win)
  local other_win, other_buf

  -- Find another window in diff mode that shows a different buffer
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= cur_win then
      vim.api.nvim_set_current_win(win)
      if vim.wo.diff then
        local buf = vim.api.nvim_win_get_buf(win)
        if buf ~= cur_buf then
          other_win, other_buf = win, buf
          break
        end
      end
    end
  end

  -- Go back to the original window
  vim.api.nvim_set_current_win(cur_win)

  -- If we didn't find a distinct other diff buffer, do nothing
  if not other_buf then
    return
  end

  local cur_is_fug   = is_fugitive_buffer(cur_buf)
  local other_is_fug = is_fugitive_buffer(other_buf)

  -- Decide which buffer to keep:
  --  - If exactly one is fugitive, delete that one.
  --  - Otherwise, keep the current buffer and delete the other.
  if cur_is_fug and not other_is_fug then
    -- We are on the fugitive side; keep the other (local) buffer
    vim.api.nvim_set_current_win(cur_win)
    vim.api.nvim_buf_delete(cur_buf, { force = false })
    vim.api.nvim_win_set_buf(cur_win, other_buf)
  elseif other_is_fug and not cur_is_fug then
    -- Other side is fugitive; keep current (local) buffer
    vim.api.nvim_set_current_win(other_win)
    vim.api.nvim_buf_delete(other_buf, { force = false })
    vim.api.nvim_set_current_win(cur_win)
  else
    -- Fallback: ambiguity; keep current buffer, delete the other
    vim.api.nvim_set_current_win(other_win)
    vim.api.nvim_buf_delete(other_buf, { force = false })
    vim.api.nvim_set_current_win(cur_win)
  end
end

-- Git status
map("n", "<leader>gs", "<cmd>G<CR>", { desc = "Git status (Fugitive)" })

-- Diff current file in a *vertical* split, but keep cursor in the original
-- (local) buffer window after the split.
map("n", "<leader>gd", git_diff_vertical_keep_local, { desc = "Git diff (vertical, keep local)" })

-- Smart quit: delete the fugitive/old-revision side and keep the local file,
-- regardless of which side you're on. Outside diff mode, does nothing.
map("n", "<leader>gq", close_other_diff_buffer, { desc = "Git diff: close fugitive side" })

-- Hard reset: turn off diff everywhere and equalize windows
map("n", "<leader>gQ", "<cmd>diffoff!<CR><C-w>=", { silent = true, desc = "Diff off + equalize" })

-- Equalize all window sizes (handy after diffs or splits)
map("n", "<leader>g=", "<C-w>=", { silent = true, desc = "Equalize window sizes" })

-- Flip diff sides: rotate window layout (swap left/right or top/bottom),
-- move cursor to the opposite pane, and re-equalize window sizes.
map("n", "<leader>gx", "<C-w>r<C-w>w<C-w>=", {
  silent = true,
  desc = "Flip diff sides (swap panes, move cursor, equalize)",
})

-- Auto-equalize window sizes when working in diff mode
local diff_group = vim.api.nvim_create_augroup("DiffAutoEqualize", { clear = true })
vim.api.nvim_create_autocmd("WinEnter", {
  group = diff_group,
  callback = function()
    if vim.wo.diff then
      vim.cmd("wincmd =")
    end
  end,
})

-- ========================================================================== --
--  Telescope Integration (FZF-equivalent behavior)
-- ========================================================================== --

-- Prefer Git project root; fallback to current working directory
local function project_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  return (vim.v.shell_error == 0 and git_root ~= "") and git_root or vim.loop.cwd()
end

-- Find files (cwd)
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ cwd = vim.loop.cwd() })
end, { desc = "Find files (cwd)" })

-- Find files (project root)
vim.keymap.set("n", "<leader>fp", function()
  require("telescope.builtin").find_files({ cwd = project_root() })
end, { desc = "Find files (project root)" })

-- Recent files (MRU)
vim.keymap.set("n", "<leader>fo", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Recent files (MRU)" })

-- Resume last Telescope picker
vim.keymap.set("n", "<leader>fr", function()
  require("telescope.builtin").resume()
end, { desc = "Resume last Telescope picker" })

-- Live grep
vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep({ cwd = project_root() })
end, { desc = "Live grep project" })

-- Buffers
vim.keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "List open buffers" })

-- Help tags
vim.keymap.set("n", "<leader>fh", function()
  require("telescope.builtin").help_tags()
end, { desc = "Search help" })

-- Whole word grep
vim.keymap.set("n", "<leader>fw", function()
  require("telescope.builtin").grep_string({
    cwd = project_root(),
    search = vim.fn.expand("<cword>"),
    word_match = "-w",
  })
end, { desc = "Grep whole word under cursor (project)" })

-- Substring grep
vim.keymap.set("n", "<leader>fW", function()
  require("telescope.builtin").grep_string({
    cwd = project_root(),
    search = vim.fn.expand("<cword>"),
  })
end, { desc = "Grep substring under cursor (project)" })

-- Last / search
vim.keymap.set("n", "<leader>f/", function()
  local last = vim.fn.getreg("/")
  require("telescope.builtin").live_grep({
    cwd = project_root(),
    default_text = last or "",
  })
end, { desc = "Grep last / pattern (project)" })

-- ========================================================================== --
--  File Tree (nvim-tree)
-- ========================================================================== --
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

-- ========================================================================== --
--  Diagnostics (LSP)
-- ========================================================================== --
-- map("n", "<leader>dn", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
-- map("n", "<leader>dp", vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
-- map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Explain diagnostic" })

-- ========================================================================== --
--  CoC keymaps (Neovim, Lua style)                                           --
--  NOTE: assumes you've done: local map = vim.keymap.set earlier in file     --
-- ========================================================================== --

-- Go-to / references / hover
map("n", "gd", "<Plug>(coc-definition)",      { desc = "CoC: definition" })
map("n", "gD", "<Plug>(coc-declaration)",     { desc = "CoC: declaration" })
map("n", "gr", "<Plug>(coc-references)",      { desc = "CoC: references" })
map("n", "gi", "<Plug>(coc-implementation)",  { desc = "CoC: implementation" })
map("n", "gy", "<Plug>(coc-type-definition)", { desc = "CoC: type def" })
map("n", "K",  ":call CocActionAsync('doHover')<CR>", { silent = true, desc = "CoC: hover" })

-- ========================================================================== --
--  Completion behavior: CoC popup confirm / cycle / dismiss (Copilot-safe)
-- ========================================================================== --

-- Trigger completion manually (Ctrl-Space)
map("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true, desc = "CoC: manual complete" })

-- Smart Enter / Tab / Shift-Tab when popup visible
map("i", "<CR>",    'coc#pum#visible() ? coc#pum#confirm() : "\\<CR>"',
  { expr = true, silent = true, desc = "CoC: confirm or newline" })
map("i", "<Tab>",   'coc#pum#visible() ? coc#pum#next(1)  : "\\<Tab>"',
  { expr = true, silent = true, desc = "CoC: next item or Tab" })
map("i", "<S-Tab>", 'coc#pum#visible() ? coc#pum#prev(1)  : "\\<S-Tab>"',
  { expr = true, silent = true, desc = "CoC: prev item or S-Tab" })

-- Dismiss CoC popup manually (Ctrl-e). Falls back to normal <C-e> otherwise.
map("i", "<C-e>",
  'coc#pum#visible() ? coc#pum#cancel() : "\\<C-e>"',
  { expr = true, silent = true, desc = "CoC: dismiss completion popup" }
)

-- ========================================================================== --
--  Rename / code actions / formatting
-- ========================================================================== --
map("n", "<leader>rn", "<Plug>(coc-rename)",          { desc = "CoC: rename" })
map("n", "<leader>ca", "<Plug>(coc-codeaction)",      { desc = "CoC: code action" })
map({ "n", "x" }, "<leader>cf", "<Plug>(coc-format-selected)", { desc = "CoC: format range" })

-- ========================================================================== --
--  Diagnostics: navigation + list
-- ========================================================================== --
map("n", "<leader>dn", "<Plug>(coc-diagnostic-next)", { desc = "CoC: next diagnostic" })
map("n", "<leader>dp", "<Plug>(coc-diagnostic-prev)", { desc = "CoC: prev diagnostic" })
map("n", "]d",         "<Plug>(coc-diagnostic-next)", { desc = "CoC: next diagnostic" })
map("n", "[d",         "<Plug>(coc-diagnostic-prev)", { desc = "CoC: prev diagnostic" })
map("n", "<leader>de", ":CocDiagnostics<CR>",         { silent = true, desc = "CoC: diagnostics list" })

-- ========================================================================== --
--  Visibility toggles: inlay hints, diagnostics, suggestions
-- ========================================================================== --
map("n", "<leader>ih", ":CocCommand document.toggleInlayHint<CR>",
  { silent = true, desc = "Toggle inlay hints" })
map("n", "<leader>dg", ":call CocAction('diagnosticToggle')<CR>",
  { silent = true, desc = "Toggle diagnostics (global)" })
map("n", "<leader>db", ":call CocAction('diagnosticToggleBuffer')<CR>",
  { silent = true, desc = "Toggle diagnostics (buffer)" })
map("n", "<leader>cs", ":call CocAction('toggle', 'suggest')<CR>",
  { silent = true, desc = "CoC: toggle suggestions" })

-- ========================================================================== --
--  Comment toggle (Comment.nvim)
-- ========================================================================== --
map("n", "<leader>/", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment" })

-- ========================================================================== --
--  End of config.lua
-- ========================================================================== --
