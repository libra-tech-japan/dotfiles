# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# エディタ設定
export EDITOR=nvim

# Homebrew パス設定（Mac/Linux共通化）
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  if [[ -d "/opt/homebrew/bin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
else
  # Linux
  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
  elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
fi
# Ensure history directory exists
if [[ ! -d "${XDG_DATA_HOME}/zsh" ]]; then
  mkdir -p "${XDG_DATA_HOME}/zsh"
fi
