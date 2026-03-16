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

  " Statusline + bufferline (airline)
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

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

" Jump directly to buffer N using <leader>1..9
for i in range(1, 9)
  execute 'nnoremap <silent> <leader>' . i . ' :buffer ' . i . '<CR>'
endfor

" Close current buffer (keep Vim running; works nicely with airline bufferline)
nnoremap <silent> <leader>bd :bdelete<CR>

" FZF-powered buffer picker that deletes selected buffer
command! BD call fzf#run({
      \ 'source':  map(getbufinfo({'buflisted':1}), {_,v -> v.bufnr . ' ' . v.name}),
      \ 'sink':    function('s:bd_sink'),
      \ 'down':    '40%' })

function! s:bd_sink(line)
  let l:bnr = split(a:line)[0]
  execute 'bdelete ' . l:bnr
endfunction

nnoremap <leader>bD :BD<CR>

" --- Diff helper: identify fugitive buffers --------------------------------
function! s:IsFugitiveBuffer(bufnr) abort
  let l:name = bufname(a:bufnr)
  " Fugitive buffers use a fugitive:// scheme
  return l:name =~# '^fugitive://'
endfunction

" --- Diff helper: close the *fugitive* side, keep the local file -----------"
function! s:CloseOtherDiffBuffer() abort
  " If we're not in diff mode at all, do nothing."
  if !&diff
    return
  endif

  let l:curwin  = winnr()
  let l:curbuf  = bufnr('%')
  let l:other_buf = -1
  let l:other_win = -1

  " Find another window that's also in diff mode but shows a different buffer
  for l:w in range(1, winnr('$'))
    execute l:w . 'wincmd w'
    if &diff && bufnr('%') != l:curbuf
      let l:other_buf = bufnr('%')
      let l:other_win = l:w
      break
    endif
  endfor

  " Go back to the original window
  execute l:curwin . 'wincmd w'

  " If we didn't find a distinct other diff buffer, do nothing
  if l:other_buf == -1
    return
  endif

  let l:cur_is_fug   = s:IsFugitiveBuffer(l:curbuf)
  let l:other_is_fug = s:IsFugitiveBuffer(l:other_buf)

  " Decide which buffer to keep:
  "  - If exactly one is fugitive, delete that one.
  "  - Otherwise, keep the current buffer and delete the other.
  if l:cur_is_fug && !l:other_is_fug
    " We are on the fugitive side; keep the other (local) buffer
    " Delete current buffer (and its window), then ensure local is shown
    execute l:curwin . 'wincmd w'
    execute 'bdelete ' . l:curbuf
    execute 'buffer ' . l:other_buf
  elseif l:other_is_fug && !l:cur_is_fug
    " Other side is fugitive; keep current (local) buffer
    execute l:other_win . 'wincmd w'
    execute 'bdelete ' . l:other_buf
    execute 'buffer ' . l:curbuf
  else
    " Fallback: ambiguity; keep current buffer, delete the other
    execute l:other_win . 'wincmd w'
    execute 'bdelete ' . l:other_buf
    execute 'buffer ' . l:curbuf
  endif
endfunction

" --- Diff helper: vertical Gdiffsplit but keep cursor on original buffer ---
function! s:GitDiffVerticalKeepLocal() abort
  " Remember the buffer we started in (usually the local working tree file)
  let l:origbuf = bufnr('%')

  " Open a vertical diff
  execute 'vertical Gdiffsplit'

  " If diff isn't actually on, bail out gracefully
  if !&diff
    return
  endif

  " Jump back to the window showing the original buffer (local file)
  for l:w in range(1, winnr('$'))
    execute l:w . 'wincmd w'
    if bufnr('%') == l:origbuf
      break
    endif
  endfor
endfunction

" --- Git review helper: live session state ---------------------------------
let s:git_review = {'root': '', 'current_file': ''}

" --- Git review helper: prefer Fugitive root, fallback to git --------------
function! s:GitRootForBuffer() abort
  let l:file = expand('%:p')
  let l:probe = empty(l:file) ? getcwd() : l:file

  if exists('*FugitiveWorkTree')
    let l:fugitive_root = FugitiveWorkTree(l:probe)
    if type(l:fugitive_root) == type('') && !empty(l:fugitive_root)
      return simplify(l:fugitive_root)
    endif
  endif

  let l:dir = isdirectory(l:probe) ? l:probe : fnamemodify(l:probe, ':h')
  let l:root = systemlist('git -C ' . shellescape(l:dir) . ' rev-parse --show-toplevel')
  return v:shell_error || empty(l:root) ? '' : l:root[0]
endfunction

" --- Git review helper: changed files from porcelain status ----------------
function! s:ChangedFiles(root) abort
  let l:files = []
  let l:lines = systemlist('git -C ' . shellescape(a:root) . ' status --porcelain')
  if v:shell_error
    return l:files
  endif

  for l:entry in l:lines
    if empty(l:entry)
      continue
    endif

    let l:status = strpart(l:entry, 0, 2)
    if l:status ==# '??'
      continue
    endif
    if l:status[1] ==# ' '
      continue
    endif

    let l:file = strpart(l:entry, 3)
    if l:file =~# ' -> '
      let l:file = matchstr(l:file, '-> \zs.*$')
    endif

    if empty(l:file)
      continue
    endif

    let l:path = simplify(a:root . '/' . l:file)
    if filereadable(l:path) && index(l:files, l:file) < 0
      call add(l:files, l:file)
    endif
  endfor

  return l:files
endfunction

" --- Git review helper: cleanup hidden review buffers ----------------------
function! s:CleanupReviewBuffer(bufnr) abort
  if a:bufnr <= 0 || !bufexists(a:bufnr)
    return
  endif

  if getbufvar(a:bufnr, '&modified') || bufwinnr(a:bufnr) != -1
    return
  endif

  execute 'bdelete ' . a:bufnr
endfunction

" --- Git review helper: find current file in the live review set -----------
function! s:FindReviewIndex(files, root) abort
  let l:candidates = []
  if !empty(s:git_review.current_file)
    call add(l:candidates, simplify(a:root . '/' . s:git_review.current_file))
  endif
  let l:buffer_path = expand('%:p')
  if !empty(l:buffer_path)
    call add(l:candidates, simplify(fnamemodify(l:buffer_path, ':p')))
  endif

  for l:target in l:candidates
    for l:i in range(0, len(a:files) - 1)
      if simplify(a:root . '/' . a:files[l:i]) ==# l:target
        return l:i
      endif
    endfor
  endfor

  return 0
endfunction

" --- Git review helper: echo current review position -----------------------
function! s:EchoReviewPosition(files, index) abort
  if empty(a:files) || a:index < 0 || a:index >= len(a:files)
    return
  endif

  echo printf('Git review %d/%d: %s', a:index + 1, len(a:files), a:files[a:index])
endfunction

" --- Git review helper: open file, diff it, and cleanup prior view ---------
function! s:OpenGitReviewAt(files, index) abort
  if empty(a:files) || a:index < 0 || a:index >= len(a:files)
    return
  endif

  let l:old_buf = bufnr('%')
  let l:target_file = a:files[a:index]
  let l:target = simplify(s:git_review.root . '/' . l:target_file)

  call s:CloseOtherDiffBuffer()
  execute 'edit ' . fnameescape(l:target)

  let s:git_review.current_file = l:target_file
  call s:GitDiffVerticalKeepLocal()

  if l:old_buf != bufnr('%')
    call s:CleanupReviewBuffer(l:old_buf)
  endif

  call s:EchoReviewPosition(a:files, a:index)
endfunction

" --- Git review helper: start a live multi-file diff session ---------------
function! s:StartGitReview() abort
  let l:root = s:GitRootForBuffer()
  if empty(l:root)
    echo 'Git review: current buffer is not in a git worktree'
    return
  endif

  let l:files = s:ChangedFiles(l:root)
  if empty(l:files)
    echo 'Git review: no changed files'
    return
  endif

  let s:git_review = {'root': l:root, 'current_file': ''}
  let l:index = s:FindReviewIndex(l:files, l:root)
  call s:OpenGitReviewAt(l:files, l:index)
endfunction

" --- Git review helper: step through the current changed-file set ----------
function! s:GitReviewStep(delta) abort
  let l:root = empty(s:git_review.root) ? s:GitRootForBuffer() : s:git_review.root
  if empty(l:root)
    echo 'Git review: current buffer is not in a git worktree'
    return
  endif

  let l:files = s:ChangedFiles(l:root)
  if empty(l:files)
    let s:git_review = {'root': l:root, 'current_file': ''}
    echo 'Git review: no changed files'
    return
  endif

  let s:git_review.root = l:root
  let l:index = s:FindReviewIndex(l:files, l:root)
  let l:next = (l:index + a:delta + len(l:files)) % len(l:files)
  call s:OpenGitReviewAt(l:files, l:next)
endfunction

" --- Git (vim-fugitive) ----------------------------------------------------
" Status: open fugitive status window
nnoremap <silent> <leader>gs :G<CR>

" Diff current file in a *vertical* split (forces vertical)
" nnoremap <silent> <leader>gd :vertical Gdiffsplit<CR>

" Diff current file in a *vertical* split, but keep cursor in the original
" (local) buffer window after the split.
nnoremap <silent> <leader>gd :call <SID>GitDiffVerticalKeepLocal()<CR>

" Multi-file git review session.
" Start the live review session at the current changed file (or first changed file).
nnoremap <silent> <leader>gD :call <SID>StartGitReview()<CR>

" Jump to the next changed file and open its vertical Fugitive diff.
nnoremap <silent> <leader>gn :call <SID>GitReviewStep(1)<CR>

" Jump to the previous changed file and open its vertical Fugitive diff.
nnoremap <silent> <leader>gp :call <SID>GitReviewStep(-1)<CR>

" Smart quit: delete the fugitive/old-revision side and keep the local file,
" regardless of which side you're on. Outside diff mode, just quits this window.
nnoremap <silent> <leader>gq :call <SID>CloseOtherDiffBuffer()<CR>

" Hard reset: turn off diff everywhere and equalize windows
nnoremap <silent> <leader>gQ :diffoff!<CR>:wincmd =<CR>

" Equalize all window sizes (handy after diffs or splits)
nnoremap <silent> <leader>g= :wincmd =<CR>

" Flip diff sides: rotate window layout (swap left/right or top/bottom),
" move cursor to the opposite pane, and re-equalize window sizes.
nnoremap <silent> <leader>gx <C-w>r<C-w>w<C-w>=

" Auto-equalize window sizes when working in diff mode
augroup DiffAutoEqualize
  autocmd!
  autocmd WinEnter * if &diff | wincmd = | endif
augroup END

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

" --- Airline: statusline + bufferline/tabline ------------------------------
" Enable the tabline extension so buffers show as a top "bufferline"
let g:airline#extensions#tabline#enabled = 1

" Show buffers, not Vim's actual tab pages, in the tabline
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tabs    = 0

" Show buffer numbers in the tabline (so you can use :b<number>)
let g:airline#extensions#tabline#buffer_nr_show = 1

" Nicer buffer labels: only the tail of the path, disambiguated when needed
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" Optional: use a theme that matches your colorscheme (you have solarized)
let g:airline_theme = 'solarized'

" Optional: powerline-style glyphs (if your font supports them)
let g:airline_powerline_fonts = 1

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
