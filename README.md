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

### 2.2 コンテナへの持ち込み（生 docker / docker compose・devcontainer 非依存）

devcontainer を使わず `docker compose up` + `docker exec` + tmux で開発する環境向け。
個人 dotfiles は**チーム共用の compose / bootstrap とは分離**して持ち込みます。

**初回展開（コンテナに `docker exec` 後、1コマンド）:**

```bash
# repo が無い環境（git 必須）
curl -fsSL https://raw.githubusercontent.com/libra-tech-japan/dotfiles/main/scripts/container-bootstrap.sh | bash
# または手動で
git clone https://github.com/libra-tech-japan/dotfiles ~/dotfiles && ~/dotfiles/scripts/container-bootstrap.sh
```

`container-bootstrap.sh` は冪等で、`~/dotfiles` が無ければ clone、あれば clone をスキップして
`install.sh --container`（Linuxbrew + brew bundle + リンク）を実行します。
`DOTFILES_REPO` / `DOTFILES_DIR` で clone 元・展開先を上書きできます。

**自分の compose（編集できる場合）— ほぼ自動:**

`~/dotfiles`（必要なら `$HOME` 全体）を named volume で永続化します。`compose.yaml` 例:

```yaml
volumes:
  dotfiles:

services:
  dev:
    volumes:
      - dotfiles:/home/dev/dotfiles   # ~/dotfiles を永続化（clone は初回のみ）
```

`~/dotfiles` を永続化すると2回目以降は clone 不要。さらに **`$HOME` も永続化すれば symlink ごと
残る**ため、`docker exec` で対話 zsh に入った瞬間に自動で使えます。`$HOME` を永続化しない場合でも、
`zsh` の **self-heal**（コンテナ・対話シェルのみ）が `~/.config/nvim` 等の symlink 欠落を検知し、
`install.sh --container --relink`（brew を走らせない高速再リンク）で自動復元します。

> compose.yaml の named volume 追加は**対象プロジェクト側（別リポジトリ）の変更**です。dotfiles 側の
> 変更ではありません（チーム共用 bootstrap には dotfiles 処理を入れない方針）。

**他人の compose（編集できない場合）:**

`compose.yaml` を触れなくても、`docker exec` 後に上記の初回展開コマンドを1回流せば展開されます。
volume が無ければコンテナ再作成のたびに clone が走ります（private repo は SSH agent forwarding が必要）。

**SSH agent forwarding（private repo を `git@` で clone する場合）:** ホストで `ssh-add` 済みの鍵を
コンテナへ転送します。HTTPS + token でも可。`DOTFILES_REPO=git@github.com:libra-tech-japan/dotfiles.git`
のように上書きできます。

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
