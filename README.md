# dotfiles

Personal configuration files managed with [chezmoi](https://www.chezmoi.io/).

## Setup

### New machine

```bash
# 1. Homebrew インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. chezmoi インストール
brew install chezmoi

# 3. dotfiles を clone（ghqパスに配置）
chezmoi init --source ~/ghq/github.com/saeeeeru/dotfiles https://github.com/saeeeeru/dotfiles

# 4. Homebrew パッケージ一括インストール（apply 後に走るスクリプトが jq などを使う）
brew bundle --file ~/ghq/github.com/saeeeeru/dotfiles/dot_Brewfile

# 5. ホームに反映
chezmoi apply
```

以降は `~/.Brewfile` が置かれるので `brew bundle --global` でよい。

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

### Hammerspoon でディスプレイを自動設定する

`~/.hammerspoon/init.lua` が、ディスプレイの抜き差しのたびに次を行う。

- 全ディスプレイを、HiDPI かつ幅 2304 以下の中で作業領域が最も広い解像度にする（27 インチ 4K は 2304x1296、MacBook 内蔵は 1800x1169）
- 外部ディスプレイが 1 台なら、内蔵ディスプレイの真上（左右中央）に置く

手動で再適用するときは `ctrl+alt+cmd+d`。初回は Hammerspoon を起動し、ログイン時に起動されることを確認する。

## Go Links（Chrome）

アドレスバーの `go/twitter` を登録先へ飛ばす Manifest V3 拡張。実体は `chrome/golinks/`。chezmoi の source（`~/ghq/github.com/saeeeeru/dotfiles`）に置いたまま、Chrome の「パッケージ化されていない拡張機能」として読み込む。

`.chezmoiignore` に `chrome` があるので、`chezmoi apply` は `~/chrome` を作らない。ホームへコピーすると、編集のたびに apply と拡張の再読み込みが両方必要になり、読み込み元が二重になる。source の場所は `~/ghq/github.com/saeeeeru/dotfiles` に固定している。

### インストール（初回だけ）

1. Chrome で `chrome://extensions` を開く
2. 「デベロッパーモード」をオンにする
3. 「パッケージ化されていない拡張機能を読み込む」で次のフォルダを選ぶ

```
~/ghq/github.com/saeeeeru/dotfiles/chrome/golinks
```

### 使い方

`go/twitter` と入力して Enter。`go/` だけなら一覧が出る。

Chrome は `go/twitter` を URL ではなく検索にすることが多い。拡張は次の両方を拾う。

- `http://go/<名前>` と `https://go/<名前>`（末尾の `/` も可）
- Google 検索に落ちた `https://www.google.com/search?q=go%2F<名前>` と `q=go/<名前>`（`google.co.jp` も同じ。`q` が先頭でなくてもよい）

検索結果のままなら、一度 `go/twitter/`（末尾スラッシュ）か `http://go/twitter` と入れる。Chrome が `go` をホストとして覚えると、次から URL として開く。

拾う検索は Google の `google.com` と `google.co.jp` で、クエリ全体が `go/<名前>` か `go/<名前>/` のときだけ。`go/twitter login` のような続きがある検索や、別の検索エンジン、`google.de` のような未登録の国別ドメインはそのまま検索になる。国別ドメインを足すときは `rules.json` の正規表現と `manifest.json` の `host_permissions` の両方に足す。

`go` という単語や、登録していない `go/parser` のような検索は飛ばさない。

### リンクを足す

編集するのは `chrome/golinks/rules.json` だけ。一覧ページはそのファイルから名前を読む。

その名前のルールは2つある。直アクセス用（`^https?://go/twitter/?$`）と、Google 検索用（`q=(?:go%2[Ff]|go/)twitter` を含むもの）。この2つをコピーして、次を変える。

- `id`: 他と被らない正の整数
- 正規表現の中の名前（各ルールに1箇所）
- `redirect.url`

名前は英小文字・数字・ハイフン。`go/twitter` と `go/Twitter` は別物として扱われる。`priority` は `2` のままにする。末尾付近の `extensionPath` ルールは `go/` の一覧用なのでコピーしない。

行き先は `redirect.url` で URL 全体を置き換える。`regexSubstitution` は一致した部分だけを差し替えるので、Google の `&sourceid=chrome&ie=UTF-8` が行き先の末尾に残る。

編集したあとは `chrome://extensions` でこの拡張の再読み込みを押す。`chezmoi apply` やビルドは不要。JSON が壊れているとルールごと読み込まれない。

確認用に `python3 chrome/golinks/check.py` がある。標準ライブラリだけで、サンプル URL が期待する行き先に解決されるかを見る。拡張の動作には不要。

初期のリンク:

| 名前 | 行き先 |
| --- | --- |
| `twitter`, `x` | https://x.com/ |
| `gmail` | https://mail.google.com/ |
| `facebook` | https://www.facebook.com/ |
| `amazon` | https://www.amazon.co.jp/ |
| `sizu` | https://sizu.me/saeeeeru |
| `note` | https://note.com/deepfoot |

## Contents

- `dot_Brewfile` → `~/.Brewfile`
- `dot_zshrc` → `~/.zshrc`
- `dot_hammerspoon/` → `~/.hammerspoon/`
- `dot_config/aerospace/` → `~/.config/aerospace/`
- `dot_config/borders/` → `~/.config/borders/`
- `dot_config/ghostty/` → `~/.config/ghostty/`
- `dot_config/herdr/` → `~/.config/herdr/`
- `dot_config/lazygit/` → `~/.config/lazygit/`
- `dot_config/nvim/` → `~/.config/nvim/`
- `dot_config/tmux/` → `~/.config/tmux/`
- `run_onchange_after_*.sh` は `chezmoi apply` 時に、内容が変わったときだけ走る（tpm、Codex hooks、Herdr / plugin / agent integration のインストール）
- `chrome/golinks/` は Chrome の go/ 拡張。`.chezmoiignore` 対象で、ホームにはコピーしない

Aerospace、JankyBorders、Ghostty、tmux の設定もこのリポジトリで管理している。

## Herdr + Claude Code / Codex / Cursor Agent

Herdr, its Neovim sidebar, the optional diff-review pane, and Claude/Codex/Cursor Agent integrations are installed by `chezmoi apply` on a new machine. The setup script uses Herdr's official installer because its Homebrew formula requires a source build on macOS 14. The Herdr prefix is `Option+Space`; Ghostty treats Option as Alt and Herdr temporarily switches to ASCII input while prefix mode is active. The managed `~/.config/herdr/config.toml` sets keyboard-first behavior and these shortcuts:

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

The `prefix`, then `shift+o` picker searches repositories managed by `ghq` and focuses an existing workspace or creates a new one. The repository picker is installed by the chezmoi apply script and pinned to v0.2.0. Its managed plugin config leaves the new workspace at a shell prompt instead of starting Claude automatically. Herdr detects `working`, `blocked`, `done`, and `idle` states. New tabs no longer ask for a name. Claude/Codex/Cursor sidebar rows show the state icon and agent name on the first line, then the terminal title on the second. Herdr 0.9.3 does not expose the Spaces/Agents divider ratio as a config option; dragging it only changes the current attach and is not persisted.

The URL picker is installed from [`kaar/herdr-fzf-url`](https://github.com/kaar/herdr-fzf-url) by chezmoi. Press `prefix`, then `u` to choose URLs from the active pane's scrollback; Enter opens the selection and Ctrl+Y copies it.

The Neovim sidebar keeps its buffers when hidden and reopened. Uncommitted changes show as gitsigns markers; `]c` / `[c` move between hunks, `<leader>hp` previews one, and `<leader>hr` resets it. These markers do not separate agent edits from your own; use the diff-review pane below to see what an agent changed.

The sidebar and file picker come from [`saeeeeru/herdr-nvim`](https://github.com/saeeeeru/herdr-nvim), a fork of [`ChmaraX/herdr-nvim`](https://github.com/ChmaraX/herdr-nvim) pinned to `v1.1.0-subagents.1`. The fork also reads Claude Code sub-agent transcripts, so files edited by delegated agents appear in the `prefix`, then `f` picker. The picker only sees files touched through the Edit/Write/Read tools, not through shell commands.

Open the optional diff-review pane with:

```bash
herdr plugin action invoke open --plugin persiyanov.reviewr
```

Or press `prefix`, then `d` to toggle it. The plugin is pinned to v0.44.0 and also opens automatically when Herdr creates or opens a worktree. It reviews the worktree of the focused pane's working directory, so have Claude Code enter a worktree with its EnterWorktree tool rather than `cd` into one from a shell command.

The review pane can show the worktree diff, browse/search files, and send line comments to the selected active agent. The official Herdr integrations also let it resume supported Claude Code, Codex, and Cursor Agent CLI sessions after a Herdr server restart (`cursor-agent --resume <session-id>`; `cursor-agent` must be on `PATH`). Herdr plugins are community code; inspect the plugin source before installing or updating them.
