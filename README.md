# env-pretty.yazi

Readable `.env` previewer for [Yazi](https://github.com/sxyazi/yazi): keys aligned into a column, `=` dimmed, comments dimmed.

## Why

Yazi's code previewer treats a dotenv file as flat text, so keys, the `export` keyword, values and comments all look the same and the file is hard to scan. It is a config table, not prose.

## Requirements

Nothing beyond the base system (`cat`, `wc`). Yazi 25.12.29 or newer (nothing this plugin uses is newer than that; tested on 26.9.1).

## Install

```sh
ya pkg add juanlopez4691/env-pretty.yazi
```

```toml
# ~/.config/yazi/yazi.toml
[[plugin.prepend_previewers]]
url = "*.env*"
run = "env-pretty"
```

Yazi matches `url` patterns against the **full path**, not the file name — a bare `.env*` pattern matches nothing, which is why this one is `*.env*`. It covers `.env`, `.env.example`, `.env.local`, `.env.production`, and `foo.env`.

## Behaviour

```
APP_NAME                     = Laravel
APP_ENV                      = local
APP_KEY                      = base64:QX7D+lQ5ZtcI/j+dN…
APP_DEBUG                    = true

# APP_MAINTENANCE_STORE=database      ← comments dimmed, shown as authored
```

- Keys are padded to the longest key in the file (so the `=` column does not jump while scrolling), capped at 32 characters.
- `export KEY=value` keeps its marker; blank lines are preserved so the file's grouping survives; lines that are not assignments are shown dimmed and unmodified.
- `J` / `K` scroll by lines.

## Caveats

- Files larger than 1 MB fall back to Yazi's code previewer — that is not a dotenv file any more.
- Continuation lines of a multi-line quoted value are shown as authored (the parser only splits at the first `=` of a line).
- Values are not masked. This is a local file preview; if you screenshot your file manager, your secrets are in the picture.

## License

MIT
