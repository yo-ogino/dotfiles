set nocompatible "vi非互換モード

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
set cursorline

"#######################
" プログラミングヘルプ系
"#######################
syntax on "カラー表示
set smartindent "オートインデント
set expandtab "タブの代わりに空白文字挿入
set ts=2 sw=2 sts=0 "タブは半角4文字分のスペース
" ファイルを開いた際に、前回終了時の行で起動
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
set autoindent

"#######################
" 検索系
"#######################
set ignorecase "検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase "検索文字列に大文字が含まれている場合は区別して検索する
set wrapscan "検索時に最後まで行ったら最初に戻る
set noincsearch "検索文字列入力時に順次対象文字列にヒットさせない
set nohlsearch "検索結果文字列の非ハイライト表示
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
set whichwrap=b,s,[,],<,> "カーソルで行頭・行末移動

"#######################
" ウインドウ系 
"#######################
set splitbelow
set splitright

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
"inoremap <silent> jj <ESC>
"inoremap <silent> <C-j> <ESC>
"nnoremap <silent> <C-j> <Nop>
"noremap <CR> i<CR><ESC><Right>
"noremap <BS> i<BS><ESC><Right>
noremap <C-h> ^
noremap <C-l> $

"#######################
"NeoBundle
"#######################
filetype plugin indent off                   " required!

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'ZenCoding.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'ZenCoding.vim'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'kchmck/vim-coffee-script'

filetype plugin indent on

"#######################
" color
"#######################
syntax enable
if system('uname') == "Darwin\n"
  set background=light
  colorscheme solarized
  "colorscheme molokai
endif

