
" Options {

    " Make Vim more useful
    set nocompatible
    " Enable hybrid line numbers
    set number relativenumber
    " Allow backspace in insert mode
    set backspace=indent,eol,start
    " Optimize for fast terminal connections
    set ttyfast
    " Show the filename in the window titlebar
    set title
    " Show the (partial) command as it’s being typed
    set showcmd
    " Show current mode down the bottom
    set showmode
    " syntax highlighting
    if has('gui_running')
    syntax on
    endif
    " Show status line
    set laststatus=2
    " Add the g flag to search/replace by default
    set gdefault
    " Allow modelines
    set modeline
    " Enable per-directory .vimrc files and disable unsafe commands in them
    set exrc
    set secure
    " Show current line and column position in file
    set ruler
    " Sets the Height of the Command Line
    set cmdheight=2
    " Turn on the WiLd menu, auto complete for commands in command line
    set wildmenu
    " No sounds on error set novisualbell
    set noerrorbells
    set novisualbell
    " Highlight dynamically as pattern is typed
    set incsearch
    " Don’t reset cursor to start of line when moving around.
    set nostartofline
    " Show the cursor position
    set ruler
    " Start scrolling three lines before the horizontal window border
    set scrolloff=3
    " Change mapleader
    let mapleader=","
    " automatically rebalance windows on vim resize
    autocmd VimResized * :wincmd =
    " binary file in a hex view
    set binary
    " Don’t add empty newlines at the end of files
    set noeol
    " Disable backups and swapfiles
    set nobackup
    set noswapfile
    " Syntax coloring lines that are too long just slows down the world
    set synmaxcol=196
    " Highlight current line
    set cursorline
    " Highlight column after col 100
    set colorcolumn=100
    " Use spaces instead of tabs
    set expandtab
    " Make tabs as wide as four spaces
    set tabstop=4
    " Indenting is 4 spaces
    set shiftwidth=4
    " Makes the spaces feel like real tabs
    set softtabstop=4
    " Turns it on
    set autoindent
    " Do it smarter!
    set smartindent
    " Show “invisible” characters
    set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
    " Highlight unwanted spaces
    set list
    " Highlight searches
    set hlsearch
    " Ignore case of searches
    set ignorecase
    " Use case if any caps used
    set smartcase
    " Highlight dynamically as pattern is typed
    set incsearch
    " Set to auto read when a file is changed from the outside
    set autoread
    " Stop indenting when pasting
    set pastetoggle=<f2>
    " More natural split opening
    set splitbelow
    set splitright
    " Syntax code folding
    set foldmethod=indent
    " Set the folding level on open, set to show level 1
    set foldlevel=1
    " Add a bit extra margin to the left
    set foldcolumn=0
    " Copy selection to OS X clipboard
    set clipboard=unnamed
    " Don't redraw while executing macros
    set lazyredraw
    " Hide buffers instead of closing them
    set hidden
    " Continue comments when pressing <Enter>
    set formatoptions+=r
    " Don't continue comments when pressing o/O
    set formatoptions-=o
    " Recognize numbered lists when formatting
    set formatoptions+=n
    " Use indent of second line in paragraph
    set formatoptions+=2
    " Don't break long lines that were already too long
    set formatoptions+=l
    " Don't add styling for HTML (eg. underline links)
    let html_no_rendering=1

    " Enable mouse for all modes
    set mouse=a
    if &term =~ '^screen'
        set ttymouse=sgr " http://superuser.com/questions/549930/cant-resize-vim-splits-inside-tmux
    endif
    " Note: To select text in your terminal, you have to use Shift+click (Linux) or Alt+click (Mac).

    " Source the vimrc file after saving it
    " if has("autocmd")
    "    autocmd bufwritepost .vimrc source ~/.vimrc
    " endif

" }

" Plugins {

    if filereadable(expand("~/.vim/plugins.vim"))
        source ~/.vim/plugins.vim
    endif

" }

" Color scheme {

    " Bad Wolf
    try
        " colorscheme badwolf
        colorscheme wellsokai
    catch
    endtry

" }

" Global key bindings {

    " Remap 0 to first non-blank character
    map 0 ^

    " Switching between windows
    noremap <C-j> <C-w>j
    noremap <C-k> <C-w>k
    noremap <C-h> <C-w>h
    noremap <C-l> <C-w>l

" }

" Insert mode key bindings {

    " Save file Ctrl-s
    imap <C-s> <Esc>:w<CR>a

    " Moves cursor
    imap <C-e> <End>
    imap <C-a> <Home>

    " Delete and backspace
    imap <C-d> <Del>
    imap <C-h> <BS>

    " Toggle wrapping mode
    imap <F4> <C-o>:setlocal wrap!<CR>

    " mapping ESC to `jk`
    :inoremap jk <esc>

    " New Tab
    inoremap <C-t>     <Esc>:tabnew<CR>

" }

" Normal mode key bindings {

    " Save file Ctrl-s
    nmap <C-s> :w<CR>
    nmap <leader>w :w!<CR>

    " Toggle folding
    nnoremap <space> za

    " Toggle wrapping mode
    " map <F4> :setlocal wrap!<CR>
    " Toggle spell check
    " map <F5> :setlocal spell! spelllang=en<CR>

    " Disable highlight
    map <silent> <leader><cr> :noh<cr>
    " Switch CWD to the directory of the open buffer
    map <leader>cd :cd %:p:h<cr>:pwd<cr>
    " Quickly edit/reload the vimrc file
    nmap <silent> <leader>ve :e $MYVIMRC<CR>
    nmap <silent> <leader>vs :so $MYVIMRC<CR>
    " Toggle paste mode
    map <leader>pp :setlocal paste!<cr>

    " Upper/lower word
    nmap <leader>u viwU
    nmap <leader>l viwu

    " Upper/lower first char of word
    nmap <leader>U gewvU
    nmap <leader>L gewvu

    " Tabs
    " nmap <C-j> :tabp<CR>
    " nmap <C-k> :tabn<CR>
    nnoremap <C-t> :tabnew<CR>
    nnoremap th  :tabfirst<CR>
    nnoremap tk  :tabnext<CR>
    nnoremap tj  :tabprev<CR>
    nnoremap tl  :tablast<CR>
    nnoremap tt  :tabedit<Space>
    nnoremap tn  :tabnext<Space>
    nnoremap tm  :tabm<Space>
    nnoremap td  :tabclose<CR>
    " Alternatively use
    "nnoremap th :tabnext<CR>
    "nnoremap tl :tabprev<CR>
    "nnoremap tn :tabnew<CR>

    " Map <M-h,j,k,l> to resize windows
    nmap <silent> ˙ <C-w><
    nmap <silent> ∆ <C-W>-
    nmap <silent> ˚ <C-W>+
    nmap <silent> ¬ <C-w>>

    " Exit to shell
    nmap <leader>z :sh<cr>

    " Strip trailing whitespace
    noremap <leader>ss :call StripWhitespace()<CR>
    function! StripWhitespace()
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        :%s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
    endfunction

    " Paste from the system clipboard
    nmap <leader>p "*p
    " Paste from the system clipboard
    nmap <leader>p :r !ssh localhost -p 2244 pbpaste<CR>

    " Remove highlight from search
    nmap <leader>n :nohls<CR>

" }

" Visual mode {

    " Pressing * or # searches for the current selection
    function! s:VSetSearch()
        let temp = @@
        norm! gvy
        let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
        let @@ = temp
    endfunction

    vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><c-o>
    vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><c-o>

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Make tab in visual mode indent code
    vnoremap <tab>   >gv
    vnoremap <s-tab> <gv

    " Copy to the system clipboard
    vmap <leader>y y:e ~/clipboard<CR>:setlocal noeol<CR>p:w !ssh localhost -p 2244 pbcopy<CR>:bdelete!<CR><CR>

" }

" fzf {
    " set runtimepath+=~/.dotfiles/fzf

    nnoremap <leader>f :Files<CR>
    nnoremap <leader>b :Buffers<CR>
    nnoremap <leader>g :GFiles<CR>
    nnoremap <leader>t :Tags<CR>
" }

" Automatic commands {

    if has("autocmd")
        " Don't highlight the current line if entering another window
        autocmd WinEnter * set cursorline
        autocmd WinLeave * set nocursorline

        " Keep folds layout
        " autocmd BufWinLeave ?* mkview
        " autocmd BufWinEnter ?* silent loadview

        " Jump to last cursor position unless it's invalid or in an event handler
        autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal! g'\"" |
            \ endif

        " Enable file type detection
        filetype plugin indent on
        autocmd FileType go compiler go
        " Markdown
        autocmd BufNewFile,BufRead *.md set filetype=markdown
        " Treat .json files as .js
        autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
        " Treat .es files as .js
        autocmd BufNewFile,BufRead *.es setfiletype javascript
        " Auto-detect indent settings
        " autocmd BufReadPost * :DetectIndent
        " Use tabs for makefiles
        autocmd FileType make setlocal noexpandtab

        " Source the vimrc file after saving it
        " autocmd bufwritepost .vimrc source ~/.vimrc

        " Git commit
        autocmd FileType gitcommit set textwidth=72
        autocmd FileType gitcommit set colorcolumn=73
        au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 3, 2, 0])

    endif

    " Source local vimrc
    try
        source ~/.vimrc_local
    catch
    endtry

" }
