#!/data/data/com.termux/files/usr/bin/bash

# Termux Auto-Reconnector Bootstrapper
# This script is designed to be run via: curl | bash

# This script is designed to be downloaded and run locally.

# --- Utilities ---
# Colors using tput if available, fall back to ANSI
if command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold)
  NORMAL=$(tput sgr0)
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  MAG=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  GRAY=$(tput setaf 7)
else
  BOLD='\e[1m'
  NORMAL='\e[0m'
  RED='\e[31m'
  GREEN='\e[32m'
  YELLOW='\e[33m'
  BLUE='\e[34m'
  MAG='\e[35m'
  CYAN='\e[36m'
  GRAY='\e[37m'
fi

# --- Device & Auth Init ---
AUTH_FILE="$HOME/.termux_reconnector_auth"
if [[ -f "$AUTH_FILE" ]]; then
    source "$AUTH_FILE"
fi

if [[ -z "$DEVICE_ID" ]]; then
    DEVICE_ID="DEV-$(cat /proc/sys/kernel/random/uuid | cut -c 1-8 | tr 'a-z' 'A-Z')"
fi

echo "======================================"
echo "                REblox                "
echo "                Setup                 "
echo "======================================"

# --- Platoboost Authentication ---
PROJECT_ID="21504"
DISCORD_LINK="https://discord.gg/ZFjE9yqUNy"

verify_key_silently() {
    return 0 # Bypass verification for private Premium build
}

# --- Dependency Installation ---
echo "Checking and installing essential Termux packages (tsu, procps, etc.)..."
echo "This might take a moment on the first run..."
pkg update -y
pkg install -y tsu procps coreutils ncurses-utils
echo "Essential packages successfully verified/installed."
echo ""

# --- Download Main Application ---
echo "Downloading core GUI script..."

# Premium Build - Downloading from the Public REblox-Premium repository
curl -sL "https://raw.githubusercontent.com/RiTiKM416/REblox-Premium/main/gui_reconnector.sh" -o "$PREFIX/bin/roblox-reconnector" &
CURL_PID=$!

spin='-\|/'
i=0
while kill -0 $CURL_PID 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r\e[36m[${spin:$i:1}] Downloading...\e[0m"
    sleep 0.1
done

printf "\r\e[32m[✓] Download complete!       \e[0m\n"
chmod +x "$PREFIX/bin/roblox-reconnector"

# CRITICAL FIX: Inject 'exec < /dev/tty' into the downloaded script if not present.
# When running via 'curl | bash', stdin is the pipe (not the keyboard).
# This ensures ALL 'read' commands inside the app read from the real terminal.
if ! grep -q 'exec < /dev/tty' "$PREFIX/bin/roblox-reconnector" 2>/dev/null; then
    sed -i '1a\\nexec < /dev/tty' "$PREFIX/bin/roblox-reconnector"
fi

echo ""
echo "Installation complete!"
echo "Starting the application..."
echo ""

# Launch in a fresh bash process with stdin explicitly from the terminal
bash "$PREFIX/bin/roblox-reconnector" < /dev/tty
