""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 検索設定
set incsearch
set ignorecase
set smartcase
set wrapscan
set hlsearch

" UI/表示設定
set number
set ruler
set scrolloff=5
set termguicolors
set signcolumn=yes
set pumblend=10

" 動作設定
set mouse=a
set hidden
set belloff=all
set lazyredraw
set history=500
set backspace=indent,eol,start
set autoread
set vb t_vb=
set shortmess+=c
set complete+=k

" ファイル関連
set nobackup
set noswapfile

" ウィンドウ関連
set splitbelow
set splitright


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Indent & Tab Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set cindent

" 改行時のコメント継続を無効
set formatoptions-=o
set formatoptions-=r
set formatoptions+=m


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding & Filetype Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
set fileencodings=utf-8,euc-jp,iso-2022-jp,cp932,sjis
set fileformats=unix,dos,mac


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" リーダーキーをスペースに設定
let mapleader="\<Space>"

" ESC2回でハイライトを消す
nnoremap <silent><Esc><Esc> :noh<Return>

" 外部クリップボードをデフォルトに
set clipboard=unnamed,unnamedplus

" `x`キーで行削除してもレジスタに入れない
nnoremap x "_x
vnoremap x "_x

" `.`リピート可能にする
noremap <leader>p "0p
noremap <leader>P "0P

" 行末まで選択
vnoremap v $h

" 連続してインデント変更
vnoremap < <gv
vnoremap > >gv

" `j`/`k`で折り返し行を移動
nnoremap j gj
nnoremap k gk

" コマンドモードを`;`にマッピング
nnoremap ; :
vnoremap ; :

" `:w`, `quit`関連
nnoremap <C-s> :w<CR>
nnoremap <Space>q :<C-u>q!<Return>
nnoremap ZZ <ESC>:q!<CR>
inoremap ZZ <ESC>:q!<CR>

" バッファ移動
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>

" `init.vim`の再読み込みと編集
nnoremap <leader>sc :source ~/.config/nvim/init.vim<cr>
nnoremap <leader>in :e ~/.config/nvim/init.vim<cr>

" `jq`でjson整形
nnoremap <leader>jq :%!jq '.'<CR>

" 対応する括弧へのジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" インサートモードでの移動
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-h> <BS>
inoremap <C-d> <Del>
inoremap <C-l> <Right>

" 行頭・行末ジャンプ
nnoremap <C-h> ^
nnoremap <C-l> $
vnoremap <C-h> ^
vnoremap <C-l> $

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt=longest,menuone,preview

set wildmenu
set wildmode=longest,list,full

" `Coc`関連設定（※vim-plugのプラグインリスト内にある`coc.nvim`が有効な場合）
" `set hidden`は既に上記Generalに移動済み
" `set shortmess+=c`も既に上記Generalに移動済み
" `set signcolumn=yes`も既に上記Generalに移動済み


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins (vim-plug)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'vim-jp/vimdoc-ja'
Plug 'machakann/vim-highlightedyank'
Plug 'terryma/vim-multiple-cursors'
Plug 'rhysd/clever-f.vim'
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/vim-asterisk'
Plug 'haya14busa/vim-edgemotion'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-surround'
Plug 'monaqa/dps-dial.vim'
call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Custom Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set updatetime=250

" vim-easymotion
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" Clever-f
let g:clever_f_ignore_case = 1

" vim-asterisk
map * <Plug>(asterisk-z*)
map #  <Plug>(asterisk-z#)
map g* <Plug>(asterisk-gz*)
map g# <Plug>(asterisk-gz#)

" vim-adgemotion
map <C-j> <Plug>(edgemotion-j)
map <C-k> <Plug>(edgemotion-k)

" yank-highlit
let g:highlightedyank_highlight_duration = 150
