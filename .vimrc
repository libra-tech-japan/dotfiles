""""""""""""""""""
"""   .vimrc   
""""""""""""""""""
set incsearch
set ignorecase
set wrapscan
set hlsearch
set smartcase

set ruler
set number
set clipboard+=unnamedplus
set scrolloff=5

" 動作環境との統合
" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus

"screen利用時設定
set ttymouse=xterm2

" マウスの入力を受け付ける
set mouse=a

" ビープ音を消す"
set belloff=all

" <Space>q で強制終了
nnoremap <Space>q :<C-u>q!<Return>

" ESC*2 でハイライトやめる
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return>

"tab/indentの設定
set shellslash
set expandtab "タブ入力を複数の空白入力に置き換える
set tabstop=4 "画面上でタブ文字が占める幅
set shiftwidth=4 "自動インデントでずれる幅
set softtabstop=2 "連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent "改行時に前の行のインデントを継続する
set smartindent "改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set cindent

" リーダー設定"
let mapleader="\<Space>"

" reload vimrc
nnoremap <leader><leader> :source ~/.ideavimrc<cr>
"  上書き保存"
nnoremap <C-s> :w<CR>

"x キー削除でデフォルトレジスタに入れない
nnoremap x "_x
vnoremap x "_x

"vv で行末まで選択
vnoremap v ^$h

"選択範囲のインデントを連続して変更
vnoremap < <gv
vnoremap > >gv

"インサートモードで bash 風キーマップ
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-h> <BS>
inoremap <C-d> <Del>

" j, k による移動を折り返されたテキストでも自然に振る舞うように変更
nnoremap j gj
nnoremap k gk

" vを二回で行末まで選択
vnoremap v $h

" TABにて対応ペアにジャンプ
nnoremap &lt;Tab&gt; %
vnoremap &lt;Tab&gt; %


" 入力モード中に素早くJJと入力した場合はESCとみなす
inoremap jj <ESC>:set iminsert=0<CR>
inoremap <ESC> <ESC>:set iminsert=0<CR>

set shellslash              " Windowsでディレクトリパスの区切り文字に / を使えるようにする
set lazyredraw              " マクロなどを実行中は描画を中断
set complete+=k             " 補完に辞書ファイル追加
set history=500

" 入力補助
set backspace=indent,eol,start " バックスペースでなんでも消せるように
set formatoptions+=m           " 整形オプション，マルチバイト系を追加
" 補完
set completeopt=longest,menuone,preview

" コマンド補完
set wildmenu           " コマンド補完を強化
set wildmode=longest,list,full " リスト表示，最長マッチ

" ファイル関連
set nobackup   " バックアップ取らない
set autoread   " 他で書き換えられたら自動で読み直す
set noswapfile " スワップファイル作らない
set hidden     " 編集中でも他のファイルを開けるようにする

" ビープ音除去
set vb t_vb=

" ウィンドウ関連
set splitbelow
set splitright

" ==================== カラー ==================== "
colorscheme default          " カラースキーム
syntax on " シンタックスカラーリングオン
filetype indent on " ファイルタイプによるインデントを行う
filetype plugin on " ファイルタイプごとのプラグインを使う
" ポップアップメニューの色変える
"highlight Pmenu ctermbg=lightcyan ctermfg=black
"highlight PmenuSel ctermbg=blue ctermfg=black
"highlight PmenuSbar ctermbg=darkgray
"highlight PmenuThumb ctermbg=lightgray
highlight Comment ctermfg=blue

" 行番号のハイライト
highlight clear CursorLine


" ==================== エンコーディング関連 ==================== "
set encoding=utf-8
set fileencodings=utf-8,euc-jp,iso-2022-jp,cp932,sjis
set fileformats=unix,dos,mac


