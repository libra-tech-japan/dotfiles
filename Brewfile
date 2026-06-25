# ホスト専用パッケージ。
# install.sh の run_brew_bundle("Brewfile") で Brewfile.common と結合して実行される。
# 共通パッケージは Brewfile.common を参照。

# Baseline（de-facto 標準。BHD-205）
# ホスト OS（macOS / EC2 等）では dotfiles が用意する。コンテナ内ではこれらを入れず、
# コンテナを提供するプロジェクトの Docker イメージ（例: bihada-connect docker/Dockerfile の apt 層）が
# 用意する責務とする。よって container（Brewfile.common のみ）には含めない。
brew "git"
brew "curl"
brew "wget"
brew "unzip"
# git-secrets はホストの個人 git hook 用に残す。コンテナ/チーム強制はプロジェクト側へ移管（BHD-205）。
brew "git-secrets"
# gh はホストの GitHub 操作（PR/issue/auth）+ git credential helper（!gh）の PATH 解決用。
# コンテナでは入れない（プロジェクト Docker イメージが /usr/bin/gh を apt で提供。bihada-connect BHD-206）。
brew "gh"

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
