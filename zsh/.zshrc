# Zsh設定ファイル（フレームワーク排除、軽量化）

# ============================================================================
# 基本設定
# ============================================================================
export TERM=xterm-256color

# --- AI & Non-interactive Guard ---
# 非対話モード、またはAIエージェントからの実行時は、カスタマイズを読み込まず終了
if [[ $- != *i* ]] || [[ "$TERM" == "dumb" ]]; then
  return
fi

# 履歴設定
# XDGの履歴ディレクトリは対話シェルで作成（非対話の副作用を回避）
if [[ ! -d "${XDG_DATA_HOME}/zsh" ]]; then
  mkdir -p "${XDG_DATA_HOME}/zsh"
fi
HISTFILE="${XDG_DATA_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt HIST_VERIFY

# 補完設定
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump-$ZSH_VERSION"

# 対話シェルでコメントを有効化
setopt interactive_comments

# ============================================================================
# ツール初期化
# ============================================================================

# --- dotfiles self-heal (コンテナ・対話シェルのみ) ---
# 生 docker / docker compose（devcontainer 非依存）では home リセットで ~/.config 等の
# symlink が消える。~/dotfiles はあるのにリンクが欠落している時だけ、links-only の
# 高速再リンク（install.sh --container --relink）で自己修復する。brew は走らせない。
# - 非対話ガードより後なので AI / CI / 非対話では実行されない。
# - 健全時は数回の stat（-L 判定）だけでほぼ無コスト。欠落時のみ relink。
# - 初回展開は scripts/container-bootstrap.sh を使う（こちらは復旧専用）。
# - DOTFILES_NO_SELF_HEAL=1 で無効化。
if [[ -z "${DOTFILES_NO_SELF_HEAL:-}" ]] \
   && { [[ -n "$REMOTE_CONTAINERS" ]] || [[ -f "/.dockerenv" ]]; } \
   && [[ -d "$HOME/dotfiles/.git" ]] && command -v stow &>/dev/null \
   && [[ ! -L "$HOME/.config/nvim" ]]; then
  echo "🔗 dotfiles: restoring links..."
  "$HOME/dotfiles/install.sh" --container --relink || true
fi

# --- Context-Aware Runtime Strategy ---

# カレントまたは親ディレクトリに mise.toml があるか判定
_has_mise_toml() {
  local d="${1:-$PWD}"
  while [[ -n "$d" && "$d" != "/" ]]; do
    [[ -f "$d/mise.toml" ]] && return 0
    d="${d%/*}"
  done
  return 1
}

# 1. Container Strategy — 起動時・cd 後に _apply_mise_container_strategy で適用（下記参照）
# mise.toml があるときは MISE_DISABLE_TOOLS を unset し、[tools] の node/python を使う。

# 2. Volta Strategy (Client Environment)
# Voltaがインストールされている場合、Node管理権限をVoltaに委譲する
if command -v volta &> /dev/null; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"

  # MiseはPython等のために起動させるが、Nodeは Volta 管理下の system を使う
  export MISE_DISABLE_TOOLS="node"

# 3. Mise Strategy (Home Environment)
# 上記以外(Mac等)では、Miseが全権を掌握する (特別な設定不要)
fi

# Linuxbrew bin（.zshenv と同じ判定）
_linuxbrew_bin_dir() {
  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    echo "/home/linuxbrew/.linuxbrew/bin"
  elif [[ -d "$HOME/.linuxbrew/bin" ]]; then
    echo "$HOME/.linuxbrew/bin"
  fi
}

# PATH 先頭にディレクトリを置く（既存エントリは除去してから先頭へ）
_prepend_path_dir() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return
  local -a parts
  parts=("${(@s.:.)PATH}")
  parts=(${parts:#$dir})
  export PATH="${dir}:${(j.:.)parts}"
}

# mise が有効なツールを PATH 先頭へ（hook-env だけでは linuxbrew が勝つ場合の保険）
_prepend_mise_tool_bin_to_path() {
  local tool="$1" bin_dir
  if [[ -n "${MISE_DISABLE_TOOLS:-}" ]] && [[ ",${MISE_DISABLE_TOOLS}," == *",${tool},"* ]]; then
    return
  fi
  bin_dir=$(command mise which "$tool" 2>/dev/null) || return
  bin_dir="${bin_dir:h}"
  _prepend_path_dir "$bin_dir"
}

# コンテナ内: カレント $PWD に mise.toml が無いときだけ Homebrew の node/python を優先
_apply_mise_container_strategy() {
  if [[ -z "$REMOTE_CONTAINERS" && ! -f "/.dockerenv" ]]; then
    return
  fi
  if _has_mise_toml 2>/dev/null; then
    unset MISE_DISABLE_TOOLS MISE_NODE_VERSION MISE_PYTHON_VERSION 2>/dev/null
  else
    unset MISE_NODE_VERSION MISE_PYTHON_VERSION 2>/dev/null
    export MISE_DISABLE_TOOLS="node,python"
  fi
  if command -v mise &>/dev/null; then
    eval "$(mise hook-env -s zsh 2>/dev/null)" || true
  fi
  if _has_mise_toml 2>/dev/null; then
    _prepend_mise_tool_bin_to_path node
    _prepend_mise_tool_bin_to_path python
  else
    local brew_bin
    brew_bin=$(_linuxbrew_bin_dir)
    _prepend_path_dir "$brew_bin"
  fi
}
if [[ -n "$REMOTE_CONTAINERS" ]] || [[ -f "/.dockerenv" ]]; then
  chpwd_functions+=(_apply_mise_container_strategy)
fi

# mise (asdf互換のランタイム管理)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
  # 起動時の $PWD にも適用（cd せずにワークスペースで開いた場合を含む）
  _apply_mise_container_strategy
fi

# npm グローバル bin を PATH に追加（devcontainer CLI / ni 等のグローバル CLI を使えるように）
# mise 等は cd ごとに node を切り替えるため、chpwd でも再評価してディレクトリに依存しないようにする。
# 注: `npm bin -g` は npm 9 で削除されたため使えない（常に空を返し PATH に何も足さなくなる）。
#     現行 npm では `npm prefix -g`/bin が旧 `npm bin -g` と等価。
#     npm 実体パスが変わらない限り prefix をキャッシュし、chpwd ごとの node 起動コストを避ける。
typeset -g _NPM_GLOBAL_BIN_NPM=""   # 最後に評価した npm 実体パス
typeset -g _NPM_GLOBAL_BIN_DIR=""   # その npm のグローバル bin（$prefix/bin）
_add_npm_global_bin_to_path() {
  local npm_path
  npm_path=$(command -v npm 2>/dev/null) || return
  if [[ "$npm_path" != "$_NPM_GLOBAL_BIN_NPM" ]]; then
    local npm_prefix
    npm_prefix=$(npm prefix -g 2>/dev/null) || return
    _NPM_GLOBAL_BIN_NPM="$npm_path"
    _NPM_GLOBAL_BIN_DIR="${npm_prefix:+$npm_prefix/bin}"
  fi
  local npm_bin="$_NPM_GLOBAL_BIN_DIR"
  if [[ -n "$npm_bin" && -d "$npm_bin" && ":$PATH:" != *":$npm_bin:"* ]]; then
    export PATH="${PATH}:${npm_bin}"
  fi
}
_add_npm_global_bin_to_path
chpwd_functions+=(_add_npm_global_bin_to_path)

# starship プロンプト
if command -v starship &> /dev/null; then
  # コンテナ内は緑系パレットに切り替える（表示要素は共通、色のみ）。
  # ~/.config/starship.toml の palette 行だけ 'green' に差し替えた派生設定をキャッシュに生成し、
  # それを STARSHIP_CONFIG で指す。ホストは既定（tokyo）の設定をそのまま使う。
  if { [[ -n "$REMOTE_CONTAINERS" ]] || [[ -f "/.dockerenv" ]]; } && [[ -f "$HOME/.config/starship.toml" ]]; then
    _ss_src="$HOME/.config/starship.toml"
    _ss_gen="${XDG_CACHE_HOME:-$HOME/.cache}/starship/container.toml"
    if [[ ! -f "$_ss_gen" || "$_ss_src" -nt "$_ss_gen" ]]; then
      mkdir -p "${_ss_gen:h}"
      sed "s/^palette = .*/palette = 'green'/" "$_ss_src" > "$_ss_gen"
    fi
    export STARSHIP_CONFIG="$_ss_gen"
    unset _ss_src _ss_gen
  fi
  eval "$(starship init zsh)"
fi

# zoxide (cdの代替)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# ============================================================================
# エイリアス: ツール置き換え
# ============================================================================

# ls -> eza
if command -v eza &> /dev/null; then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias lt='eza --tree --level=2 --icons --git'      # 基本のTree表示
  alias ltt='eza --tree --level=4 --icons --git'     # 深い階層まで見る
  alias lta='eza --tree --level=2 --icons --git -a'  # 全て見る
fi

# cat -> bat
if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# grep -> ripgrep
if command -v rg &> /dev/null; then
  alias grep='rg'
fi

# vim系 -> nvim
if command -v nvim &> /dev/null; then
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
fi


# ============================================================================
# エイリアス: 機能ショートカット
# ============================================================================

# zshrc の再読み込み
alias src='source ~/.zshrc'

# tmuxinator の短縮
if command -v tmuxinator &> /dev/null; then
  alias mux="tmuxinator"
  alias m="mux agent"
fi

# Git エイリアス
if command -v git &> /dev/null; then
  alias g='git'
  alias ga='git add .'
  alias gau='git add -u'
  alias gc='git commit -v'
  alias gca='git commit --amend'
  alias gcm='git commit -m'
  alias gp='git push'
  alias gps='gp'
  alias gpf='git push --force-with-lease'
  alias gl='git lg'
  alias gs='git status'
  alias gst='gs'
  alias gd='git diff'
fi

# Lazygit エイリアス
if command -v lazygit &> /dev/null; then
  alias lg='lazygit'
fi

# Claude Code
if command -v claude &> /dev/null; then
  alias cc='claude'
  alias yolo="cc --dangerously-skip-permissions"
fi

# Docker
if command -v docker &> /dev/null; then
  alias d='docker'
  alias dps='docker ps'
  alias dpsa='docker ps -a'
  alias dex='docker exec -it'        # dex コンテナ名 bash
  alias dlogs='docker logs -f'       # dlogs コンテナ名
  alias dstop='docker stop'
  alias drm='docker rm'
  alias dri='docker rmi'

  alias dc='docker compose'          # docker-compose より新しい書き方
  alias dcu='docker compose up -d'
  alias dcd='docker compose down'
  alias dcr='docker compose restart'
  alias dcl='docker compose logs -f'
  alias dcps='docker compose ps'


  alias ddf='docker system df'       # ディスク使用量
  alias dstats='docker stats --no-stream'
  # 使っていないリソースを全部消す（volumeは除く）
  alias dprune='docker system prune -f'
  # 停止中含む全コンテナを削除
  alias drmall='docker rm $(docker ps -aq)'
  # タグなしイメージを一括削除
  alias dclean='docker image prune -f'
fi


# ============================================================================
# 関数定義
# ============================================================================

# --- DevContainer 関数（devcontainer コマンドがある場合のみ定義）---
if command -v devcontainer &> /dev/null; then
  # dotfiles リポジトリの既定値。環境変数 DOTFILES_REPO で上書きできる。
  # 各 dev* 関数の第2引数 [repo] でも上書き可能（優先度: 引数 > DOTFILES_REPO > 既定）。
  : ${DOTFILES_REPO:="https://github.com/libra-tech-japan/dotfiles"}

  # dotfiles 注入オプションを reply 配列に組み立てる（URL の唯一の生成点）。
  # 第1引数があれば優先、無ければ $DOTFILES_REPO を使う。devup / devrebuild が共用。
  function _build_dotfiles_opts() {
    local repo="${1:-$DOTFILES_REPO}"
    reply=(
      --dotfiles-repository "$repo"
      --dotfiles-target-path "~/dotfiles"
      --dotfiles-install-command "./install-container.sh"
    )
  }

  # devup: DevContainerにdotfilesを注入して起動
  #   使い方: devup [workspace] [repo]
  #   repo 省略時は $DOTFILES_REPO（既定は GitHub の dotfiles）。
  #   注: devup は git リポジトリを clone するため、検証されるのは push 済みの状態。
  #       ローカル別リポジトリ/フォークを試す例:
  #         DOTFILES_REPO=https://github.com/me/dotfiles devup .
  function devup() {
    local workspace="${1:-.}"
    local repo="${2:-$DOTFILES_REPO}"
    local -a reply
    _build_dotfiles_opts "$repo"
    echo "🚀 Starting DevContainer with Dotfiles Injection..."
    echo "   📦 dotfiles: $repo"
    devcontainer up \
      --workspace-folder "$workspace" \
      "${reply[@]}"

    if [ $? -eq 0 ]; then
      echo "✅ Container Ready. Run 'devsh' to enter."
    fi
  }

  # devbuild: DevContainer イメージをビルド（--remove-existing-container は build では不可）
  # 注: dotfiles の注入は devcontainer up の段階で行われる
  function devbuild() {
    local workspace="${1:-.}"
    echo "🔨 Building DevContainer..."
    devcontainer build --workspace-folder "$workspace"
    if [ $? -eq 0 ]; then
      echo "✅ Container Built. Run 'devup' to start with dotfiles injection."
    fi
  }

  # devrebuild: 既存コンテナを削除してから up（設定変更の反映用）
  #   使い方: devrebuild [workspace] [repo]
  function devrebuild() {
    local workspace="${1:-.}"
    local repo="${2:-$DOTFILES_REPO}"
    local -a reply
    _build_dotfiles_opts "$repo"
    echo "🔨 Rebuilding DevContainer (remove existing + up)..."
    echo "   📦 dotfiles: $repo"
    devcontainer up \
      --workspace-folder "$workspace" \
      --remove-existing-container \
      "${reply[@]}"
    if [ $? -eq 0 ]; then
      echo "✅ Container Ready. Run 'devsh' to enter."
    fi
  }

  # devdotfiles: コンテナ内でdotfilesを更新（git pull & install）
  function devdotfiles() {
    local workspace="${1:-.}"
    echo "🔄 Updating dotfiles inside DevContainer..."
    devcontainer exec \
      --workspace-folder "$workspace" \
      zsh -c "cd ~/dotfiles && git pull && ./install-container.sh"
  }

  # devsh: コンテナ内に入るショートカット
  function devsh() {
    local workspace="${1:-.}"
    devcontainer exec --workspace-folder "$workspace" zsh || \
    devcontainer exec --workspace-folder "$workspace" bash
  }
fi

# --- tmux 関数 ---
# t: tmuxセッション 'main' にアタッチ、なければ作成
function t() {
  if [[ -n "$TMUX" ]]; then
    echo "Already in Tmux."
    return
  fi
  tmux attach-session -t main 2>/dev/null || tmux new-session -s main
}

# --- Build Helpers ---
# tb: Turbo Build Shortcut
# カレントディレクトリからプロジェクトルートのturboを呼び出し、ビルドを実行する
function tb() {
  if [ -f "pnpm-lock.yaml" ]; then
    echo "🚀 Running: pnpm turbo run build $@"
    pnpm turbo run build "$@"
  elif [ -f "yarn.lock" ]; then
    echo "🚀 Running: yarn turbo run build $@"
    yarn turbo run build "$@"
  else
    echo "🚀 Running: npm run build $@"
    npm run build "$@"
  fi
}


# --- Docker 関数 ---
# 実行中コンテナにbashで入る
function dsh() { docker exec -it "$1" bash; }

# コンテナ名をfzfで選んでexec（fzf必須）
function dexf() {
  local cname
  cname=$(docker ps --format '{{.Names}}' | fzf)
  [ -n "$cname" ] && docker exec -it "$cname" bash
}



# --- Dev Machine Control (EC2 + SSM) ---
# タグ名は .zshrc-local で WORK_DEV_MACHINE_TAG を上書き可能（未設定時はデフォルト）
WORK_DEV_MACHINE_TAG="${WORK_DEV_MACHINE_TAG:-Bihada-Dev-Machine}"

# 開発機を起動する
dev-start() {
    echo "🚀 Starting ${WORK_DEV_MACHINE_TAG}..."
    local inst
    inst=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${WORK_DEV_MACHINE_TAG}" "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].InstanceId" --output text)
    if [ -z "$inst" ]; then
        echo "⚠️ Instance not found or already running."
    else
        aws ec2 start-instances --instance-ids $inst
        echo "⏳ Waiting for initialization..."
        aws ec2 wait instance-running --instance-ids $inst
        echo "✅ System Online! (ID: $inst)"
    fi
}

# 開発機にSSM接続する
dev-connect() {
    local inst
    inst=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${WORK_DEV_MACHINE_TAG}" "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)
    if [ -z "$inst" ]; then
        echo "⚠️ Instance is not running. Please run 'work-start' first."
    else
        echo "🔌 Connecting to ${WORK_DEV_MACHINE_TAG} ($inst)..."
        aws ssm start-session --target $inst
    fi
}

# 開発機を停止する（課金停止）
dev-stop() {
    echo "💤 Stopping ${WORK_DEV_MACHINE_TAG}..."
    local inst
    inst=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${WORK_DEV_MACHINE_TAG}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
    if [ -z "$inst" ]; then
        echo "⚠️ Instance not found or already stopped."
    else
        aws ec2 stop-instances --instance-ids $inst
        echo "✅ Stop signal sent. Good night!"
    fi
}

# ============================================================================
# キーバインド（Emacs風）— ツール初期化の後に設定（上書き防止）
# ============================================================================
bindkey -e

# 履歴（Ctrl+P / Ctrl+N は bash と同様）
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^R' history-incremental-search-backward

# カーソル移動
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^B' backward-char
bindkey '^F' forward-char

# 削除
bindkey '^D' delete-char
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^U' backward-kill-line
bindkey '^K' kill-line

# --- Local Overrides (git管理外) ---
[[ -f ~/.zshrc-local ]] && source ~/.zshrc-local
