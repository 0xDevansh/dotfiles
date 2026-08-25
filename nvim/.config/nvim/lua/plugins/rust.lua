-- Rust language support for LazyVim
-- Relies on: lazyvim.plugins.extras.lang.rust (enabled in lazyvim.json)
-- That extra brings in: rustaceanvim, mason codelldb, neotest-rust

return {
  -- ── rustaceanvim ──────────────────────────────────────────────────────────
  -- Replaces rust-tools.nvim; talks directly to rust-analyzer.
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    opts = {
      server = {
        -- Use the rust-analyzer installed via rustup instead of Mason's copy.
        -- This keeps your toolchain in sync with your active rustup channel.
        cmd = function()
          local ra = vim.fn.exepath("rust-analyzer")
          if ra == "" then
            -- Fallback: ask rustup explicitly
            ra = vim.fn.trim(vim.fn.system("rustup which rust-analyzer"))
          end
          return { ra }
        end,

        default_settings = {
          ["rust-analyzer"] = {
            -- Show inlay hints for types, parameter names, etc.
            inlayHints = {
              bindingModeHints        = { enable = true },
              chainingHints           = { enable = true },
              closingBraceHints       = { enable = true, minLines = 20 },
              closureReturnTypeHints  = { enable = "with_block" },
              lifetimeElisionHints    = { enable = "skip_trivial", useParameterNames = true },
              maxLength               = 30,
              parameterHints          = { enable = true },
              typeHints               = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
            },

            -- Keep cargo check running on save for fast inline diagnostics.
            checkOnSave = true,
            check = {
              command   = "clippy",        -- use clippy instead of cargo check
              extraArgs = { "--no-deps" }, -- faster: skip dependency lints
            },

            -- Proc-macros & build scripts (needed for full accuracy).
            procMacro = {
              enable  = true,
              ignored = {
                -- Suppress noisy async-trait expansions in diagnostics.
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },

            cargo = {
              allFeatures    = true,
              loadOutDirsFromCheck = true,
            },

            -- Show docs as rendered markdown in hover.
            hover = { actions = { references = { enable = true } } },

            lens = {
              enable     = true,
              references = {
                adt        = { enable = true },
                enumVariant = { enable = true },
                method     = { enable = true },
                trait      = { enable = true },
              },
            },

            semanticHighlighting = {
              strings = { enable = true },
            },
          },
        },
      },

      -- ── DAP (debugging) ───────────────────────────────────────────────────
      -- codelldb is installed by the LazyVim rust extra via Mason.
      dap = {
        autoload_configurations = true,
      },
    },
  },

  -- ── Mason: ensure codelldb is always present ──────────────────────────────
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb" })
    end,
  },

  -- ── nvim-cmp: enable snippet expansion (needed for LSP snippets) ──────────
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
    },
  },
}
