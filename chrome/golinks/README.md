# Go Links

アドレスバーの `go/twitter` を登録先へ飛ばす Manifest V3 拡張。このフォルダを、そのまま Chrome に読み込む。

chezmoi の source は `~/ghq/github.com/saeeeeru/dotfiles`。`.chezmoiignore` に `chrome` があるので、`chezmoi apply` では `~/chrome` にコピーされない。読み込むパスは source のままにする。

## インストール（初回だけ）

1. Chrome で `chrome://extensions` を開く
2. 「デベロッパーモード」をオンにする
3. 「パッケージ化されていない拡張機能を読み込む」で、このフォルダを選ぶ

```
~/ghq/github.com/saeeeeru/dotfiles/chrome/golinks
```

## 使い方

`go/twitter` と入力して Enter。`go/` だけなら一覧が出る。一覧は `rules.json` から作る。

Chrome は `go/twitter` を検索にすることが多い。拡張は次の両方を拾う。

- `http://go/<名前>` と `https://go/<名前>`（末尾の `/` も可）
- Google 検索に落ちた `q=go%2F<名前>` と `q=go/<名前>`（`www.google.com` と `www.google.co.jp`、先頭の `google.com` / `google.co.jp`。`q` が先頭でなくてもよい）

検索結果のままなら、一度 `go/twitter/` か `http://go/twitter` と入れる。Chrome が `go` をホストとして覚える。

拾うのは、クエリ全体が `go/<名前>` か `go/<名前>/` のときだけ。`go/twitter login` や、登録していない `go/parser`、`go` という単語の検索はそのまま。別の検索エンジンや `google.de` のような未登録ドメインもそのまま。ドメインを足すときは `rules.json` の正規表現と `manifest.json` の `host_permissions` の両方に足して、再読み込みする。

## リンクを足す

編集するのは `rules.json` だけ。直アクセス用と Google 検索用の2ルールをコピーして、`id`（他と被らない正の整数）、正規表現中の名前、`redirect.url` を変える。`priority` は `2`。名前は英小文字・数字・ハイフンで、大文字小文字は区別される。

```json
{
  "id": 1,
  "priority": 2,
  "action": { "type": "redirect", "redirect": { "url": "https://x.com/" } },
  "condition": {
    "regexFilter": "^https?://go/twitter/?$",
    "isUrlFilterCaseSensitive": true,
    "resourceTypes": ["main_frame"]
  }
}
```

```json
{
  "id": 2,
  "priority": 2,
  "action": { "type": "redirect", "redirect": { "url": "https://x.com/" } },
  "condition": {
    "regexFilter": "^https?://(?:www\\.)?google\\.(?:com|co\\.jp)/search\\?(?:[^#]*&)?q=(?:go%2[Ff]|go/)twitter(?:%2[Ff]|/)?(?:$|&|#)",
    "isUrlFilterCaseSensitive": true,
    "resourceTypes": ["main_frame"]
  }
}
```

ファイル末尾の `extensionPath` ルールは `go/` の一覧用なのでコピーしない。

行き先は `redirect.url` で URL 全体を置き換える。`regexSubstitution` は一致した範囲だけを差し替えるので、`&sourceid=chrome&ie=UTF-8` が行き先の末尾に残る。

編集後は `chrome://extensions` で再読み込みする。`chezmoi apply` やビルドは不要。

`python3 chrome/golinks/check.py` は標準ライブラリだけで、サンプル URL の行き先を確認する。拡張の動作には不要。
