
-- All runtime setups for Treesitter, Telescope ext, Gitsigns,
-- and LSP + completion (nvim-cmp).  (Neovim 0.11+ LSP API)

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "bash", "json", "yaml" },
  auto_install = true,                 -- install parsers on demand
  highlight = {
    enable = true,                     -- Treesitter highlight
    additional_vim_regex_highlighting = false,  -- no legacy regex (modern themes)
  },
  indent = { enable = true },
})

-- Telescope: enable native sorter if available
pcall(require("telescope").load_extension, "fzf")

-- Gitsigns
require("gitsigns").setup({})

-- -------------------------------------------------------------------------- --
--  LSP servers (new API, with binary checks)
-- -------------------------------------------------------------------------- --

-- local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- -- Lua (make your config lint-free)
-- if vim.fn.executable("lua-language-server") == 1 then
--   vim.lsp.config("lua_ls", {
--     capabilities = capabilities,
--     settings = {
--       Lua = {
--         diagnostics = { globals = { "vim" } },
--         workspace   = { checkThirdParty = false },
--       },
--     },
--   })
--   vim.lsp.enable("lua_ls")
-- end

-- -- Python
-- if vim.fn.executable("pyright-langserver") == 1 then
--   vim.lsp.config("pyright", {
--     capabilities = capabilities,
--     -- settings = { python = { analysis = { typeCheckingMode = "basic" } } },
--   })
--   vim.lsp.enable("pyright")
-- end

-- -- Add more servers as needed (examples):
-- -- if vim.fn.executable("typescript-language-server") == 1 then
-- --   vim.lsp.config("tsserver", { capabilities = capabilities })
-- --   vim.lsp.enable("tsserver")
-- -- end
-- --
-- -- if vim.fn.executable("bash-language-server") == 1 then
-- --   vim.lsp.config("bashls", { capabilities = capabilities })
-- --   vim.lsp.enable("bashls")
-- -- end
-- --
-- -- if vim.fn.executable("yaml-language-server") == 1 then
-- --   vim.lsp.config("yamlls", { capabilities = capabilities })
-- --   vim.lsp.enable("yamlls")
-- -- end

-- -------------------------------------------------------------------------- --
--  nvim-cmp (completion)
-- -------------------------------------------------------------------------- --
-- local cmp     = require("cmp")
-- local luasnip = require("luasnip")

-- cmp.setup({
--   snippet = {
--     expand = function(args)
--       luasnip.lsp_expand(args.body)
--     end,
--   },
--   mapping = {
--     ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
--     ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
--     ["<CR>"]  = cmp.mapping.confirm({ select = true }),
--     ["<Tab>"] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_next_item()
--       elseif luasnip.expand_or_jumpable() then
--         luasnip.expand_or_jump()
--       else
--         fallback()
--       end
--     end, { "i", "s" }),
--     ["<S-Tab>"] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_prev_item()
--       elseif luasnip.jumpable(-1) then
--         luasnip.jump(-1)
--       else
--         fallback()
--       end
--     end, { "i", "s" }),
--   },
--   -- Copilot prioritized, then LSP, snippets, path, then buffer
--   sources = cmp.config.sources({
--     { name = "copilot" },
--     { name = "nvim_lsp" },
--     { name = "luasnip" },
--     { name = "path" },
--   }, {
--     { name = "buffer" },
--   }),
--   window = {
--     completion    = cmp.config.window.bordered(),
--     documentation = cmp.config.window.bordered(),
--   },
-- })

-- -------------------------------------------------------------------------- --
--  LSP keymaps (buffer-local, set when a server attaches)
-- -------------------------------------------------------------------------- --
-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
--   callback = function(args)
--     local bufnr = args.buf
--     local map = function(mode, lhs, rhs, desc)
--       vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
--     end

--     -- Go to / info
--     map("n", "gd",     vim.lsp.buf.definition,        "LSP: Go to definition")
--     map("n", "gD",     vim.lsp.buf.declaration,       "LSP: Go to declaration")
--     map("n", "gr",     vim.lsp.buf.references,        "LSP: References")
--     map("n", "gi",     vim.lsp.buf.implementation,    "LSP: Go to implementation")
--     map("n", "gy",     vim.lsp.buf.type_definition,   "LSP: Type definition")
--     map("n", "K",      vim.lsp.buf.hover,             "LSP: Hover")
--     map("n", "<C-k>",  vim.lsp.buf.signature_help,    "LSP: Signature help")

--     -- Actions
--     map("n", "<leader>rn", vim.lsp.buf.rename,        "LSP: Rename symbol")
--     map("n", "<leader>ca", vim.lsp.buf.code_action,   "LSP: Code action")
--     map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "LSP: Format buffer")

--     -- Diagnostics (you also have <leader>dn/<leader>dp/<leader>de in config.lua)
--     map("n", "[d",     vim.diagnostic.goto_prev,      "Diag: Prev")
--     map("n", "]d",     vim.diagnostic.goto_next,      "Diag: Next")
--     map("n", "<leader>dl", vim.diagnostic.setloclist, "Diag: Populate loclist")
--   end,
-- })
