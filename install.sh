#!/data/data/com.termux/files/usr/bin/bash

# Termux Auto-Reconnector Bootstrapper
# Optimized for Public Repository Access

# --- Utilities ---
if command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); NORMAL=$(tput sgr0); RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); CYAN=$(tput setaf 6)
else
  BOLD=''; NORMAL=''; RED=''; GREEN=''; YELLOW=''; CYAN=''
fi

echo -e "${CYAN}======================================"
echo -e "                REblox                "
echo -e "                Setup                 "
echo -e "======================================${NORMAL}"

# --- Dependency Installation ---
echo -e "${YELLOW}[*] Checking essential packages...${NORMAL}"
# Only install if missing to save time
for pkg in tsu procps coreutils ncurses-utils curl; do
    if ! command -v $pkg >/dev/null 2>&1 && ! dpkg -s $pkg >/dev/null 2>&1; then
        echo -e "${YELLOW}[!] Installing $pkg...${NORMAL}"
        pkg install -y $pkg
    fi
done

# --- Download Main Application ---
echo -e "${YELLOW}[*] Downloading core GUI script...${NORMAL}"
DEST="$PREFIX/bin/roblox-reconnector"

# Download with a simple progress indicator
curl -L "https://raw.githubusercontent.com/RiTiKM416/REblox-Premium/main/gui_reconnector.sh" -o "$DEST"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}[-][ERROR] Download failed! Please check your internet connection.${NORMAL}"
    exit 1
fi

if [[ ! -s "$DEST" ]]; then
    echo -e "${RED}[-][ERROR] Downloaded file is empty! GitHub might be blocked or URL is wrong.${NORMAL}"
    exit 1
fi

chmod +x "$DEST"

# CRITICAL FIX: Ensure 'exec < /dev/tty' is at the top for pipe installations
# We check the first few lines specifically.
if ! head -n 15 "$DEST" | grep -q 'exec < /dev/tty'; then
    echo -e "${YELLOW}[*] Patching stdin redirection...${NORMAL}"
    sed -i '2i\\nexec < /dev/tty' "$DEST"
fi

echo -e "\n${GREEN}[✓] Installation complete!${NORMAL}"
echo -e "${CYAN}[*] Starting REblox Premium...${NORMAL}\n"

# Launch in a way that definitely detaches from any previous pipe
# We use 'bash' directly to ensure the new state is clean.
exec bash "$DEST" < /dev/tty
