#!/usr/bin/env python3
"""Validate the go/ links extension.

Python standard library only. Chrome never runs this file. From the repo root:

    python3 chrome/golinks/check.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# Names the extension ships with. Adding a link only requires rules.json;
# a new name is accepted when both of its rules follow the templates below.
LINKS = {
    "twitter": "https://x.com/",
    "x": "https://x.com/",
    "gmail": "https://mail.google.com/",
    "facebook": "https://www.facebook.com/",
    "amazon": "https://www.amazon.co.jp/",
    "sizu": "https://sizu.me/saeeeeru",
    "note": "https://note.com/deepfoot",
}

HOST_PERMISSIONS = [
    "*://go/*",
    "*://google.com/*",
    "*://*.google.com/*",
    "*://google.co.jp/*",
    "*://*.google.co.jp/*",
]

# Same expression index.js uses to read a direct-navigation rule.
DIRECT_NAME = re.compile(r"^\^https\?:\/\/go\/([a-z0-9-]+)\/\?\$")
NAME_AFTER_SLASH = re.compile(r"(?:go/|go/\))([a-z0-9-]+)")

LINK_PRIORITY = 2
INDEX_PRIORITY = 1


def direct_regex(name: str) -> str:
    return rf"^https?://go/{name}/?$"


def search_regex(name: str) -> str:
    # (?P<...> ) is intentionally not used: Chrome compiles regexFilter with RE2.
    return (
        r"^https?://(?:www\.)?google\.(?:com|co\.jp)/search\?"
        r"(?:[^#]*&)?q=(?:go%2[Ff]|go/)"
        + name
        + r"(?:%2[Ff]|/)?(?:$|&|#)"
    )


def index_direct_regex() -> str:
    return r"^https?://go/?$"


def index_search_regex() -> str:
    return (
        r"^https?://(?:www\.)?google\.(?:com|co\.jp)/search\?"
        r"(?:[^#]*&)?q=(?:go%2[Ff]|go/)(?:$|&|#)"
    )


def load_json(path: Path):
    def pairs(items):
        obj = {}
        for key, value in items:
            if key in obj:
                raise ValueError(f"{path.name}: duplicate key {key!r}")
            obj[key] = value
        return obj

    with path.open(encoding="utf-8") as handle:
        return json.loads(handle.read(), object_pairs_hook=pairs)


def destination(rule: dict):
    redirect = rule["action"]["redirect"]
    if "url" in redirect:
        return ("url", redirect["url"])
    return ("extensionPath", redirect["extensionPath"])


def classify(rule: dict) -> tuple[str, str | None]:
    regex = rule["condition"]["regexFilter"]
    if regex == index_direct_regex():
        return "index-direct", None
    if regex == index_search_regex():
        return "index-search", None
    names = NAME_AFTER_SLASH.findall(regex)
    for name in names:
        if regex == direct_regex(name):
            return "direct", name
        if regex == search_regex(name):
            return "search", name
    raise AssertionError(f"rule {rule.get('id')} does not match a known template: {regex}")


def assert_common(rule: dict, priority: int) -> None:
    assert set(rule) == {"id", "priority", "action", "condition"}, rule["id"]
    assert isinstance(rule["id"], int) and rule["id"] > 0, rule["id"]
    assert rule["priority"] == priority, rule["id"]
    action = rule["action"]
    assert action["type"] == "redirect", rule["id"]
    redirect = action["redirect"]
    assert set(action) == {"type", "redirect"}, rule["id"]
    condition = rule["condition"]
    assert set(condition) == {
        "regexFilter",
        "isUrlFilterCaseSensitive",
        "resourceTypes",
    }, rule["id"]
    assert condition["isUrlFilterCaseSensitive"] is True, rule["id"]
    assert condition["resourceTypes"] == ["main_frame"], rule["id"]
    # Chrome replaces only the matched span when regexSubstitution is set,
    # which would keep Google's trailing query on the destination.
    assert "regexSubstitution" not in redirect, rule["id"]


def compiled_rules(rules: list[dict]) -> list[tuple[dict, re.Pattern[str]]]:
    compiled = []
    for rule in rules:
        compiled.append((rule, re.compile(rule["condition"]["regexFilter"])))
    return compiled


def matching(url: str, compiled: list[tuple[dict, re.Pattern[str]]]) -> list[dict]:
    return [rule for rule, pattern in compiled if pattern.search(url)]


def direct_urls(name: str) -> list[str]:
    return [
        f"http://go/{name}",
        f"https://go/{name}",
        f"http://go/{name}/",
        f"https://go/{name}/",
    ]


def search_urls(name: str) -> list[str]:
    encoded = "go%2F" + name
    raw = "go/" + name
    return [
        f"https://www.google.com/search?q={encoded}",
        f"https://www.google.com/search?q={raw}",
        f"https://www.google.com/search?q={encoded}&sourceid=chrome&ie=UTF-8",
        f"https://www.google.co.jp/search?q={encoded}&hl=ja",
        f"https://www.google.co.jp/search?hl=ja&sourceid=chrome&ie=UTF-8&q={encoded}",
        f"https://google.com/search?q={encoded}",
        f"https://www.google.com/search?q={encoded}%2F",
        f"https://www.google.com/search?q={raw}/",
        f"https://www.google.com/search?q={encoded}%2f",
        f"https://www.google.com/search?q=go%2f{name}",
        f"http://www.google.com/search?q={encoded}",
        (
            "https://www.google.com/search?q="
            + encoded
            + "&oq="
            + encoded
            + "&gs_lcrp=abc&sourceid=chrome&ie=UTF-8"
        ),
        f"https://www.google.com/search?q={encoded}#ref",
    ]


def negative_urls(name: str) -> list[str]:
    encoded = "go%2F" + name
    return [
        f"http://go/{name}/extra",
        f"http://go/{name}extra",
        f"https://go/{name}/extra",
        f"https://www.google.com/search?q={encoded}+login",
        f"https://www.google.com/search?q={encoded}%20login",
        f"https://www.google.com/search?q=how+to+{encoded}",
        f"https://www.google.com/search?q={encoded}extra",
        f"https://www.google.com.evil.com/search?q={encoded}",
        f"https://evil.example/search?q={encoded}",
        f"https://www.bing.com/search?q={encoded}",
        f"https://www.google.de/search?q={encoded}",
        f"http://example.com/go/{name}",
        f"https://www.google.com/search?oq={encoded}",
        f"https://www.google.com/search?q=prefix{encoded}",
        f"http://go/{name}?q=1",
    ]


def index_positive_urls() -> list[str]:
    return [
        "http://go/",
        "https://go/",
        "http://go",
        "https://go",
        "https://www.google.com/search?q=go%2F",
        "https://www.google.com/search?q=go/",
        "https://www.google.co.jp/search?q=go%2F&hl=ja",
        "https://www.google.com/search?hl=ja&q=go%2F",
        "https://google.com/search?q=go/",
        "https://www.google.com/search?q=go%2F&sourceid=chrome&ie=UTF-8",
    ]


def index_negative_urls() -> list[str]:
    return [
        "https://www.google.com/search?q=go",
        "https://www.google.com/search?q=golang",
        "https://www.google.com/search?q=go+lang",
        "https://www.google.com/search?q=go%2Fparser",
        "https://www.google.com/",
        "http://go/twitter",
        "https://example.com/go/",
    ]


def validate_manifest(manifest: dict) -> None:
    assert manifest["manifest_version"] == 3
    assert manifest["name"] == "Go Links"
    assert manifest["version"] == "1.0.0"
    assert manifest["permissions"] == ["declarativeNetRequestWithHostAccess"]
    assert manifest["host_permissions"] == HOST_PERMISSIONS
    assert "background" not in manifest
    assert "content_scripts" not in manifest
    rulesets = manifest["declarative_net_request"]["rule_resources"]
    assert rulesets == [{"id": "golinks", "enabled": True, "path": "rules.json"}]
    assert manifest["web_accessible_resources"] == [
        {"resources": ["index.html"], "matches": HOST_PERMISSIONS}
    ]


def validate(rules: list[dict], index_js: str) -> dict[str, str]:
    assert isinstance(rules, list) and rules, "rules.json must be a non-empty array"
    ids = [rule["id"] for rule in rules]
    assert len(ids) == len(set(ids)), f"duplicate rule ids: {ids}"

    found: dict[str, dict[str, object]] = {}
    index_kinds = set()
    for rule in rules:
        kind, name = classify(rule)
        if kind.startswith("index"):
            assert_common(rule, INDEX_PRIORITY)
            assert destination(rule) == ("extensionPath", "/index.html"), rule["id"]
            assert kind not in index_kinds, kind
            index_kinds.add(kind)
            continue
        assert_common(rule, LINK_PRIORITY)
        assert name is not None
        assert re.fullmatch(r"[a-z0-9-]+", name), name
        kind_name, url = destination(rule)
        assert kind_name == "url", rule["id"]
        assert url.startswith("https://") and " " not in url, url
        slot = found.setdefault(name, {})
        assert kind not in slot, f"{name} has two {kind} rules"
        slot[kind] = url

    assert index_kinds == {"index-direct", "index-search"}

    for name, url in LINKS.items():
        assert name in found, f"missing shipped link {name}"
        assert found[name].get("direct") == url, name
        assert found[name].get("search") == url, name

    for name, slot in found.items():
        assert set(slot) == {"direct", "search"}, f"{name} needs both rules, has {sorted(slot)}"
        assert slot["direct"] == slot["search"], name

    needle = r"/^\^https\?:\/\/go\/([a-z0-9-]+)\/\?\$/"
    assert needle in index_js, "index.js no longer extracts direct rules"
    for rule in rules:
        kind, name = classify(rule)
        extracted = DIRECT_NAME.fullmatch(rule["condition"]["regexFilter"])
        if kind == "direct":
            assert extracted and extracted.group(1) == name
        else:
            assert extracted is None

    return {name: str(slot["direct"]) for name, slot in found.items()}


def main() -> int:
    manifest = load_json(ROOT / "manifest.json")
    rules = load_json(ROOT / "rules.json")
    index_js = (ROOT / "index.js").read_text(encoding="utf-8")
    validate_manifest(manifest)
    mapping = validate(rules, index_js)
    compiled = compiled_rules(rules)
    failures = []
    checked = 0

    def hits_for(url: str) -> list[tuple[str, str | None, tuple[str, str]]]:
        found_hits = []
        for hit in matching(url, compiled):
            kind, name = classify(hit)
            found_hits.append((kind, name, destination(hit)))
        return found_hits

    for name, url in mapping.items():
        for kind, samples in (("direct", direct_urls(name)), ("search", search_urls(name))):
            for sample in samples:
                checked += 1
                got = hits_for(sample)
                # twitter and x share a destination, so match the rule name too.
                if got != [(kind, name, ("url", url))]:
                    failures.append(f"{sample}\n  expected {kind} {name} -> {url}\n  got {got}")
        for sample in negative_urls(name):
            checked += 1
            got = hits_for(sample)
            if any(hit[1] == name for hit in got):
                failures.append(f"{sample}\n  unexpectedly matched {name}: {got}")

    for sample in index_positive_urls():
        checked += 1
        got = hits_for(sample)
        if len(got) != 1 or not got[0][0].startswith("index") or got[0][2] != (
            "extensionPath",
            "/index.html",
        ):
            failures.append(f"{sample}\n  expected index\n  got {got}")
    for sample in index_negative_urls():
        checked += 1
        got = hits_for(sample)
        if any(hit[0].startswith("index") for hit in got):
            failures.append(f"{sample}\n  unexpectedly opened the index: {got}")

    if failures:
        sys.stdout.write("\n".join(failures) + "\n")
        return 1

    print(f"ok: {len(mapping)} links, {checked} urls")
    for name, url in mapping.items():
        print(f"  go/{name} -> {url}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (AssertionError, OSError, ValueError, json.JSONDecodeError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
