# dotfiles

Personal configuration files managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### New machine

```bash
# 1. Homebrew インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. chezmoi インストール
brew install chezmoi

# 3. dotfiles を clone して apply（ghqパスに配置）
chezmoi init --apply --source ~/ghq/github.com/saeeeeru/dotfiles https://github.com/saeeeeru/dotfiles

# 4. Homebrew パッケージ一括インストール
brew bundle --global
```

## Daily usage

```bash
chezmoi add ~/.zshrc    # ホーム側の変更をsourceに取り込む
chezmoi apply           # source側の変更をホームに反映
chezmoi diff            # 差分確認
chezmoi edit ~/.zshrc   # source側を直接編集
```

## Tips

### Git worktree を移動する

`wcd` で現在のリポジトリの worktree 一覧を出して、そのまま移動できる。

```bash
wcd
```

`fzf` が入っていれば絞り込み選択、なければ番号入力で選択する。

### JankyBorders を有効化する

```bash
brew services start borders
```

### Aerospace の設定が反映されない場合

設定ファイルは chezmoi で同期済みでも、Aerospace が再読み込みしていない場合がある。

```bash
aerospace reload-config
```

それでも反映されない場合は Aerospace を再起動する。

## Contents

- `dot_Brewfile` → `~/.Brewfile`
- `dot_zshrc` → `~/.zshrc`
- `dot_config/nvim/` → `~/.config/nvim/`
- `dot_config/lazygit/` → `~/.config/lazygit/`
- `dot_config/tmux/` → `~/.config/tmux/`

## tmux-agent-sidebar

This repo manages the tmux-side setup for [`hiroppy/tmux-agent-sidebar`](https://github.com/hiroppy/tmux-agent-sidebar):

- `~/.config/tmux/tmux.conf` loads `plugins.tmux`
- `chezmoi apply` bootstraps TPM into `~/.tmux/plugins/tpm` if it is missing
- `chezmoi apply` also ensures `codex_hooks = true` exists in `~/.codex/config.toml`

After applying dotfiles, finish the interactive setup once.
Start tmux first. If you are already inside tmux, reload with `prefix + r`.

1. Open tmux and press `prefix + I` to let TPM install `tmux-agent-sidebar`.
2. Follow the install wizard and accept the prebuilt binary unless you want a local Rust build.
3. Restart Codex so the `codex_hooks` feature flag is picked up.
4. In a Codex pane inside tmux, press `prefix + e`.
5. Click the yellow `ⓘ` badge, copy the `codex` setup snippet, and paste it into the Codex pane.

Once setup is complete, `prefix + e` toggles the sidebar in the current window and `prefix + E` toggles it everywhere.
