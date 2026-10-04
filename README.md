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

### よく使うコマンド

`.zshrc` では、Neovim と Lazygit の短縮形も設定している。

```bash
v       # nvim
lg      # lazygit
gcd     # gh ghq-cd
```

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
- `dot_config/aerospace/` → `~/.config/aerospace/`
- `dot_config/borders/` → `~/.config/borders/`
- `dot_config/ghostty/` → `~/.config/ghostty/`
- `dot_config/nvim/` → `~/.config/nvim/`
- `dot_config/lazygit/` → `~/.config/lazygit/`
Homebrew Bundle は chezmoi の apply 後に `brew bundle --global` で実行する。Aerospace、JankyBorders、Ghostty の設定もこのリポジトリで管理している。

## Herdr + Claude Code / Codex

Herdr, its Neovim sidebar, the optional diff-review pane, and Claude/Codex integrations are installed by `chezmoi apply` on a new machine. The setup script uses Herdr's official installer because its Homebrew formula requires a source build on macOS 14. The Herdr prefix is `Option+Space`; Ghostty treats Option as Alt and Herdr temporarily switches to ASCII input while prefix mode is active. The managed `~/.config/herdr/config.toml` sets keyboard-first behavior and these shortcuts:

- `prefix`, then `e`: toggle the persistent Neovim sidebar
- `prefix`, then `f`: open the picker for files touched by the agent
- `prefix`, then `h/j/k/l`: move between panes while keeping the editor open
- `prefix`, then `c`: create a tab for another coding session
- `prefix`, then `,`: rename the active tab
- `prefix`, then `↑/↓`: move to the previous/next agent
- In Neovim, `<leader>ac`: ask about the current line or selection
- In Neovim, `<leader>aS`: send queued code annotations to the agent

The `prefix`, then `shift+o` picker searches repositories managed by `ghq` and focuses an existing workspace or creates a new one. The repository picker is installed by the chezmoi apply script and pinned to v0.2.0. Its managed plugin config leaves the new workspace at a shell prompt instead of starting Claude automatically. Herdr detects `working`, `blocked`, `done`, and `idle` states. New tabs no longer ask for a name. Claude/Codex sidebar rows show the state icon and agent name on the first line, then the terminal title on the second. Herdr 0.9.3 does not expose the Spaces/Agents divider ratio as a config option; dragging it only changes the current attach and is not persisted.

The Neovim sidebar keeps its buffers when hidden and reopened. Agent edits appear in the sidebar; `]r` / `[r` move between edits and `<leader>au` reverts the current agent hunk.

Open the optional diff-review pane with:

```bash
herdr plugin action invoke open --plugin persiyanov.reviewr
```

The review pane can show the worktree diff, browse/search files, and send line comments to the selected active agent. The official Herdr integrations also let it resume supported Claude Code and Codex sessions after a Herdr server restart. Herdr plugins are community code; inspect the plugin source before installing or updating them.
