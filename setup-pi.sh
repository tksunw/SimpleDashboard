#!/usr/bin/env bash
#
# SimpleDashboard — Raspberry Pi Kiosk Setup
#
# Run on the Pi as your normal user (uses sudo where needed):
#   chmod +x setup-pi.sh
#   ./setup-pi.sh
#
# Prerequisites:
#   - Raspberry Pi OS with Desktop (Bookworm or later)
#   - Network connection
#   - config.js in the same directory as this script
#   - Background images in backgrounds/ (run ./update-backgrounds.sh after adding images)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEB_ROOT="/var/www/html"

echo "=== SimpleDashboard Pi Kiosk Setup ==="
echo ""

# --- Validate required files ---
if [ ! -f "$SCRIPT_DIR/config.js" ]; then
    echo "ERROR: config.js not found in $SCRIPT_DIR"
    echo "Copy config.js.default to config.js and fill in your settings first."
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/index.html" ]; then
    echo "ERROR: index.html not found in $SCRIPT_DIR"
    exit 1
fi

# --- Install packages (only if needed) ---
echo "[1/4] Checking packages..."
NEED_INSTALL=()
if ! command -v nginx &> /dev/null; then
    NEED_INSTALL+=(nginx)
else
    echo "       nginx already installed."
fi
if ! dpkg -s fonts-noto-color-emoji &> /dev/null 2>&1; then
    NEED_INSTALL+=(fonts-noto-color-emoji)
else
    echo "       fonts-noto-color-emoji already installed."
fi
if ! command -v unclutter &> /dev/null; then
    NEED_INSTALL+=(unclutter)
else
    echo "       unclutter already installed."
fi

if [ ${#NEED_INSTALL[@]} -gt 0 ]; then
    echo "       Installing: ${NEED_INSTALL[*]}..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${NEED_INSTALL[@]}" > /dev/null
    echo "       Packages installed."
else
    echo "       All packages already installed, skipping."
fi

# --- Deploy dashboard files ---
echo "[2/4] Deploying dashboard to $WEB_ROOT..."
sudo rm -f "$WEB_ROOT/index.nginx-debian.html"
sudo cp "$SCRIPT_DIR/index.html" "$WEB_ROOT/"
sudo cp "$SCRIPT_DIR/config.js" "$WEB_ROOT/"

# Deploy backgrounds
sudo mkdir -p "$WEB_ROOT/backgrounds"
if [ -d "$SCRIPT_DIR/backgrounds" ]; then
    sudo cp "$SCRIPT_DIR/backgrounds/"* "$WEB_ROOT/backgrounds/" 2>/dev/null || true
    echo "       backgrounds/ copied."
else
    echo "       WARNING: No backgrounds/ directory found — add images to $WEB_ROOT/backgrounds/ later."
fi

# Generate manifest
if [ -f "$SCRIPT_DIR/update-backgrounds.sh" ]; then
    sudo bash "$SCRIPT_DIR/update-backgrounds.sh" "$WEB_ROOT"
fi

sudo chown -R www-data:www-data "$WEB_ROOT"
echo "       Dashboard deployed."

# --- Enable and start nginx ---
echo "[3/4] Starting nginx..."
sudo systemctl enable nginx --quiet
sudo systemctl restart nginx
echo "       nginx running on port 80."

# --- Configure kiosk mode ---
echo "[4/4] Configuring kiosk mode..."

AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

# Kiosk launcher script
KIOSK_SCRIPT="$HOME/kiosk.sh"
cat > "$KIOSK_SCRIPT" << 'KIOSK'
#!/usr/bin/env bash

# Wait for desktop and network
sleep 5

# Disable screen blanking and power management
xset s off
xset s noblank
xset -dpms

# Hide cursor after 3 seconds of inactivity
if command -v unclutter &> /dev/null; then
    unclutter -idle 3 -root &
fi

# Launch Chromium in kiosk mode
chromium-browser \
    --kiosk \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-features=TranslateUI \
    --check-for-update-interval=31536000 \
    --disable-component-update \
    --autoplay-policy=no-user-gesture-required \
    http://localhost
KIOSK
chmod +x "$KIOSK_SCRIPT"

# Desktop autostart entry
cat > "$AUTOSTART_DIR/kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Name=SimpleDashboard Kiosk
Exec=$KIOSK_SCRIPT
X-GNOME-Autostart-enabled=true
EOF

echo "       Kiosk autostart configured."

echo ""
echo "=== Setup complete ==="
echo ""
echo "  Dashboard URL:  http://localhost"
echo "  Web root:       $WEB_ROOT"
echo "  Kiosk script:   $KIOSK_SCRIPT"
echo "  Autostart:      $AUTOSTART_DIR/kiosk.desktop"
echo ""
echo "  To test now:    Open Chromium and go to http://localhost"
echo "  To go live:     Reboot the Pi — kiosk starts automatically"
echo ""
echo "  To update files later:"
echo "    sudo cp config.js index.html $WEB_ROOT/"
echo "    sudo cp backgrounds/* $WEB_ROOT/backgrounds/"
echo "    sudo bash update-backgrounds.sh $WEB_ROOT"
echo ""
echo "  To exit kiosk mode: Alt+F4, or SSH in and run:"
echo "    pkill chromium"
