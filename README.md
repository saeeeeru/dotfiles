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
- `prefix`, then `u`: fuzzy-find URLs in the active pane's scrollback and open them
- `prefix`, then `d`: toggle the diff-review pane
- In Neovim, `<leader>ac`: ask about the current line or selection
- In Neovim, `<leader>aS`: send queued code annotations to the agent

The `prefix`, then `shift+o` picker searches repositories managed by `ghq` and focuses an existing workspace or creates a new one. The repository picker is installed by the chezmoi apply script and pinned to v0.2.0. Its managed plugin config leaves the new workspace at a shell prompt instead of starting Claude automatically. Herdr detects `working`, `blocked`, `done`, and `idle` states. New tabs no longer ask for a name. Claude/Codex sidebar rows show the state icon and agent name on the first line, then the terminal title on the second. Herdr 0.9.3 does not expose the Spaces/Agents divider ratio as a config option; dragging it only changes the current attach and is not persisted.

The URL picker is installed from [`kaar/herdr-fzf-url`](https://github.com/kaar/herdr-fzf-url) by chezmoi. Press `prefix`, then `u` to choose URLs from the active pane's scrollback; Enter opens the selection and Ctrl+Y copies it.

The Neovim sidebar keeps its buffers when hidden and reopened. Uncommitted changes show as gitsigns markers; `]c` / `[c` move between hunks, `<leader>hp` previews one, and `<leader>hr` resets it. These markers do not separate agent edits from your own; use the diff-review pane below to see what an agent changed.

The sidebar and file picker come from [`saeeeeru/herdr-nvim`](https://github.com/saeeeeru/herdr-nvim), a fork of [`ChmaraX/herdr-nvim`](https://github.com/ChmaraX/herdr-nvim) pinned to `v1.1.0-subagents.1`. The fork also reads Claude Code sub-agent transcripts, so files edited by delegated agents appear in the `prefix`, then `f` picker. The picker only sees files touched through the Edit/Write/Read tools, not through shell commands.

Open the optional diff-review pane with:

```bash
herdr plugin action invoke open --plugin persiyanov.reviewr
```

Or press `prefix`, then `d` to toggle it. The plugin is pinned to v0.44.0 and also opens automatically when Herdr creates or opens a worktree. It reviews the worktree of the focused pane's working directory, so have Claude Code enter a worktree with its EnterWorktree tool rather than `cd` into one from a shell command.

The review pane can show the worktree diff, browse/search files, and send line comments to the selected active agent. The official Herdr integrations also let it resume supported Claude Code and Codex sessions after a Herdr server restart. Herdr plugins are community code; inspect the plugin source before installing or updating them.
