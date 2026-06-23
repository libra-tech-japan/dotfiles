# Dotfiles (Libratech Lab. 2026)

**LazyVim**、**Tmux**、**Zsh (Starship)**、**Docker** をベースとした Thin Host & AI-Native Architecture の dotfiles リポジトリです。開発ホストは **EC2（Ubuntu）** を想定し、macOS や WSL2 はオプションで利用できます。

## 🚀 インストール

### 1. 必要な環境

- Linux（Ubuntu/Debian）推奨（EC2 開発ホスト想定）、または macOS（OrbStack 推奨）・WSL2
- Git

### 2. セットアップ

**ホスト（EC2 / macOS / WSL）でフルインストールする場合:**

```bash
git clone https://github.com/libra-tech-japan/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh install-container.sh
./install.sh
```

**DevContainer で利用する場合:** 各リポジトリの devcontainer 設定で dotfiles の `installCommand` に `./install-container.sh` を指定してください（実体は `install.sh --container` の薄い shim）。コンテナでは Linuxbrew を導入し、Brewfile.common でツールを一括インストールしたうえで、設定（Git・Starship・Neovim・zsh 等）を Stow でリンクします。

### 2.1 Docker 導入ガイド

#### macOS（OrbStack）

- OrbStack を起動していることを確認してください
- `docker` コマンドが通れば OK です

#### WSL2 Ubuntu（Docker Engine / Desktop 不使用）

1. WSL 側で systemd を有効化  
   `/etc/wsl.conf` の例:

   ```
   [boot]
   systemd=true
   ```

2. Windows 側で WSL を再起動  
   PowerShell:
   ```
   wsl --shutdown
   ```

3. Ubuntu 側で Docker Engine を導入  
   推奨は公式の APT リポジトリ方式です（長期運用向け）。

4. ユーザーを docker グループに追加  
   ```
   sudo usermod -aG docker $USER
   ```
   追加後は一度ログインし直してください。

#### Bare Ubuntu（Docker Engine / Desktop 不使用）

- 公式 APT リポジトリ方式で導入してください
- `docker compose`（plugin）と `buildx` が有効なことを確認

#### 動作確認

```
docker version
docker info
docker run --rm hello-world
```

問題があれば `systemctl status docker` で状態確認を推奨します。

### 3. インストール後の設定（Git identity）

個人情報（name/email）は公開リポジトリの `git/.gitconfig` には置かず、各マシンの
`~/.gitconfig.local` に分離します（`git/.gitconfig` の `[include]` が読み込む）。

`install.sh` は `~/.gitconfig.local` が**無い場合のみ** `.gitconfig.local.example` から
作成します（既存ファイルは上書きしないため再実行しても冪等）。作成後、自分の値に書き換えてください:

```ini
# ~/.gitconfig.local
[user]
    name = Your Name
    email = your-id+username@users.noreply.github.com
```

`git/.gitconfig` には `[user] useConfigOnly = true` が入っており、上記を設定するまで
コミットは拒否されます（identity 未設定時に `username@hostname` から著者情報が
勝手に生成され、実名・実メールが意図せず混入するのを防ぐ安全策）。

### `~/.config` と Stow の方針

`starship` パッケージを Stow すると `~/.config` 全体が `starship/.config` へのシンボリックリンクになり、htop や `gh` の生成物が **dotfiles リポジトリ内**に書き込まれることがあります。そのため `starship.toml` と `tmuxinator` は **手動リンク**し、`~/.config` は実ディレクトリのまま各エントリだけをリンクします。

- **確認**: `./scripts/check-stow.sh` で `~/.config` が単一 symlink でないこと、各設定が個別にリンクされていることを確認してください。
- **修復**: 上記の状態になっている場合は dotfiles のルートで `./install.sh` を再実行してください（`repair_config_dir` が壊れたリンクを直します）。
- **入れ子 symlink**: `~/.config/tmuxinator` などが既にディレクトリへの symlink のとき、`ln -sf` だけで再リンクすると `starship/.config/tmuxinator/tmuxinator` のようなファイルがリポジトリ内に増えます。install スクリプトは `ln -sfn` と `clean_nested_config_symlink` でこれを防ぎます。

### Neovim でキーマップ・プラグインが読み込まれない場合

設定は **Stow + 手動リンク** で行います。dotfiles のルートで `./install.sh` を実行すると、`~/.config/nvim` が `nvim/.config/nvim` へのシンボリックリンクになります。

- **確認**: `ls -la ~/.config/nvim` でリンク先が dotfiles の `nvim/.config/nvim` か確認してください。
- **手動でリンクする場合**: `./install.sh` または `./install-container.sh` を再実行してください（`nvim` / `lazygit` は Stow 対象外です）。
- **設定パスの確認**: Neovim 起動後 `:lua print(vim.fn.stdpath("config"))` で、`~/.config/nvim`（またはその実体パス）が表示されることを確認してください。

## 🛠 技術スタック

- **Shell:** Zsh + Starship + Mise + Zoxide
- **Editor:** Neovim (LazyVim)
- **Terminal:** Tmux + Alacritty/WezTerm ready
- **Audit:** Lazygit + Difftastic (AI Code Review optimized)
