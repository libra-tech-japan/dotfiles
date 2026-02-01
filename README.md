# Dotfiles (Libratech Lab. 2026)

**LazyVim**、**Tmux**、**Zsh (Starship)**、**Docker** をベースとした Thin Host & AI-Native Architecture の dotfiles リポジトリです。

## 🚀 インストール

### 1. 必要な環境

- macOS（OrbStack 推奨）または Linux（Debian/Ubuntu）
- Git

### 2. セットアップ

```bash
git clone https://github.com/libra-tech-japan/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

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

### 3. インストール後の設定

ローカルの Git 設定ファイルを作成してください:

```bash
# ~/.gitconfig.local
[user]
    name = Your Name
    email = your@email.com
```

### Neovim でキーマップ・プラグインが読み込まれない場合

設定は **Stow によるリンク** で行います。dotfiles のルートで `./install.sh` を実行すると、`~/.config/nvim` が `nvim/.config/nvim` へのシンボリックリンクになります。

- **確認**: `ls -la ~/.config/nvim` でリンク先が dotfiles の `nvim/.config/nvim` か確認してください。
- **手動でリンクする場合**: dotfiles のルートで `stow nvim` を実行してください。
- **設定パスの確認**: Neovim 起動後 `:lua print(vim.fn.stdpath("config"))` で、`~/.config/nvim`（またはその実体パス）が表示されることを確認してください。

## 🛠 技術スタック

- **Shell:** Zsh + Starship + Mise + Zoxide
- **Editor:** Neovim (LazyVim)
- **Terminal:** Tmux + Alacritty/WezTerm ready
- **Audit:** Lazygit + Difftastic (AI Code Review optimized)
