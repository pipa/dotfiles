return {
  -- add toggleterm
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        shade_terminals = false,
        persist_mode = true,
        direction = "float",
        float_opts = {
          border = "single",
          winblend = 3,
          highlights = {
            border = "FloatBorder",
            background = "Normal",
          },
        },
      })

      -- Define keybindings to toggle the terminal window
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }

      map("n", "<leader>t", ":ToggleTerm<CR>", opts)
      map("t", "<leader>t", "<C-\\><C-n>:ToggleTerm<CR>", opts)
    end,
  },
}
