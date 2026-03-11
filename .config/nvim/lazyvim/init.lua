-- Bootstrap LazyVim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.html" },
    { import = "lazyvim.plugins.extras.lang.css" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.ui.alpha" },
    { import = "lazyvim.plugins.extras.ui.mini-starter" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.dap.nlua" },
    { import = "lazyvim.plugins.extras.coding.treesitter" },
    { import = "lazyvim.plugins.extras.coding.treesitter-context" },
    { import = "lazyvim.plugins.extras.coding.nvim-cmp" },
    { import = "lazyvim.plugins.extras.util.mini-ai" },
    { import = "lazyvim.plugins.extras.util.mini-surround" },
    { import = "lazyvim.plugins.extras.lsp.none-ls" },
    { import = "lazyvim.plugins.extras.lsp.lint" },
    { import = "lazyvim.plugins.extras.mason" },
    { import = "plugins.catppuccin" },
    { import = "plugins.ufo" },
    { import = "plugins.lsp" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
      },
    },
  },
})