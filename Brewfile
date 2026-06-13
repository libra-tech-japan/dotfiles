# ホスト専用パッケージ。
# install.sh の run_brew_bundle("Brewfile") で Brewfile.common と結合して実行される。
# 共通パッケージは Brewfile.common を参照。

# Runtime & Dev Tools
brew "mise"
brew "devcontainer"

# Terminal
brew "tmux"
brew "tmuxinator"
brew "htop"

# AWS
brew "awscli"
cask "session-manager-plugin"

# macOS Specifics
if OS.mac?
  cask "orbstack"
  cask "font-hack-nerd-font"
  cask "visual-studio-code"
  cask "google-chrome"
  cask "ghostty"
end
