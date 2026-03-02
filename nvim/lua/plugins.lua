
-- lua/plugins.lua
-- All plugin specs only. No heavy config here; that lives in config.lua / lsp.lua.
return {
  -- Neovim-native replacements for tpope classics
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "numToStr/Comment.nvim",  event = "VeryLazy", config = true },

  -- Classics you like (Vimscript works fine)
  { "tpope/vim-fugitive", event = "VeryLazy" },

  -- Colors (load early so :colorscheme in theme.lua always succeeds)
  { "ishan9299/nvim-solarized-lua", lazy = false, priority = 1000 },
  --{ "lifepillar/vim-solarized8", lazy = false, priority = 1000 },
  --{ "navarasu/onedark.nvim", lazy = false, priority = 1000 },
  { "jnurmine/Zenburn",                 lazy = false, priority = 1000 },

  -- Icons (nice for nvim-tree, telescope, gitsigns)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Core Lua utilities
  { "nvim-lua/plenary.nvim", lazy = true },

  -- File explorer (replaces NERDTree in Neovim)
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
    end,
  },

  -- Bufferline (top buffer tabs)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          numbers = "buffer_id",  -- show actual buffer numbers (for :b3 etc)
        },
      })
    end,
  },

  -- Treesitter (syntax/indent/folds)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", event = { "BufReadPost", "BufNewFile" } },

  -- Telescope fuzzy finder (+ native sorter if make(1) exists)
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
  },

  -- Git inline signs
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = true,
  },

  -- Native LSP + completion stack
  -- { "neovim/nvim-lspconfig" },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "hrsh7th/cmp-nvim-lua",
  --     "L3MON4D3/LuaSnip",
  --     "saadparwaiz1/cmp_luasnip",
  --   },
  -- },

  -- -- GitHub Copilot (native Lua) + cmp source
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require("copilot").setup({
  --       suggestion = { enabled = false },  -- we use copilot-cmp instead
  --       panel      = { enabled = false },
  --       filetypes  = {
  --         markdown = true,
  --         help     = false,
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end,
  -- },

  -- CoC (VSCode-like LSP+completion in one)
  { "neoclide/coc.nvim", branch = "release" },

  -- Classic Copilot.vim (works great with CoC)
  { "github/copilot.vim" },

  -- AI / code companion plugin
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    -- Load only when used
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionActions",
    },

    -- Keymaps here trigger lazy-load
    keys = {
      -- Chat buffer
      { "<leader>cc", "<cmd>CodeCompanionChat<CR>",        desc = "CC: Chat" },
      { "<leader>cC", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CC: Toggle chat" },
      { "<leader>ca", "<cmd>CodeCompanionActions<CR>",     desc = "CC: Action Palette" },

      -- Inline assistant (acts on current buffer/visual selection)
      { "<leader>ci", "<cmd>CodeCompanion<CR>",            desc = "CC: Inline (prompt after)", mode = { "n", "v" } },

      -- Command generator
      { "<leader>c:", "<cmd>CodeCompanionCmd<CR>",         desc = "CC: Generate command" },

      -- Add selected text to the open chat buffer
      { "<leader>cA", ":CodeCompanionChat Add<CR>",   desc = "CC: Add selection to chat", mode = "v" },
    },

    -- Keep opts minimal; add adapters later once it’s working
    opts = {
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
      },
    }
  }

  -- (Optional later)
  -- { "stevearc/conform.nvim" },   -- formatter runner
  -- { "mfussenegger/nvim-lint" },  -- lightweight linter runner
}
