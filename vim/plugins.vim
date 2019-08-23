" Load vim-plug {

    if empty(glob("~/.vim/autoload/plug.vim"))
        execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    endif

" }

" Plugs list {

    " Make sure you use single quotes
    call plug#begin()

    Plug 'junegunn/fzf', { 'dir': '~/.vim/plugged/fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-surround'
    Plug 'scrooloose/nerdcommenter'
    Plug 'w0rp/ale'
    Plug 'gioele/vim-autoswap'
    Plug 'airblade/vim-gitgutter'
    Plug 'itchyny/lightline.vim'
    Plug 'jacoborus/tender'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'mattn/emmet-vim'
    Plug 'prettier/vim-prettier', {
        \ 'do': 'yarn install',
        \ 'for': ['javascript', 'css', 'scss', 'json', 'html' ] }
    Plug 'pangloss/vim-javascript'
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'ConradIrwin/vim-bracketed-paste'
    Plug 'jiangmiao/auto-pairs'
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'

    call plug#end()

" }

" Airline {

    " set lighline theme inside lightline config
    let g:lightline = { 'colorscheme': 'tender' }

    " set airline theme
    let g:airline_theme = 'tender'
    let g:airline_powerline_fonts = 1

" }

" Lang Customizations {

    let g:go_fmt_command = "goimports"

" }

" Emmet {

    let g:user_emmet_expandabbr_key='<Tab>'
    imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

" }

" ALE linter {

    let g:ale_linter_aliases = {
    \   'jstmpl': 'javascript',
    \   'csstmpl': 'css',
    \}
    let g:ale_lint_on_save = 1
    let g:ale_lint_on_text_changed = 'never'
    "let g:ale_linters_explicit = 1
    "let g:ale_history_log_output = 1
    let g:ale_linters = {
    \   'javascript': ['eslint'],
    \   'jstmpl': ['eslint'],
    \}

    " Set this. Airline will handle the rest.
    let g:airline#extensions#ale#enabled = 1

    let g:ale_echo_msg_error_str = 'error'
    let g:ale_echo_msg_warning_str = 'warning'
    let g:ale_echo_msg_format = '[%linter%-%severity%] %s'

" }

" IndentLine {

    " let g:indentLine_char = '¦'
    " let g:indentLine_leadingSpaceChar = '.'
    " let g:indentLine_color_term = 239
    " let g:indentLine_faster = 1

" }

" NERD {

    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
    " Allow commenting and inverting empty lines (useful when commenting a region)
    let g:NERDCommentEmptyLines = 1
    " Enable NERDCommenterToggle to check all selected lines is commented or not
    let g:NERDToggleCheckAllLines = 1

" }