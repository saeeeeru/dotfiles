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

会社の Mac はここまで。Moshi は入れない。個人 Mac だけ、下の「Moshi（個人 Mac のみ）」にあるマーカーを書いてから、もう一度 `chezmoi apply` する。

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
- `run_onchange_after_*.sh` は `chezmoi apply` 時に、内容が変わったときだけ走る（tpm、Codex hooks、Herdr / plugin / agent integration のインストール）。`run_onchange_after_40_install-moshi.sh.tmpl` は個人 Mac のマーカーがあるときだけ mosh と moshi-hook を入れる

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

## Moshi（個人 Mac のみ）

[Moshi](https://getmoshi.app) は iOS の SSH / Mosh ターミナルで、`moshi-hook` がエージェントの通知を電話に送る。個人 Mac だけに入れる。会社の Mac では、マーカーが無い限り tap も formula もサービスも agent hook も入れない。

ホスト名では切り分けない。`MacBook-Air-5` は変わり得るし、マーカーが無いマシンは必ず work（何もしない）にする。

### 個人 Mac で有効にする

マーカーは chezmoi の管理外で、このリポジトリには入らない。`chezmoi add` しない。

```bash
mkdir -p ~/.config/dotfiles
printf '%s\n' personal > ~/.config/dotfiles/profile
chezmoi apply
```

ファイルの中身は `personal` の 1 行だけ。それ以外（空、`work`、未知の値）は work になる。

その apply で Moshi 用スクリプトが実行するのは次だけ。

```bash
brew tap rjyo/moshi
brew trust rjyo/moshi   # Homebrew 6 以降。古い Homebrew には trust が無いので飛ばす
brew install moshi-hook
brew install mosh
MOSHI_HOOK_SKIP_FIRST_RUN=1 moshi-hook install
# ~/.codex/config.toml があるときだけ、codex_hooks = true を戻す
brew services start moshi-hook
```

`moshi-hook install` はペアリングトークンなしで、ホーム配下のエージェント設定に Moshi の hook を書く。対象には `~/.claude/settings.json` と `~/.cursor/hooks.json` が含まれる。入っているエージェントだけを書き、無いものは飛ばす。これらはこのリポジトリに無く、`chezmoi apply` も git status も汚さない。`moshi-hook install` のあとにこれらを `chezmoi add` しない。追加すると個人 Mac の hook が会社の Mac に配られる。スクリプトは、これらのファイルが source にある、またはホーム側がシンボリックリンクなら、インストールを止める。

`moshi-hook install` は未管理の `~/.codex/config.toml` も書き換え、`codex_hooks` を落とすことがある。個人 Mac ではその直後に、共有スクリプトと同じ処理でもう一度 `codex_hooks = true` を入れる。会社の Mac ではこのファイルに触らない。

一度 work として apply したあとにマーカーを置いた場合も、次の `chezmoi apply` で再実行される。プロファイルの値がスクリプトの展開結果に入るため。

マーカーを消すか `work` にすると、以降の apply は Moshi を入れない。すでに入っている formula や hook は消さない。外すときは個人 Mac で `moshi-hook uninstall` してから `brew uninstall moshi-hook mosh` する。

一時的に上書きするとき:

```bash
DOTFILES_PROFILE=personal chezmoi apply   # マーカーが無くても個人向け処理を走らせる
DOTFILES_PROFILE=work chezmoi apply       # マーカーがあっても何もしない
```

Tailscale は自動では入れない。LAN の外から繋ぐときだけ、macOS アプリを入れる（App Store か `brew install --cask tailscale`）。formula の `brew install tailscale` は macOS の通常の入れ方ではないので使わない。

### 手作業（電話がいる。トークンはリポジトリに置かない）

1. システム設定 → 一般 → 共有 → リモートログイン をオンにする。
2. Tailscale を使うなら、ログインしたあとにホストで次を実行する。Tailscale SSH はポート 22 を横取りし、Moshi の鍵認証と mosh の起動を壊す。

   ```bash
   sudo tailscale set --ssh=false
   ```

3. ペアリングはどちらか。トークンは Moshi の Settings → Hooks に出る。コマンドやファイルに残してコミットしない。

   ```bash
   moshi-hook pair --token <token>
   ```

   または QR の Easy Pair:

   ```bash
   moshi-hook host setup
   ```

4. 確認する。

   ```bash
   moshi-hook doctor
   ```

   Codex 0.157 以降は共有バックグラウンドサーバの停止を聞いてくることがある。`chezmoi apply` は stdin を閉じた非対話の `moshi-hook install` なので、その確認は出さない。止めるなら、あとから `moshi-hook doctor --yes` を実行する。実行中の Codex セッションは切れる。

非対話の SSH は `~/.zshrc` を読まない。`mosh-server` が見つからないときは、Homebrew のインストーラが `~/.zprofile` に足す次の行が残っているか確認する。

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```
