# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A single-page web dashboard (clock, date, weather, calendar) for vertically-mounted monitors. Zero dependencies, zero build step — vanilla HTML/CSS/JS in one file (`index.html`). Deployed as static files via any web server; optionally runs in Chromium kiosk mode on a Raspberry Pi.

## Running Locally

```sh
python3 -m http.server 8080
```

No build, no install, no compile. Just serve and open `http://localhost:8080`.

## Key Architecture

**Everything is in `index.html`** — embedded `<style>`, inline `<script>`, no external JS/CSS. The only external dependency is `config.js` (loaded via `<script src>`).

**Config pattern:** `config.js.default` (tracked) is the template; `config.js` (gitignored) is the user's actual config. Same pattern for `backgrounds.json.default` / `backgrounds.json`.

**Responsive scaling system:** All sizes use `calc(var(--s) * N)`. On init and resize, JS measures content at `--s=1px` to get natural dimensions, then computes the optimal `--s` value to fill the viewport proportionally.

**Background cycling:** Two absolutely-positioned div layers (`#bg-a`, `#bg-b`) crossfade via CSS `transition: opacity`. JS preloads images before swapping opacity to avoid flicker. Manifest (`backgrounds.json`) is re-fetched each cycle tick. Backgrounds are selected by filename prefix priority:
1. Date-specific (`MMDD` prefix, e.g. `0214-valentines.jpg`)
2. Month-specific (`MM` + non-digit, e.g. `02-winter.jpg`)
3. Season-specific (`spring-`/`summer-`/`autumn-`/`winter-` prefix) — uses `CONFIG.weatherLat` to flip for southern hemisphere
4. General (no prefix, e.g. `bokeh1.jpg`)

**Weather:** PirateWeather API, fetched on an interval. After forecast renders, content is re-measured and scale is recalculated.

## Background Image Workflow

```sh
# Add/remove images in backgrounds/, then regenerate manifest:
./update-backgrounds.sh
```

The script scans for jpg/jpeg/png/webp/gif/avif and writes `backgrounds.json`. Defaults to `/var/www/html` on the Pi (falls back to script directory). Accepts an optional path argument to override.

## Pi Deployment

`setup-pi.sh` is idempotent — checks for existing packages before installing. Always copies dashboard files to `/var/www/html`. Run it again safely after changes.
