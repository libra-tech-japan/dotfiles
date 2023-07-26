""""""""""""""""""
"""   .vimrc   
""""""""""""""""""
set incsearch
set ignorecase
set wrapscan
set hlsearch
set smartcase
set pumblend=10
set termguicolors
set ruler
set number
set scrolloff=5
" Coc ----
set hidden
set shortmess+=c
set signcolumn=yes


" 動作環境との統合
" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus

" マウスの入力を受け付ける
set mouse=a

" ビープ音を消す"
set belloff=all

" ESC*2 でハイライトやめる
nnoremap <silent><Esc><Esc> :noh<Return>
" 改行時のコメント継続無効
set formatoptions-=o
set formatoptions-=r

"tab/indentの設定
set expandtab "タブ入力を複数の空白入力に置き換える
set tabstop=2 "画面上でタブ文字が占める幅
set shiftwidth=2 "自動インデントでずれる幅
set softtabstop=2 "連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent "改行時に前の行のインデントを継続する
set smartindent "改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set cindent

" リーダー設定"
let mapleader="\<Space>"

" コマンドモードへ;も利用可とする
nnoremap ; :
vnoremap ; :

" reload vimrc
nnoremap <leader>sc :source ~/.config/nvim/init.vim<cr>
nnoremap <leader>in :e ~/.config/nvim/init.vim<cr>

"x キー削除でデフォルトレジスタに入れない
nnoremap x "_x
vnoremap x "_x

"0レジスタ
noremap <leader>p "0p
noremap <leader>P "0P

"vv で行末まで選択
vnoremap v $h

"選択範囲のインデントを連続して変更
vnoremap < <gv
vnoremap > >gv

"インサートモードで bash 風キーマップ
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-h> <BS>
inoremap <C-d> <Del>

inoremap <C-l> <Right>

" j, k による移動を折り返されたテキストでも自然に振る舞うように変更
nnoremap j gj
nnoremap k gk

" 行頭・行末ジャンプ
nnoremap <C-h> ^
nnoremap <C-l> $
vnoremap <C-h> ^
vnoremap <C-l> $


" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" 入力モード中に素早くjj jkと入力した場合はESCとみなす
inoremap <silent>jj <ESC>
inoremap <silent>jk <ESC>

"  上書き保存"
nnoremap <C-s> :w<CR>
" 上書きしないで終了
nnoremap <Space>q :<C-u>q!<Return>
inoremap ZZ <ESC>:q!<CR>
nnoremap ZZ <ESC>:q!<CR>

" バッファ移動
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>

" json成型（jqコマンド）
nnoremap <leader>jq :%!jq '.'<CR>


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



" ==================== エンコーディング関連 ==================== "
set encoding=utf-8
set fileencodings=utf-8,euc-jp,iso-2022-jp,cp932,sjis
set fileformats=unix,dos,mac

" ==================== プラグイン ==================== "
call plug#begin('~/.config/nvim/plugged')

Plug 'vim-jp/vimdoc-ja'

" 編集支援
Plug 'machakann/vim-highlightedyank'
" 複数行同時編集
Plug 'terryma/vim-multiple-cursors'
" 検索・移動支援
Plug 'rhysd/clever-f.vim'
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/vim-asterisk'
Plug 'haya14busa/vim-edgemotion'
" コメント
Plug 'tpope/vim-commentary'
" 括弧補完
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-surround'
" C-a C-x拡張(その依存プラグイン )
Plug 'monaqa/dps-dial.vim'
Plug 'vim-denops/denops.vim'


call plug#end()


" -- vim-easymotion -----------------
" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)


" Clever-f
let g:clever_f_ignore_case = 1


" vim-asterisk
map *  <Plug>(asterisk-z*)
map #  <Plug>(asterisk-z#)
map g* <Plug>(asterisk-gz*)
map g# <Plug>(asterisk-gz#)

" vim-adgemotion
map <C-j> <Plug>(edgemotion-j)
map <C-k> <Plug>(edgemotion-k)

" yank-highlit
let g:highlightedyank_highlight_duration = 150


" 反映時間を短くする(デフォルトは4000ms)
set updatetime=250
