return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep (root dir)" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
    { "<leader>f/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
  },
  opts = {
    defaults = {
      file_ignore_patterns = {
        "^.git/",
        "^node_modules/",
        "^dist/",
        "^build/",
        "^%.cache/",
      },
      hidden = true,
    },
  },
}
