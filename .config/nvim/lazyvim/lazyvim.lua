-- LazyVim Configuration
-- This file configures LazyVim-specific settings

return {
  defaults = {
    ---@usage The function to use when opening a lazy link in the browser
    -- open = "open",
    ---@usage If false, don't show LazyVim changelog when exiting
    show_changelog = true,
    ---@usage The directory where the LazyVim changelog will be stored
    changelog_file = "CHANGELOG.md",
  },
  ---@usage Load the default settings, a keymap is defined below that opens the LazyVim changelog
  spec = "lazyvim.plugins.spec",
  ---Don't change the options below
  spec_runtime = "lazyvim.plugins.spec-runtime",
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
  dev = {
    ---@usage directory where you store your local plugins
    directory = "plugins",
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true },
  performance = {
    -- LazyVim by default only loads the plugins that you explicitly use
    -- By default, we load all plugins
    rtp = {
      -- disables some plugins
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
  profiling = {
    -- We load LazyVim (and all plugins) at startup, so we can measure the time it takes
    -- Set it to `true` if you want to see the profiling results on startup
    -- The results will be printed to the console
    load = false,
  },
}