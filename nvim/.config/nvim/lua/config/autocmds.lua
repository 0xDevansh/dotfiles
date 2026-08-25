-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Treat .ipynb files as jupyter (not JSON) so molten + notebook-navigator load
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.ipynb",
  callback = function()
    vim.bo.filetype = "jupyter"
  end,
})
