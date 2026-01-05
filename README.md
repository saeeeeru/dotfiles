# dotfiles

Personal configuration files for development environment.

## Contents

- `nvim/` - Neovim configuration
- `zsh/` - Zsh configuration with Oh My Zsh
- `tmux/` - Tmux configuration
- `lazygit/` - Lazygit configuration

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

## Prerequisites

- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [Tmux](https://github.com/tmux/tmux)
- [Lazygit](https://github.com/jesseduffield/lazygit)

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
