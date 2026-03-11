-- Options.lua
-- General
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showmode = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.pumheight = 10
vim.opt.conceallevel = 0
vim.opt.fileencoding = "utf-8"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.termguicolors = true
vim.opt.guicursor = "n-v-c:block,i-ci-ve:blinkon100-blinkon100,r-cr:hor20,a:blinkon100"

-- Folding with nvim-ufo
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 1
vim.opt.foldlevelstart = 1
vim.opt.foldenable = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Wild menu
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildignore = "*.doc,*.pdf,*.jpg,*.png,*.gif,*.bmp,*.o,*.obj,*.pyc,*.class"

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Buffer
vim.opt.hidden = true
vim.opt.autoread = true

-- Highlight
vim.opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }

-- Misc
vim.opt.iskeyword:append("-")
vim.opt.shortmess:append("c")
vim.opt.whichwrap:append("<>[]hl")

-- Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true

-- Search
vim.opt.inccommand = "nosplit"
vim.opt.levenshtein = true

-- Performance
vim.opt.lazyredraw = false
vim.opt.synmaxcol = 240