-- Jupyter / ipynb support
-- Requires (install once):
--   sudo pacman -S python-pynvim python-jupyter-client python-ipykernel
--
-- Keymaps (all under <leader>j):
--   <leader>ji  Init kernel (or pick one)
--   <leader>jl  Evaluate line
--   <leader>jv  Evaluate visual selection
--   <leader>jx  Run current cell
--   <leader>jX  Run cell and move to next
--   <leader>jo  Show output window
--   <leader>jO  Hide output window
--   <leader>jd  Delete cell output
--   <leader>jR  Restart kernel
--   [c / ]c     Jump to prev/next cell

return {
  -- Image rendering via kitty graphics protocol
  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend = "kitty",
      integrations = {},
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  -- Core: Jupyter kernel integration + inline output
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "python", "jupyter" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<CR>",             desc = "Init Kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<CR>",     desc = "Evaluate Line" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<CR>",   desc = "Re-evaluate Cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<CR>",       desc = "Show Output" },
      { "<leader>jO", "<cmd>MoltenHideOutput<CR>",       desc = "Hide Output" },
      { "<leader>jd", "<cmd>MoltenDelete<CR>",           desc = "Delete Cell Output" },
      { "<leader>jR", "<cmd>MoltenRestart!<CR>",         desc = "Restart Kernel" },
      {
        "<leader>jv",
        ":<C-u>MoltenEvaluateVisual<CR>gv",
        mode = "v",
        desc = "Evaluate Visual",
      },
    },
  },

  -- Cell navigation and run (works with # %% markers in .py and with .ipynb)
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {
      "echasnovski/mini.ai",
      "benlubas/molten-nvim",
    },
    ft = { "python", "jupyter" },
    keys = {
      { "]c", function() require("notebook-navigator").move_cell("d") end, desc = "Next Cell" },
      { "[c", function() require("notebook-navigator").move_cell("u") end, desc = "Prev Cell" },
      { "<leader>jx", function() require("notebook-navigator").run_cell() end,      desc = "Run Cell" },
      { "<leader>jX", function() require("notebook-navigator").run_and_move() end,  desc = "Run Cell & Move" },
    },
    opts = {
      repl_provider = "molten",
      cell_markers = {
        python = "# %%",
      },
    },
  },
}
