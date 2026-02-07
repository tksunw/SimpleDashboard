# Dashboard

A clean, self-contained web dashboard designed for a vertically-mounted monitor. Zero dependencies, zero build step — just a single HTML file with embedded CSS and vanilla JS.

## Features

- **Clock** — large, updates every second, 12 or 24-hour format
- **Date** — day of week and full date on a single line
- **Weather** — current conditions with icon, temperature, and "feels like" plus a 3-day forecast (via [PirateWeather](https://pirateweather.net/))
- **Calendar** — current month grid with today highlighted
- **Background image** — full-bleed with dark overlay for text contrast
- **Auto-scaling** — all elements scale proportionally to fit any browser size, from phones to large monitors

## Setup

1. Copy the example config and fill in your values:

   ```sh
   cp config.js.default config.js
   ```

2. Edit `config.js`:
   - Get a free API key from [PirateWeather](https://pirateweather.net/)
   - Set your latitude and longitude
   - Adjust units, time format, etc.

3. Drop a `background.jpg` in the project directory (any resolution — it will be scaled to cover the screen).

4. Serve with any web server:

   ```sh
   python3 -m http.server 8080
   ```

   Then open `http://localhost:8080` in a browser.

## Configuration

All settings are in `config.js`:

| Setting | Description | Default |
|---|---|---|
| `weatherApiKey` | PirateWeather API key | — |
| `weatherLat` | Latitude | — |
| `weatherLon` | Longitude | — |
| `weatherUnits` | `'us'` (Fahrenheit) or `'si'` (Celsius) | `'us'` |
| `weatherRefreshMin` | Minutes between weather updates | `15` |
| `backgroundImage` | Path to background image | `'background.jpg'` |
| `timeFormat` | `12` or `24` hour clock | `12` |

## Files

| File | Tracked | Purpose |
|---|---|---|
| `index.html` | Yes | Dashboard (HTML + CSS + JS) |
| `config.js.default` | Yes | Example config with placeholder values |
| `config.js` | No | Your actual config (gitignored) |
| `background.jpg` | No | Your background image (gitignored) |
