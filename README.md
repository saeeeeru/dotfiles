# dotfiles

Personal configuration files for development environment.

## Contents

- `nvim/` - Neovim configuration
- `zsh/` - Zsh configuration with Oh My Zsh
- `tmux/` - Tmux configuration
- `lazygit/` - Lazygit configuration
- `ghostty/` - Ghostty terminal emulator configuration

## Setup

### Neovim
```bash
ln -sf ~/ghq/github.com/saeeeeru/dotfiles/nvim ~/.config/nvim
```

### Zsh
```bash
ln -sf ~/ghq/github.com/saeeeeru/dotfiles/zsh/.zshrc ~/.zshrc
```

### Tmux
```bash
ln -sf ~/ghq/github.com/saeeeeru/dotfiles/tmux/.tmux.conf ~/.tmux.conf
```

### Lazygit
```bash
ln -sf ~/ghq/github.com/saeeeeru/dotfiles/lazygit/config.yml ~/.config/lazygit/config.yml
```

### Ghostty
```bash
mkdir -p ~/.config/ghostty
ln -sf ~/ghq/github.com/saeeeeru/dotfiles/ghostty/config ~/.config/ghostty/config
```

**macOS権限設定:** クイックターミナルのグローバルキーバインドを使用する場合は、システム設定 > プライバシーとセキュリティ > アクセシビリティ でGhosttyを有効化してください。

## Prerequisites

- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [Tmux](https://github.com/tmux/tmux)
- [Lazygit](https://github.com/jesseduffield/lazygit)
- [Ghostty](https://ghostty.org/)

### Oh My Zsh plugins used
- git
- aliases
- copypath
- history
- docker
- github
- composer
- laravel
- brew
- zsh-completions
- zsh-autosuggestions
- zsh-syntax-highlighting
