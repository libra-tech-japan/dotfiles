# Dotfiles (Libratech Lab. 2026)

Thin Host & AI-Native Architecture based on **LazyVim**, **Tmux**, **Zsh (Starship)**, and **Docker**.

## 🚀 Installation

### 1. Requirements
- macOS (OrbStack recommended) or Linux (Debian/Ubuntu)
- Git

### 2. Setup

```bash
git clone https://github.com/libra-tech-japan/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### 3. Post Install
Create local git config:

```bash
# ~/.gitconfig.local
[user]
    name = Your Name
    email = your@email.com
```

## 🛠 Tech Stack
- **Shell:** Zsh + Starship + Mise + Zoxide
- **Editor:** Neovim (LazyVim)
- **Terminal:** Tmux + Alacritty/WezTerm ready
- **Audit:** Lazygit + Difftastic (AI Code Review optimized)
