-- Keymaps.lua
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Clear highlights
keymap("n", "<leader>h", vim.cmd.nohlsearch, { desc = "Clear search highlights" })

-- Save and quit
keymap("n", "<leader>w", ":w<CR>", { desc = "Save" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit all" })

-- Splits
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })

-- Terminal
keymap("n", "<leader>tt", ":terminal<CR>", { desc = "Terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", opts)

-- Quickfix
keymap("n", "<leader>co", ":copen<CR>", { desc = "Open quickfix" })
keymap("n", "<leader>cc", ":cclose<CR>", { desc = "Close quickfix" })
keymap("n", "<leader>cn", ":cnext<CR>", { desc = "Next quickfix" })
keymap("n", "<leader>cp", ":cprevious<CR>", { desc = "Previous quickfix" })

-- Loclist
keymap("n", "<leader>lo", ":lopen<CR>", { desc = "Open loclist" })
keymap("n", "<leader>lc", ":lclose<CR>", { desc = "Close loclist" })

-- Toggle options
keymap("n", "<leader>th", function()
  vim.opt.number = not vim.opt.number.value
  vim.opt.relativenumber = not vim.opt.relativenumber.value
end, { desc = "Toggle line numbers" })

keymap("n", "<leader>tw", function()
  vim.opt.wrap = not vim.opt.wrap.value
end, { desc = "Toggle wrap" })

keymap("n", "<leader>ts", function()
  vim.opt.spell = not vim.opt.spell.value
end, { desc = "Toggle spell check" })

-- Keep cursor centered
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
keymap("n", "J", "mzJ`z", opts)

-- Move lines up/down with arrow keys (when not in visual mode)
keymap("n", "<Up>", ":m-2<CR>==", opts)
keymap("n", "<Down>", ":m+<CR>==", opts)

-- Open current file in explorer
keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>o", ":Neotree focus<CR>", { desc = "Focus file explorer" })

-- Lazy
keymap("n", "<leader>L", ":Lazy<CR>", { desc = "Open Lazy" })

-- Mason
keymap("n", "<leader>cm", ":Mason<CR>", { desc = "Open Mason" })

-- Diagnostic
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Git
keymap("n", "<leader>gg", ":LazyGit<CR>", { desc = "Open LazyGit" })
keymap("n", "<leader>gf", ":LazyGitFilter<CR>", { desc = "Open LazyGit Filter" })

-- No arrow keys in normal mode (force learning)
keymap("n", "<Up>", "<Nop>", opts)
keymap("n", "<Down>", "<Nop>", opts)
keymap("n", "<Left>", "<Nop>", opts)
keymap("n", "<Right>", "<Nop>", opts)

-- Insert mode keymaps
keymap("i", "jk", "<Esc>", opts)
keymap("i", "kj", "<Esc>", opts)
keymap("i", "jj", "<Esc>", opts)

-- Visual mode keymaps
keymap("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap("v", "<leader>d", '"_d', { desc = "Delete to void register" })

-- Tabs
keymap("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
keymap("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })
keymap("n", "<leader>tm", ":tabmove ", { desc = "Move tab" })
keymap("n", "<leader>tj", ":tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tk", ":tabprevious<CR>", { desc = "Previous tab" })