let plugins_config = 'plugins.vimrc'
let mappings_work = '${HOME}/REPOS/configs/vim/work.vim'
let markdown_color_mods = '${HOME}/REPOS/dotfiles/vim/config/MarkdownMods.vim'
let vimrc_colors = '${HOME}/.vim/vimrc.colors'
let td_file = '~/WIP/TD.md'

" => SOURCE PLUGINS
execute 'source ' . plugins_config

=> COC SETTINGS
" Plugins
let g:coc_global_extensions = ['coc-css', 'coc-emmet', 'coc-html', 'coc-tsserver', 'coc-prettier', 'coc-sh']
" Run prettier on save => filetypes are defined in CocConfig
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

" => COLORS
syntax enable

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" load color scheme from here
source ${HOME}/.vim/vimrc.colors

" Reload color settings when necessary
function! LoadColors()
  echo 'loading colors...'
  execute 'source ' . vimrc_colors
  " check filetypes => :set filetype?
  if &filetype ==# 'markdown'
    call MD()
  endif
endfun
nnoremap <C-l><C-c> :call LoadColors()<CR>

" => SETTINGS >> {{{

" GENERAL
set encoding=utf-8

set backupcopy=yes           " necessary for ParcelJS to work
set updatetime=100

set nocompatible
set wildmenu
set wildignorecase

set cursorline               " highlight cursor line
set colorcolumn=80           " mark 80 chars length"
set number                   " show line numbers
set laststatus=2             " always show status bar
set showtabline=2            " show tabs even if only one file is open (always!)
set showcmd                  " show typed commands below status bar
set matchpairs+=<:>          " highlight matching pairs of brackets
set title                    " show path in console window title bar

set splitright               " open splits on the right

set conceallevel=0           " conceallevel can be toggled (see functions)

if has("persistent_undo")
  set undofile               " persist undo
  set undodir=~/.vim/undodir " set dir to save undo files
endif


" CLIPBOARD
if has('macunix')
  set clipboard=unnamed        " set mac os system clipboard
else
  set clipboard=unnamedplus     " use system clipboard, requires vim-gtk on ubuntu
endif

set wrap                      " wrap words at window length
"set textwidth=80             " wrap at 80 characters, (mark line in visual mode and press `gq`)
set linebreak                 " wrap  words at word boundary
set breakindent               " keep indentation on line wrap

" INDENTATION
" filetype plugin indent on
set expandtab                 " on pressing tab, insert 2 spaces
set tabstop=2                 " show existing tab with 2 spaces width
set softtabstop=2             " when indenting with '>', use 2 spaces width
set shiftwidth=2

" SEARCH
set incsearch                 " enable incremental search
set shortmess-=S              " show num of hits below status bar
set ignorecase smartcase      " setting both: /The finds 'The', /the finds 'the' and 'The'
set hlsearch                  " highlight matching search patterns

set splitbelow              " open splits below current window

" FOLDMARKERS
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker " fold using foldmarkers in .vim files
augroup END

"}}}

" => MAPPINGS >> {{{
" -> Mappings triggering functions are in FUNCTIONS
"
let mapleader = ","
let maplocalleader = "<space>"

" Set time you have after pressing the leader key
set timeoutlen=500 " default: 1000

" Mappings used at work
execute 'source ' . mappings_work

" Map jk to ESC,
inoremap jk <ESC>
" Do the same for terminal mode
tnoremap jk <C-\><C-n>

" Remove Whitespace when in visual mode
vnoremap <leader>ww :s/\%V\s//g<CR>

" Remove highlighting
nnoremap <esc><esc> :silent! nohls<cr>

" Edit + source .vimrc
" check if runnig nvim before mapping keys
" => in nvim $MYVIMRC will be .config/nvim/init.vim
" However all settings for nvim are in this .vimrc, init only sources them
if has('nvim')
  nnoremap <leader>ev :tabedit ${HOME}/.vimrc<CR>
  nnoremap <leader>sv :source ${HOME}/.vimrc<CR>
else
  nnoremap <leader>ev :tabedit $MYVIMRC<CR>
  nnoremap <leader>sv :source $MYVIMRC<CR>
endif

" edit plugins.vimrc
nnoremap <leader>ep :vsplit <CR>

" wrap word in double or single quotes
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel

" wrap word in curly braces
nnoremap <leader>{ ciw{}<esc>h<esc>p
" wrap word in parentheses
nnoremap <leader>( ciw()<esc>h<esc>p
" wrap word in brackets
nnoremap <leader>[  ciw[]<esc>h<esc>p

" resize vert splits
map <c-n> <c-w><
map <c-m> <c-w>>

"Circle through buffers using Tab and Shift-Tab
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" map custom fns
nnoremap <leader>r :call ToggleLineNumber()<CR>
nnoremap <silent> <C-c><C-c> :ToggleCommentRepeat<CR>

"}}}

" => FUNCTIONS  >> {{{

" Toggle between relative + absolute line nums
function! ToggleLineNumber()
  set number relativenumber!
endfunction

" Toggle comment repeat
" If active (cro) new lines will be commented out automatically
command ToggleCommentRepeat if &fo =~ 'cro' | set fo-=cro | else | set fo+=cro | endif

" Switch off/on conceal
function! ToggleConcealLevel()
  if &conceallevel == 0
    setlocal conceallevel=2
  else
    setlocal conceallevel=0
  endif
endfunction
nnoremap <C-c><C-y> :call ToggleConcealLevel()<CR>

" Toggle ignoring whitespace in diff mode
if &diff
  function! IwhiteToggle()
    if &diffopt =~ 'iwhite'
      set diffopt-=iwhite
    else
      " remove `internal` because of some quirky vim on macOS behaviour
      set diffopt-=internal
      set diffopt+=iwhite
    endif
  endfunction

  map gs :call IwhiteToggle()<CR>
endif

" format json
function! Json()
  :%!python -m json.tool
endfun

" Disable coc autocompletions
function! ToggleCocCompletions()
  if !exists("b:coc_suggest_disable") || b:coc_suggest_disable == 0
    let b:coc_suggest_disable = 1
  else
    let b:coc_suggest_disable = 0
  endif
endfunction
noremap <leader>cc :call ToggleCocCompletions()<cr>

" Show highlighting groups for current word
" => helps with defining custom styles
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nmap <C-S-P> :call <SID>SynStack()<CR>
"}}}

" => ABBREVIATIOS >> {{{
" Lorem ipsum
" 24 words
iabbrev lorem1 Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

" 50 words
iabbrev lorem2 Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

" 100 words
iabbrev lorem3 Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
"}}}

" => MARKDOWN  >> {{{

function! MD()
  " colorize code blocks
  "let g:markdown_fenced_languages= ['vim', 'html', 'xhtml', 'xml', 'css', 'js=javascript', 'java',  'python', 'sh', 'bash=sh']
  let g:markdown_fenced_languages= ['css', 'javascript', 'sh', 'react']

  " use anchors to jump around in an md file
  source $HOME/REPOS/dotfiles/vim/config/md_links.py

  " MACROS
  " strike through markdown list items
  "let @d='0i jkf*lli~~jkA~~jk0x'
  " bold for markdown list items
  "let @b='0i jkf*lli**jkA**jk0x'
  let @b='0i jkf-lli**jkA**jk0x'

  " exchage < > for html entities &gt; + &lt;
  let @x=":%s/</\\&lt;/g\<CR>:%s/>/\\&gt;/g\<CR>"

  " CHECKBOXES
  " Create a markdown checkbox
  nnoremap <leader>bb o[]<ESC>a<space>
  nnoremap <leader>BB i[]<ESC>a<space>
  " Check checkbox
  nnoremap <leader>bd :s/\[\]/\[x\]/<CR>:nohls<CR>
  " Uncheck checkbox
  nnoremap <leader>bu :s/\[x\]/\[\]/<CR>
  " Highlight checkbox label as bold
  noremap <leader>bh 0f]wi**<esc>A**<esc>

  " open a file from a markdown link
  " map <leader>g <S-V>/\%V.md)<CR><ESC>gf

  " strike through everything (which is on one line)
  let @u='0xx$xx'

  " set color mods for markdown files
  execute 'source ' . markdown_color_mods

endfunction

" load markdown settings
autocmd BufEnter *.md call MD()

"}}}

"%%%%%%%%%%%%%%%%%%%%%%%
"%%% PLUGIN SETTINGS %%%
"%%%%%%%%%%%%%%%%%%%%%%%

" => NETRW  >> {{{
" let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrew_browse_split = 4
let g:netrw_winsize = 25
" Open in left split
" Open files in right split from here
noremap <leader>t :Lexplore<CR>

" Open file in a vertical split
function! OpenToRight()
  :normal v
  let g:path=expand('%:p')
  :q
  execute 'belowright vnew' g:path
  :normal <C-l>
endfunction
nnoremap <leader>V :execute OpenToRight()<CR>

function! NetrwCollapse()
  redir => cnt
  silent .s/|//gn
  redir END
  let lvl = substitute(cnt, '\n', '', '')[0:0] - 1
  exec '?^\(| \)\{' . lvl . '\}\w'
endfunction
" map x key to collapse parent folder
" OVERRIDES netrw's x mapping --> view file in associated program
autocmd filetype netrw nmap <buffer> x :call NetrwCollapse()<CR><CR>

"}}}

" => ALE  >> {{{
" define fixers for ale
let g:ale_fixers = {
      \   '*': ['trim_whitespace'],
      \   'javascript': ['prettier'],
      \   'typescript': ['prettier'],
      \   'typescriptreact': ['prettier'],
      \}

" use fixers on save
let g:ale_fix_on_save = 1

" ale comes with a build in completion system
let g:ale_completion_enabled = 1

" use different symbols for errors + warnings
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow
"}}}

" => EMMET >> {{{
" use emmet completion using <tab>,
" can be switched on and off with the custom command Em1/Em0
function! UseEmmet(flag)
  if a:flag == 1
    imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
    echo 'emmet completion activated'
  elseif a:flag == 0
    unmap! <tab>
    echo 'emmet completion deactivated'
  endif
endfunction

command! -nargs=* Em call UseEmmet(<f-args>)
nnoremap <leader>e :Em1<CR>i
"}}}

" => FZF >> {{{

" Position + height of fzf window
" - down / up / left / right
let g:fzf_height = '50%'
let g:fzf_layout = { 'down': g:fzf_height }

" search within files in a specific directory
" ex: :Rag "foo" GTK/
command! -bang -nargs=+ -complete=dir Rag call fzf#vim#ag_raw(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Don't search file names when looking for content in files
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" search for files
nnoremap <leader>f :FZF<CR>
" use Ag to search within files
noremap <leader>ff :Ag<CR>
" use fugitive to see commits
noremap <leader>fc :Commits<CR>
" list tags
noremap <leader>ft :Tags<CR>
"}}}

" => GIT GUTTER >> {{{
" move from hunk to hunk
nmap ( <Plug>(GitGutterNextHunk)
nmap ( <Plug>(GitGutterPrevHunk)

nmap gu <Plug>(GitGutterUndoHunk)
nmap gp <Plug>(GitGutterPreviewHunk)

" always show signcolumn, even if there is no git info
set signcolumn=yes
" set git gutter to always be on
let g:gitgutter_enabled=1
" do not use any of git gutters default key maps
let g:gitgutter_map_keys=0
"}}}

" => LIGHTLINE >> {{{

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'bufferNo', 'filename', 'modified' ] ],
      \ },
      \ 'component': {
      \   'bufferNo': 'b%n',
      \ },
      \ }

"}}}


"%%%%%%%%%%%%%%%%%%%%%%%%
"%%%  WIP, GTK, TD.md %%%
"%%%%%%%%%%%%%%%%%%%%%%%%
" This is a set of fns + shortcuts
" to navigate files which I use
" to store coding snippets, to do lists and other text files

" => GTK >> {{{
function! SearchGTK()
  :vsp
  :lcd ${HOME}/GTK/
  :Ag
endfunction

function! FZF_GTK()
  :vsp
  :lcd ${HOME}/GTK/
  :Files
endfunction

command! Gtk call SearchGTK()
nnoremap <leader>GG :Gtk<CR>
nnoremap <leader>G :vsp<CR>:lcd ${HOME}/GTK/<CR>:FZF<CR>

"}}}

" => ToDo stuff td.md >> {{{
" open general TD
nnoremap <leader>ed :tabedit td_file<CR>

" SHORTCUTS
function! TDShortcuts()
  map <leader>1 /## DOING (3)<CR><ESC><ESC>
  map <leader>2 /## \<DO\><CR><ESC><ESC>
  " map <leader>3 /## PROJECTS<CR><ESC><ESC>
  map <leader>3 /## BACKLOG<CR><ESC><ESC>
  map <leader>4 /## DONE<CR><ESC><ESC>
endfunction
autocmd BufEnter TD.md call TDShortcuts()

"}}}

"%%%%%%%%%%%%%%%%%%%%%%%%
"%%% EXPERIMENTS      %%%
"%%%%%%%%%%%%%%%%%%%%%%%%

" treat underscores as a new word
set iskeyword-=_
" treat hyphen as a new word
set iskeyword-='-'

highlight jsCommentTodo guibg=#f000ff guifg=#feeeee

" insert completions with tab => used primarily for emmet completions
inoremap <expr> <TAB> pumvisible() ? "\<C-y>" : "\<C-g>u\<TAB>"

" Show IndentLines
noremap <silent><leader>l :IndentLinesToggle<CR>

" set shiftwidth to two spaces
noremap <leader>2 :set shiftwidth=2<cr>
