"#######################
" plugin(dein)
"#######################
let $CACHE = expand('~/.cache')
if !($CACHE->isdirectory())
  call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
  let s:dir = 'dein.vim'->fnamemodify(':p')
  if !(s:dir->isdirectory())
    let s:dir = $CACHE .. '/dein/repos/github.com/Shougo/dein.vim'
    if !(s:dir->isdirectory())
      execute '!git clone https://github.com/Shougo/dein.vim' s:dir
    endif
  endif
  execute 'set runtimepath^='
        \ .. s:dir->fnamemodify(':p')->substitute('[/\\]$', '', '')
endif

set nocompatible

" Set dein base path (required)
let s:dein_base = '~/.cache/dein/'

" Set dein source path (required)
let s:dein_src = '~/.cache/dein/repos/github.com/Shougo/dein.vim'

" Set dein runtime path (required)
execute 'set runtimepath+=' .. s:dein_src

" Call dein initialization (required)
call dein#begin(s:dein_base)

call dein#add(s:dein_src)

" Your plugins go here:
call dein#add('altercation/vim-colors-solarized')
call dein#add('thinca/vim-quickrun')

" Finish dein initialization (required)
call dein#end()

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
if has('syntax')
  syntax on
endif

if dein#check_install()
  call dein#install()
endif

"#######################
" 表示系
"#######################
set number "行番号表示
set showmode "モード表示
set title "編集中のファイル名を表示
set ruler "ルーラーの表示
set showcmd "入力中のコマンドをステータスに表示する
set showmatch "括弧入力時の対応する括弧を表示
set laststatus=0 "ステータスラインを常に表示
syntax enable
if system('uname') == "Darwin\n"
  set background=dark
  colorscheme solarized
endif

"#######################
" プログラミングヘルプ系
"#######################
set cindent "オートインデント
set expandtab "タブの代わりに空白文字挿入
set ts=2 sw=2 sts=0 "タブは半角4文字分のスペース
" ファイルを開いた際に、前回終了時の行で起動
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

"#######################
" 検索系
"#######################
set ignorecase "検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase "検索文字列に大文字が含まれている場合は区別して検索する
"set wrapscan "検索時に最後まで行ったら最初に戻る
set noincsearch "検索文字列入力時に順次対象文字列にヒットさせない
set hlsearch "検索語を強調表示

"#######################
" コマンド系
"#######################
set wildmenu "コマンドライン補完を便利に
set showcmd "タイプ途中のコマンドを画面最下行に表示
set cmdheight=1 "コマンドラインの高さを2行に

"#######################
" 入力系
"#######################
set backspace=indent,eol,start "バックスペースでインデント、改行の削除
set whichwrap=b,s,h,l,[,],<,> "カーソルで行頭・行末移動

"#######################
" ウインドウ系 
"#######################
set splitright
set splitbelow

"#######################
" その他
"#######################
set confirm "バッファが変更されているとき、保存するか確かめる
set visualbell "ビープの代わりにビジュアルベルを使う
set t_vb= "ビジュアルベル無効
set mouse=a "全モードでマウス有効
set termencoding=utf-8
set formatoptions=l
set nobackup
set noswapfile
set noundofile

let OSTYPE = system('uname')
if OSTYPE == "Darwin\n"
  set clipboard=unnamed,autoselect "ヤンクした時にクリップボードにコピー
elseif OSTYPE == "Linux\n"
  set clipboard=unnamedplus
endif

"#######################
" syntax 
"#######################
let java_highlight_all = 1

"#######################
" Keymap
"#######################
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
noremap <C-h> ^
noremap <C-l> $
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap    [unite]   <Nop>
nnoremap suf :<C-u>UniteWithBufferDir file<CR>
nnoremap sum :<C-u>Unite<Space>file_mru<CR>

