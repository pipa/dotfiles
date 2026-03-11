return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    open_fold_hl_timeout = 150,
    close_fold_kinds = { "imports", "comment" },
    preview = {
      win_config = {
        border = "rounded",
        position = "top",
        zindex = 200,
      },
    },
    provider_selector = function(_, filetype, buftype)
      local function handle_ts_exception(err, provider)
        local provider_name = "treesitter"
        if err:match("UfoInspectingFailed") then
          for _, v in ipairs({ "lsp", "treesitter" }) do
            if v ~= provider then
              provider_name = v
              break
            end
          end
        end
        return provider_name
      end

      return (filetype == "" or buftype == "nofile") and "indent" or function(bufnr)
        if require("ufo").getFoldVirtTextHandler(bufnr) then
          return handle_ts_exception(nil, "treesitter")
        end
        return "treesitter"
      end
    end,
  },
  init = function()
    vim.keymap.set("zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
    vim.keymap.set("zk", require("ufo").gotoPreviousClosedFold, { desc = "Go to previous closed fold" })
    vim.keymap.set("zj", require("ufo").gotoNextClosedFold, { desc = "Go to next closed fold" })
  end,
}