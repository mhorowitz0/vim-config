"vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" vim-plug
call plug#begin()
" set the runtime path to include Vundle and initialize
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
"Plug 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plug 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plug 'L9'
" Git plugin not hosted on GitHub
"Plug 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plug 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plug 'ascenator/L9', {'name': 'newL9'}


"git interface
Plug 'tpope/vim-fugitive'
"filesystem
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'kien/ctrlp.vim' 

"html
"  isnowfy only compatible with python not python3
"Plug 'isnowfy/python-vim-instant-markdown'
"Plug 'jtratner/vim-flavored-markdown'
"Plug 'suan/vim-instant-markdown'
"Plug 'nelstrom/vim-markdown-preview'
"python sytax checker
Plug 'nvie/vim-flake8'
"Plug 'vim-scripts/Pydiction'
Plug 'vim-scripts/indentpython.vim'
Plug 'scrooloose/syntastic'

"auto-completion stuff
"Plug 'klen/python-mode'
" Old name replaced by ycm-core/YouComplete
"Plug 'Valloric/YouCompleteMe'
"Plug 'klen/rope-vim'
"Plug 'davidhalter/jedi-vim'
Plug 'ervandew/supertab'
""code folding
"Plug 'tmhedberg/SimpylFold'

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py --clangd-completer
  endif
endfunction

"Plug 'ycm-core/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'tpope/vim-surround'

" Use release branch (recommended)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Or build from source code by using npm
"Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
"
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"Colors!!!
Plug 'altercation/vim-colors-solarized'
Plug 'jnurmine/Zenburn'

"Powerline status bar
"Plug 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}

" auto-tag for ctags
Plug 'craigemery/vim-autotag'

" Code commenting
Plug 'tpope/vim-commentary'

" All of your Plugins must be added before the following line
"call vundle#end()            " required
"filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
"
" vim-plug help
" :PlugInstall to install the plugins
" :PlugUpdate to install or update the plugins
" :PlugDiff to review the changes from the last update
" :PlugClean to remove plugins no longer in the list
call plug#end()
" Put your non-Plugin stuff after this line

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


"omnicomplete default
set omnifunc=syntaxcomplete#Complete

"highlight search
set hls
nnoremap <F6> :nohls<CR>

"set splitbelow
"set splitright

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
"set foldmethod=indent
"set foldlevel=99

"folding options
let g:SimpylFold_docstring_preview=1

"autocomplete
let g:ycm_autoclose_preview_window_after_completion=1

"custom keys
let mapleader=" "
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
"
call togglebg#map("<F5>")

"color schemes
if has('gui_running')
  set background=dark
  colorscheme solarized
  "colorscheme darkblue
  "colorscheme jellybeans
  "colorscheme lucius
  "colorscheme badwolf
  "colorscheme molokai
else
  colorscheme zenburn
endif
set guifont=Monaco:h14

"filesystem options
map <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree
let g:nerdtree_tabs_open_on_gui_startup=0

"I don't like swap files
set noswapfile

"turn on numbering
"set nu
autocmd FileType python set nu

"python with virtualenv support
"py3 << EOF
"import os
"import sys
"if 'VIRTUAL_ENV' in os.environ:
"  project_base_dir = os.environ['VIRTUAL_ENV']
"  sys.path.insert(0, project_base_dir)
"  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"  execfile(activate_this, dict(__file__=activate_this))
"EOF

"it would be nice to set tag files by the active virtualenv here
":set tags=~/mytags "tags for ctags and taglist
"omnicomplete
autocmd FileType python set omnifunc=pythoncomplete#Complete

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

"------------Start Python PEP 8 stuff----------------
" Number of spaces that a pre-existing tab is equal to.
au BufRead,BufNewFile *py,*pyw,*.c,*.h set tabstop=4

"spaces for indents
au BufRead,BufNewFile *.py,*pyw set shiftwidth=4
au BufRead,BufNewFile *.py,*.pyw set expandtab
au BufRead,BufNewFile *.py set softtabstop=4

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Display tabs at the beginning of a line in Python mode as bad.
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" Wrap text after a certain number of characters
au BufRead,BufNewFile *.py,*.pyw, set textwidth=100

" Use UNIX (\n) line endings.
au BufNewFile *.py,*.pyw,*.c,*.h set fileformat=unix

" Set the default file encoding to UTF-8:
set encoding=utf-8

" For full syntax highlighting:
let python_highlight_all=1
" shouldn't be necessary with vim-plug
" safer to use enable than on
"syntax enable
"syntax on

" Keep indentation level from previous line:
autocmd FileType python set autoindent

" make backspaces more powerfull
set backspace=indent,eol,start

"Folding based on indentation:
"autocmd FileType python set foldmethod=indent
"use space to open folds
nnoremap <space> za 
"----------Stop python PEP 8 stuff--------------

"autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2

"js stuff"
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2

au BufNewFile,BufRead *.js,*.html,*.css,*.yaml set tabstop=2 softtabstop=2 shiftwidth=2

set complete+=kspell
set clipboard=unnamed

" Automatically change pwd to that of current file
set autochdir

"autocmd Syntax markdown syn match markdownError "\w\@<=\w\@="
