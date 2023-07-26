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


" ==================== スペルチェック  ==================== "
augroup GitSpellCheck
    autocmd!
    autocmd FileType gitcommit setlocal spell
augroup END

" ==================== エンコーディング関連 ==================== "
set encoding=utf-8
set fileencodings=utf-8,euc-jp,iso-2022-jp,cp932,sjis
set fileformats=unix,dos,mac

" ==================== プラグイン ==================== "
call plug#begin('~/.config/nvim/plugged')

Plug 'vim-jp/vimdoc-ja'

" 編集支援
Plug 'machakann/vim-highlightedyank'
if exists('g:vscode')
else
  " インデント着色
  Plug 'nathanaelkane/vim-indent-guides'
endif
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

"--------------------------------------------------
" Nerdフォント・色
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/glyph-palette.vim'
" Git支援 
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'lambdalisue/gina.vim'
" FuzzyFinder
Plug 'junegunn/fzf', {'dir': '~/.fzf_bin', 'do': './install --all'}
Plug 'yuki-yano/fzf-preview.vim'
" Markdown プレビュー
Plug 'ellisonleao/glow.nvim', {'branch':'main'}
" タスクランナー
Plug 'thinca/vim-quickrun'
" 編集箇所リスト
Plug 'itchyny/vim-qfedit'
" アウトラインウィンドウ
Plug 'stevearc/aerial.nvim'

"https://zenn.dev/yano/articles/vim_frontend_development_2021
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ファイラ
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/fern-hijack.vim'

" シンタックスハイライト
Plug 'nvim-treesitter/nvim-treesitter'

" カラーテーマ
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

colorscheme nord

" -- vim-easymotion -----------------
" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)


" -- Airline SETTINGS -------------
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
nmap <C-p> <Plug>AirlineSelectPrevTab
nmap <C-n> <Plug>AirlineSelectNextTab


nnoremap [coc]    <Nop>
xnoremap [coc]    <Nop>
nmap     <leader>c   [coc]
xmap     <leader>c   [coc]


""" -- coc.nvim -----------------
let g:coc_global_extensions = ['coc-tsserver', 'coc-eslint8', 'coc-prettier', 'coc-git', 'coc-fzf-preview', 'coc-lists']

inoremap <silent> <expr> <C-Space> coc#refresh()
nnoremap <silent> K       :<C-u>call <SID>show_documentation()<CR>
nmap     <silent> [coc]l :<C-u>CocList<cr>
nmap     <silent> [coc]h :<C-u>call CocAction('doHover')<cr>
"スペースdfでDefinition
nmap     <silent> [coc]df <Plug>(coc-definition)
"スペースrfでReferences
nmap     <silent> [coc]rf <Plug>(coc-references)
"スペースrnでRename
nmap     <silent> [coc]rn <Plug>(coc-rename)
nmap     <silent> [coc]f :<C-u>CocCommand eslint.executeAutofix<CR>


" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <C-TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
command! -nargs=0 Fmt :call CocAction('format')


function! s:coc_typescript_settings() abort
  nnoremap <silent> <buffer> [coc]fmt :<C-u>CocCommand eslint.executeAutofix<CR>:CocCommand prettier.formatFile<CR>
endfunction

set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

augroup coc_ts
  autocmd!
  autocmd FileType typescript,typescriptreact,javascript call <SID>coc_typescript_settings()
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
noremap <leader>md :Glow<CR>

"" -- vim-quickrun -------------------
" 水平分割
let g:quickrun_config={'*': {'split':''}}
nnoremap <leader>rn :QuickRun<CR>

"" -- fzf-preview  ----------------------
nnoremap [fzf]     <Nop>
xnoremap [fzf]     <Nop>
nmap <leader>z  [fzf]
xmap <leader>z  [fzf]

"" fzf.vim --------------------------
" Ctrl+pでファイル検索を開く
" git管理されていれば:GFiles、そうでなければ:Filesを実行する
fun! FzfOmniFiles()
  let is_git = system('git status')
  if v:shell_error
    :Files
  else
    :GFiles
  endif
endfun
nnoremap <C-p> :call FzfOmniFiles()<CR>

" Ctrl+gで文字列検索を開く
" <S-?>でプレビューを表示/非表示する
command! -bang -nargs=* Rg
\ call fzf#vim#grep(
\ 'rg --column --line-number --hidden --ignore-case --no-heading --color=always '.shellescape(<q-args>), 1,
\ <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 3..'}, 'up:60%')
\ : fzf#vim#with_preview({'options': '--exact --delimiter : --nth 3..'}, 'right:50%:hidden', '?'),
\ <bang>0)
nnoremap <C-g> :Rg<CR>

" frでカーソル位置の単語をファイル検索する
nnoremap [fzf]r vawy:Rg <C-R>"<CR>
" frで選択した単語をファイル検索する
xnoremap [fzf]r y:Rg <C-R>"<CR>

" fbでバッファ検索を開く
nnoremap [fzf]b :Buffers<CR>
" fpでバッファの中で1つ前に開いたファイルを開く
nnoremap [fzf]p :Buffers<CR><CR>
" flで開いているファイルの文字列検索を開く
nnoremap [fzf]l :BLines<CR>
" fmでマーク検索を開く
nnoremap [fzf]m :Marks<CR>
" fhでファイル閲覧履歴検索を開く
nnoremap [fzf]h :History<CR>
" fcでコミット履歴検索を開く
nnoremap [fzf]c :Commits<CR>

" fzf with coc
nnoremap <silent> <C-p>  :<C-u>CocCommand fzf-preview.FromResources buffer project_mru project<CR>
nnoremap <silent> [fzf]s  :<C-u>CocCommand fzf-preview.GitStatus<CR>
nnoremap <silent> [fzf]gg :<C-u>CocCommand fzf-preview.GitActions<CR>
nnoremap <silent> [fzf]b  :<C-u>CocCommand fzf-preview.Buffers<CR>
nnoremap          [fzf]f  :<C-u>CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>
xnoremap          [fzf]f  "sy:CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"

nnoremap <silent> [fzf]q  :<C-u>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
nnoremap <silent> [fzf]rf :<C-u>CocCommand fzf-preview.CocReferences<CR>
nnoremap <silent> [fzf]d  :<C-u>CocCommand fzf-preview.CocDefinition<CR>
nnoremap <silent> [fzf]t  :<C-u>CocCommand fzf-preview.CocTypeDefinition<CR>
nnoremap <silent> [fzf]o  :<C-u>CocCommand fzf-preview.CocOutline --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>

"" -- fern -------------------------
let g:fern#renderer="nerdfont"
nnoremap <silent> <Leader>e :<C-u>Fern . -drawer -toggle -reveal=%<CR>
let g:fern#default_hidden=1
let g:fern#renderer#nerdfont#indent_markers=1
" colord Icon
" アイコンに色をつける
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

" Clever-f
let g:clever_f_ignore_case = 1

" -- treesitter ---------------------
lua <<EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "typescript",
    "javascript",
    "tsx",
    "python",
    "vue",
    "html",
    "haskell",
  },
  highlight = {
    enable = true,
  },
}
EOF

syntax on 
filetype indent on 
filetype plugin on  

" -- dps-dial ------------------------
nmap  <C-a>  <Plug>(dps-dial-increment)
nmap  <C-x>  <Plug>(dps-dial-decrement)
xmap  <C-a>  <Plug>(dps-dial-increment)
xmap  <C-x>  <Plug>(dps-dial-decrement)
xmap g<C-a> g<Plug>(dps-dial-increment)
xmap g<C-x> g<Plug>(dps-dial-decrement)

"cポップアップメニューの色変える
highlight Pmenu ctermbg=lightcyan ctermfg=black
highlight PmenuSel ctermbg=blue ctermfg=black
highlight PmenuSbar ctermbg=darkgray
highlight PmenuThumb ctermbg=lightgray
highlight Comment ctermfg=blue
highlight clear CursorLine

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

" indent_guides
let g:indent_guides_enable_on_vim_startup = 1"" git操作

" GitGutter --
" g]で前の変更箇所へ移動する
nnoremap g[ :GitGutterPrevHunk<CR>
" g[で次の変更箇所へ移動する
nnoremap g] :GitGutterNextHunk<CR>
" ghでdiffをハイライトする
nnoremap gh :GitGutterLineHighlightsToggle<CR>
" gpでカーソル行のdiffを表示する
nnoremap gp :GitGutterPreviewHunk<CR>
" 記号の色を変更する
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=blue
highlight GitGutterDelete ctermfg=red

"" 反映時間を短くする(デフォルトは4000ms)
set updatetime=250
