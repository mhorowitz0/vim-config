" --- Basics ---
set nocompatible

" Add Homebrew fzf to runtime path
set rtp+=/opt/homebrew/opt/fzf

" Use vim-plug
call plug#begin()
  " Git
  Plug 'tpope/vim-fugitive'

  " Filesystem (keep for Vim; Neovim uses nvim-tree)
  Plug 'scrooloose/nerdtree'
  Plug 'jistr/vim-nerdtree-tabs'

  " Editing niceties
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'

  " LSP/Completion/Diagnostics for Vim
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Finder (prefer FZF over ctrlp)
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " Colors
  Plug 'altercation/vim-colors-solarized'
  Plug 'jnurmine/Zenburn'

  " Tags (better autotags than vim-autotag)
  Plug 'ludovicchabant/vim-gutentags'

" vim-plug help
" :PlugInstall to install the plugins
" :PlugUpdate to install or update the plugins
" :PlugDiff to review the changes from the last update
" :PlugClean to remove plugins no longer in the list
call plug#end()
" Put your non-Plugin stuff after this line

" ===================================================================
"  CoC: auto-install & keep my extensions
" ===================================================================
" CoC will automatically install any missing extensions at startup
" and keep them updated with :CocUpdate.
" -------------------------------------------------------------------

let g:coc_global_extensions = [
      \ 'coc-pyright',
      \ '@yaegassy/coc-ruff',
      \ 'coc-json',
      \ 'coc-yaml',
      \ 'coc-tsserver',
      \ 'coc-sh',
      \ 'coc-snippets',
      \ 'coc-html',
      \ 'coc-css'
      \ ]


" Enable filetype detection, plugins and indent rules
filetype plugin indent on

" --- UI & editing ---
set number
set backspace=indent,eol,start
set clipboard=unnamed
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" --- Search behavior --------------------------------------------------------

set hlsearch        " Keep matches highlighted after searching (use :nohlsearch or <leader>h to clear)
set incsearch       " Show matches dynamically as you type during / or ? searches
set ignorecase      " Make searches case-insensitive by default
set smartcase       " If search includes uppercase letters, make it case-sensitive

" --- Window split behavior --------------------------------------------------

set splitbelow      " New horizontal splits open below the current window
set splitright      " New vertical splits open to the right of the current window

" --- Editing safety & file history -----------------------------------------

" Disable swap files (avoid .swp clutter)
set noswapfile

" Enable persistent undo (keeps history across sessions)
set undofile
set undodir=~/.vim/undo

" Optional: enable simple backups (commented out)
" set backup
" set backupdir=~/.vim/backup

" Create undo/backup dirs if missing (first-time setup)
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif
if !isdirectory(expand('~/.vim/backup'))
  call mkdir(expand('~/.vim/backup'), 'p')
endif

" --- Keymaps ---
let mapleader=" "

" Window navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" --- Buffer navigation (Tab / Shift-Tab) -----------------------------------
nnoremap <silent> <Tab>   :bnext<CR>
nnoremap <silent> <S-Tab> :bprevious<CR>
nnoremap <silent> <leader>bn :bnext<CR>
nnoremap <silent> <leader>bp :bprevious<CR>

" Clear search highlight
" nnoremap <F6> :nohlsearch<CR>
nnoremap <leader>h :nohlsearch<CR>

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore=['\.pyc$', '\~$']
let g:nerdtree_tabs_open_on_gui_startup=0

" --- Colors ---
if has('gui_running')
  set background=dark
  colorscheme solarized
  "colorscheme darkblue
  "colorscheme jellybeans
  "colorscheme lucius
  "colorscheme badwolf
  "colorscheme molokai
  set guifont=Monaco:h14
else
  "colorscheme zenburn
  colorscheme solarized
endif

" For full syntax highlighting:
let python_highlight_all=1
" shouldn't be necessary with vim-plug
" safer to use enable than on
"syntax enable
"syntax on

" ========================================================================== "
"  CoC keymaps (Vim .vimrc version)                                          "
"  NOTE: keep this after your plugin setup and mapleader definition.         "
" ========================================================================== "

" --- Go-to / references / hover -------------------------------------------
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-declaration)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" --- Completion behavior: confirm / cycle / dismiss ------------------------
" Manual trigger (Ctrl-Space)
inoremap <silent><expr> <C-Space> coc#refresh()

" Smart Enter / Tab / Shift-Tab when popup visible
inoremap <expr> <CR>    coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <expr> <Tab>   coc#pum#visible() ? coc#pum#next(1)   : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1)   : "\<S-Tab>"

" Dismiss CoC popup manually (Ctrl-e) — leaves Copilot ghost alone
inoremap <expr> <C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-e>"

" --- Rename / code actions / formatting -----------------------------------
nmap <silent> <leader>rn <Plug>(coc-rename)
nmap <silent> <leader>ca <Plug>(coc-codeaction)
xmap <silent> <leader>f  <Plug>(coc-format-selected)
nmap <silent> <leader>f  <Plug>(coc-format-selected)

" --- Diagnostics: navigation + list ---------------------------------------
nmap <silent> ]d <Plug>(coc-diagnostic-next)
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nnoremap <silent> <leader>dn <Plug>(coc-diagnostic-next)
nnoremap <silent> <leader>dp <Plug>(coc-diagnostic-prev)
nnoremap <silent> <leader>de :CocDiagnostics<CR>

" --- Visibility toggles: inlay hints, diagnostics, suggestions -------------
nnoremap <silent> <leader>ih :CocCommand document.toggleInlayHint<CR>
nnoremap <silent> <leader>dg :call CocAction('diagnosticToggle')<CR>
nnoremap <silent> <leader>db :call CocAction('diagnosticToggleBuffer')<CR>
nnoremap <silent> <leader>cs :call CocAction('toggle', 'suggest')<CR>

" ===================================================================
"  GitHub Copilot keymaps
" ===================================================================
let g:copilot_no_tab_map = v:true
imap <silent><script><expr> <C-]> copilot#Accept("\<CR>")
imap <silent> <C-\> <Plug>(copilot-dismiss)

" Don't hide Copilot ghost text during completion popups
let g:copilot_hide_during_completion = 0

" --- Language-specific light touches ---
" Python: keep it simple; CoC/linters will handle style
augroup PyBasics
  autocmd!
  autocmd FileType python setlocal textwidth=100
augroup END

" JS/YAML: 2-space indents
augroup TwoSpace
  autocmd!
  autocmd FileType javascript,yaml,html,css setlocal shiftwidth=2 tabstop=2 softtabstop=2
augroup END

" --- Gutentags defaults (works out of the box). Uncomment to tune ---
" let g:gutentags_cache_dir = expand('~/.cache/gutentags')
" let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']


" Only Python on save (leave global formatOnSave off)
" In vimrc:
" let g:coc_preferences = {'formatOnSave': v:false}
" augroup CocRuffFmt
"   autocmd!
"   autocmd BufWritePre *.py silent! call CocAction('format')
" augroup END

" --- FZF integration --------------------------------------------------------
" Requires: brew install fzf ripgrep
" Adds fuzzy file, buffer, and text search commands and keymaps

" Helper: determine project root (prefers Git; falls back to current dir)
function! s:ProjectRoot()
  let l:git = systemlist('git rev-parse --show-toplevel')[0]
  return v:shell_error ? getcwd() : l:git
endfunction

" Command: open file picker from project root
command! -nargs=0 ProjectFiles execute 'Files ' . fnameescape(<sid>ProjectRoot())

" --- FZF keymaps ------------------------------------------------------------
" (Space = <Leader>)

" Fuzzy-find files from current working directory
nnoremap <silent> <leader>ff :Files<CR>

" Fuzzy-find files from project (Git) root
nnoremap <silent> <leader>fp :ProjectFiles<CR>

" Live grep entire project (requires ripgrep)
nnoremap <silent> <leader>fg :Rg<CR>

" Grep for the whole word under the cursor (exact match, like *)
nnoremap <silent> <leader>fw :execute 'Rg -w ' . expand('<cword>')<CR>

" Grep for any occurrence of the word (substring match, like g*)
nnoremap <silent> <leader>fW :execute 'Rg ' . expand('<cword>')<CR>

" List open buffers
nnoremap <silent> <leader>fb :Buffers<CR>

" Search Vim help tags
nnoremap <silent> <leader>fh :Helptags<CR>

" Reopen recent files (MRU + buffers)
nnoremap <silent> <leader>fo :History<CR>

" OPTIONAL: Rg using your last / search (from @/ register), as a literal string
command! -nargs=0 RgLast execute 'Rg -F ' . shellescape(@/)
nnoremap <silent> <leader>f/ :RgLast<CR>

" --- FZF preview and Rg configuration ---------------------------------------
" Toggle preview with Ctrl-/ inside FZF
let g:fzf_preview_window = ['right:60%:hidden', 'ctrl-/']

" Redefine :Rg to show hidden files but skip .git directory
if executable('rg')
  command! -nargs=* Rg call fzf#vim#grep(
        \ 'rg --hidden --glob "!.git" --column --line-number --no-heading --color=always --smart-case '
        \ . shellescape(<q-args>), 1, fzf#vim#with_preview(), 0)
endif

" --- FZF open-action cheat sheet --------------------------------------------
" Inside any FZF picker:
"   Enter   → open in current window
"   Ctrl-v  → open in vertical split
"   Ctrl-x  → open in horizontal split
"   Ctrl-t  → open in new tab
"   Ctrl-q  → send matches to quickfix list
"   Ctrl-/  → toggle preview (if enabled above)


" --- Dictionary and Spell completion --------------------------------------

" Start with spell-checking disabled by default
set nospell
set spelllang=en_us

" Add system dictionary if available (used for <C-x><C-k> completion)
if filereadable('/usr/share/dict/words')
  set dictionary+=/usr/share/dict/words
endif

" Optional: include dictionary & spell words in general <C-n>/<C-p> completion
" set complete+=k   " include dictionary words
" set complete+=s   " include spelling suggestions

" --- Keybindings ----------------------------------------------------------
" <Leader>ts    → toggle spell-checking on/off
" <C-x><C-k>    → complete from dictionary
" <C-x><C-s>    → complete from spell-check suggestions
" <C-n>/<C-p>   → cycle through generic completions (if complete+=k,s are set)

" Toggle spell-checking and echo current state
nnoremap <leader>ts :set invspell<CR>:echo "spell=" . &spell<CR>
