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
set clipboard+=unnamedplus
set scrolloff=5

" 動作環境との統合
" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus


" マウスの入力を受け付ける
set mouse=a

" ビープ音を消す"
set belloff=all


" ESC*2 でハイライトやめる
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch<Return>

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
nnoremap <leader><leader> :source ~/.config/nvim/init.vim<cr>
nnoremap <leader>i :e ~/.config/nvim/init.vim<cr>
"  上書き保存"
nnoremap <C-s> :w<CR>
" 上書きしないで終了
nnoremap <Space>q :<C-u>q!<Return>

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
nnoremap <Tab> %
vnoremap <Tab> %

" 括弧補完 プラグイン対応へ
"inoremap { {}<Left>
"inoremap {<Enter> {}<Left><CR><ESC><S-o>
"inoremap ( ()<ESC>i
"inoremap (<Enter> ()<Left><CR><ESC><S-o>

" 入力モード中に素早くJJと入力した場合はESCとみなす
inoremap jj <ESC>
inoremap ZZ <ESC>:wq!<CR>

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


" ==================== プラグイン ==================== "
call plug#begin('~/.config/nvim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'terryma/vim-multiple-cursors'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-commentary'
Plug 'vim-jp/vimdoc-ja'
Plug 'junegunn/fzf', {'dir': '~/.fzf_bin', 'do': './install --all'}
Plug 'ellisonleao/glow.nvim', {'branch':'main'}
Plug 'tpope/vim-fugitive'
Plug 'jiangmiao/auto-pairs'

" https://zenn.dev/yano/articles/vim_frontend_development_2021
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/fern-hijack.vim'
Plug 'lambdalisue/glyph-palette.vim'
Plug 'yuki-yano/fzf-preview.vim'
Plug 'lambdalisue/gina.vim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'sainnhe/sonokai'
Plug 'sainnhe/gruvbox-material'

call plug#end()


" -- vim-sasymotion -----------------
" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)


" -- NERDTree SETTINGS --------------
" nmap <C-f> :NERDTreeToggle<CR>

" -- Airline SETTINGS -------------
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
nmap <C-p> <Plug>AirlineSelectPrevTab
nmap <C-n> <Plug>AirlineSelectNextTab


nnoremap [dev]    <Nop>
xnoremap [dev]    <Nop>
nmap     m        [dev]
xmap     m        [dev]
nnoremap [ff]     <Nop>
xnoremap [ff]     <Nop>
nmap     z        [ff]
xmap     z        [ff]


"" -- coc.nvim -----------------
let g:coc_global_extensions = ['coc-tsserver', 'coc-eslint8', 'coc-prettier', 'coc-git', 'coc-fzf-preview', 'coc-lists']

inoremap <silent> <expr> <C-Space> coc#refresh()
nnoremap <silent> K       :<C-u>call <SID>show_documentation()<CR>
nmap     <silent> [dev]rn <Plug>(coc-rename)
nmap     <silent> [dev]a  <Plug>(coc-codeaction-selected)iw

function! s:coc_typescript_settings() abort
  nnoremap <silent> <buffer> [dev]f :<C-u>CocCommand eslint.executeAutofix<CR>:CocCommand prettier.formatFile<CR>
endfunction

set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

augroup coc_ts
  autocmd!
  autocmd FileType typescript,typescriptreact call <SID>coc_typescript_settings()
augroup END

function! s:show_documentation() abort
  if index(['vim','help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  elseif coc#rpc#ready()
    call CocActionAsync('doHover')
  endif
endfunction

"" -- glow         ----------------------
let g:glow_border = "rounded"
noremap <leader>p :Glow<CR>

"" -- fzf-preview  ----------------------
let $BAT_THEME                     = 'gruvbox-dark'
let $FZF_PREVIEW_PREVIEW_BAT_THEME = 'gruvbox-dark'

nnoremap <silent> <C-p>  :<C-u>CocCommand fzf-preview.FromResources buffer project_mru project<CR>
nnoremap <silent> [ff]s  :<C-u>CocCommand fzf-preview.GitStatus<CR>
nnoremap <silent> [ff]gg :<C-u>CocCommand fzf-preview.GitActions<CR>
nnoremap <silent> [ff]b  :<C-u>CocCommand fzf-preview.Buffers<CR>
nnoremap          [ff]f  :<C-u>CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>
xnoremap          [ff]f  "sy:CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"

nnoremap <silent> [ff]q  :<C-u>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
nnoremap <silent> [ff]rf :<C-u>CocCommand fzf-preview.CocReferences<CR>
nnoremap <silent> [ff]d  :<C-u>CocCommand fzf-preview.CocDefinition<CR>
nnoremap <silent> [ff]t  :<C-u>CocCommand fzf-preview.CocTypeDefinition<CR>
nnoremap <silent> [ff]o  :<C-u>CocCommand fzf-preview.CocOutline --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>

"" -- fern -------------------------
let g:fern#renderer="nerdfont"
nnoremap <silent> <Leader>e :<C-u>Fern . -drawer<CR>
nnoremap <silent> <Leader>E :<C-u>Fern . -drawer -reveal=%<CR>
" colord Icon
" アイコンに色をつける
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

"" -- treesitter ---------------------
lua <<EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "typescript",
    "tsx",
  },
  highlight = {
    enable = true,
  },
}
EOF

"" -- sonokai -------------------
colorscheme sonokai
