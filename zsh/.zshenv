# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# エディタ設定
export EDITOR=nvim

# ユーザーロカル bin（コンテナで starship/lazygit を入れた場合など）
export PATH="${HOME}/.local/bin:$PATH"

# Homebrew パス設定（Mac/Linux共通化）
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  if [[ -d "/opt/homebrew/bin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
else
  # Linux（Linuxbrew: システム導入またはユーザー導入）
  # コンテナでは末尾に追加（mise.toml があるとき mise の node/python を PATH 先頭にできる）
  _linuxbrew_bin=""
  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    _linuxbrew_bin="/home/linuxbrew/.linuxbrew/bin"
  elif [[ -d "$HOME/.linuxbrew/bin" ]]; then
    _linuxbrew_bin="$HOME/.linuxbrew/bin"
  fi
  if [[ -n "$_linuxbrew_bin" ]]; then
    if [[ -f "/.dockerenv" ]] || [[ -n "${REMOTE_CONTAINERS:-}" ]]; then
      export PATH="${PATH}:${_linuxbrew_bin}"
    else
      export PATH="${_linuxbrew_bin}:${PATH}"
    fi
    unset _linuxbrew_bin
  elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
fi
