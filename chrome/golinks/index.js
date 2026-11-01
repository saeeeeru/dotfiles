const directLink = /^\^https\?:\/\/go\/([a-z0-9-]+)\/\?\$/;

async function main() {
  const list = document.querySelector("#links");
  if (!globalThis.chrome?.runtime?.getURL) {
    list.textContent = "拡張機能として読み込まれていません。";
    return;
  }

  let rules;
  try {
    const response = await fetch(chrome.runtime.getURL("rules.json"));
    rules = await response.json();
  } catch (error) {
    list.textContent = "rules.json を読めませんでした。";
    return;
  }

  for (const rule of rules) {
    const regex = rule.condition && rule.condition.regexFilter;
    const url = rule.action && rule.action.redirect && rule.action.redirect.url;
    const match = typeof regex === "string" ? directLink.exec(regex) : null;
    if (!match || typeof url !== "string") continue;

    const item = document.createElement("li");
    const code = document.createElement("code");
    code.textContent = "go/" + match[1];
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.textContent = url;
    item.append(code, document.createTextNode(" → "), anchor);
    list.append(item);
  }
}

main();
