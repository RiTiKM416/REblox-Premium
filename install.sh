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

# Premium Build - Downloading from the Private REblox-Premium repository using the PAT
GITHUB_TOKEN="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"
curl -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3.raw" -sL "https://api.github.com/repos/RiTiKM416/REblox-Premium/contents/gui_reconnector.sh" -o "$PREFIX/bin/roblox-reconnector" &
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

echo ""
echo "Installation complete!"
echo "Starting the application..."
echo ""

# Execute the downloaded GUI directly without the pipe constraint
exec "$PREFIX/bin/roblox-reconnector"
