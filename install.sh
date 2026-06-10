#!/usr/bin/env bash
#
# ╔══════════════════════════════════════════════════════╗
# ║       ADHITOOLS — All-in-One Installer v1.0         ║
# ║     Cyber Pentools + 9 Advanced Hacking Tools       ║
# ╚══════════════════════════════════════════════════════╝
# Educational purposes only. Use at your own risk.
#

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
R='\033[1;31m'; G='\033[1;32m'; C='\033[1;36m'; Y='\033[1;33m'; M='\033[1;35m'
W='\033[1;37m'; D='\033[0;37m'; B='\033[1;34m'; RESET='\033[0m'

# ── Detect privilege ──────────────────────────────────────────────────────────
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# ── Tools list ────────────────────────────────────────────────────────────────
TOOLS=(
    "injectx:https://github.com/AdhiHub/injectx.git"
    "brutex:https://github.com/AdhiHub/brutex.git"
    "gitraider:https://github.com/AdhiHub/gitraider.git"
    "cloudraider:https://github.com/AdhiHub/cloudraider.git"
    "reversex:https://github.com/AdhiHub/reversex.git"
    "crackstation:https://github.com/AdhiHub/crackstation.git"
    "phishnet:https://github.com/AdhiHub/phishnet.git"
    "droidx:https://github.com/AdhiHub/droidx.git"
    "spoofx:https://github.com/AdhiHub/spoofx.git"
)

INSTALL_DIR="/opt/adhitools"

# ── Functions ─────────────────────────────────────────────────────────────────

print_banner() {
    clear
    echo -e "${R}"
    echo '    █████╗ ██████╗ ██╗  ██╗██╗████████╗ ██████╗  ██████╗ ██╗     '
    echo '   ██╔══██╗██╔══██╗██║  ██║██║╚══██╔══╝██╔═══██╗██╔═══██╗██║     '
    echo '   ███████║██║  ██║███████║██║   ██║   ██║   ██║██║   ██║██║     '
    echo '   ██╔══██║██║  ██║██╔══██║██║   ██║   ██║   ██║██║   ██║██║     '
    echo '   ██║  ██║██████╔╝██║  ██║██║   ██║   ╚██████╔╝╚██████╔╝███████╗'
    echo '   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝'
    echo -e "${RESET}"
    echo -e "${G}   ╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${G}   ║      ${W}ALL-IN-ONE INSTALLER${G}  —  ${C}9 TOOLS${G}           ║${RESET}"
    echo -e "${G}   ╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${D}   [!] For educational & authorized testing only${RESET}"
    echo -e "${D}   [!] Developer assumes NO liability for misuse${RESET}"
    echo ""
}

print_tool_banner() {
    local name="$1"
    local num="$2"
    local total="$3"
    echo ""
    echo -e "${M}   ═══════════════════════════════════════════${RESET}"
    echo -e "${M}   [${Y}$num/${total}${M}] Installing: ${C}$name${RESET}"
    echo -e "${M}   ═══════════════════════════════════════════${RESET}"
}

print_usage() {
    echo ""
    echo -e "${Y}   Usage:${RESET}"
    echo -e "${D}     curl -fsSL https://raw.githubusercontent.com/AdhiHub/adhitools/main/install.sh | bash${RESET}"
    echo ""
    echo -e "${Y}   Options:${RESET}"
    echo -e "${D}     --list           List all tools${RESET}"
    echo -e "${D}     --tool <name>    Install a single tool${RESET}"
    echo ""
}

list_tools() {
    echo ""
    echo -e "${G}   Available tools:${RESET}"
    for entry in "${TOOLS[@]}"; do
        name="${entry%%:*}"
        echo -e "${C}     • ${W}$name${RESET}"
    done
    echo ""
}

install_single_tool() {
    local target="$1"
    for entry in "${TOOLS[@]}"; do
        name="${entry%%:*}"
        if [ "$name" = "$target" ]; then
            url="${entry#*:}"
            print_tool_banner "$name" 1 1
            install_tool "$name" "$url"
            return
        fi
    done
    echo -e "${R}[!] Tool '$target' not found${RESET}"
    list_tools
    exit 1
}

install_tool() {
    local name="$1"
    local url="$2"
    local dir="$INSTALL_DIR/$name"

    # Check/install deps
    if ! command -v git &>/dev/null; then
        echo -e "${Y}[*] Installing git...${RESET}"
        $SUDO apt-get install -y git &>/dev/null || $SUDO pacman -S --noconfirm git &>/dev/null || true
    fi

    # Clone or update
    if [ -d "$dir" ]; then
        echo -e "${Y}[~] Updating $name...${RESET}"
        cd "$dir" && git pull --ff-only 2>/dev/null || true
    else
        echo -e "${C}[*] Cloning $name...${RESET}"
        git clone --depth 1 "$url" "$dir" 2>/dev/null || {
            echo -e "${R}[✘] Failed to clone $name${RESET}"
            return 1
        }
    fi

    # Run tool-specific installer
    local installed=false

    # Check if install.sh exists
    if [ -f "$dir/install.sh" ]; then
        echo -e "${C}[*] Running installer for $name...${RESET}"
        cd "$dir"
        bash install.sh 2>/dev/null && installed=true
    elif [ -f "$dir/install.py" ]; then
        echo -e "${C}[*] Running installer for $name...${RESET}"
        cd "$dir"
        $SUDO python3 install.py 2>/dev/null && installed=true
    else
        # Just create symlink to the script
        local script=""
        for s in "$name.sh" "$name.py" "main.sh" "main.py" "tool.sh" "tool.py"; do
            [ -f "$dir/$s" ] && script="$dir/$s" && break
        done
        if [ -n "$script" ]; then
            $SUDO ln -sf "$script" "/usr/bin/$name" 2>/dev/null && installed=true
        fi
    fi

    if [ "$installed" = true ]; then
        echo -e "${G}[✔] $name installed successfully${RESET}"
    else
        echo -e "${Y}[!] $name: manual install may be needed${RESET}"
        echo -e "${D}    Files at: $dir${RESET}"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

# Handle flags
case "${1:-}" in
    --help|-h)
        print_banner
        print_usage
        exit 0
        ;;
    --list|-l)
        print_banner
        list_tools
        exit 0
        ;;
    --tool|-t)
        [ -z "$2" ] && { echo -e "${R}[!] Specify a tool name${RESET}"; list_tools; exit 1; }
        print_banner
        echo -e "${C}   Single tool mode: $2${RESET}"
        install_single_tool "$2"
        echo -e "${G}[✔] Done${RESET}"
        exit 0
        ;;
esac

# Full installation
print_banner

# Check prerequisites
echo -e "${C}[*] Checking prerequisites...${RESET}"
for cmd in git curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${R}[!] $cmd is required but not installed${RESET}"
        echo -e "${Y}[*] Install with: sudo apt install $cmd${RESET}"
        exit 1
    fi
done
echo -e "${G}[✔] All prerequisites met${RESET}"

# Create install directory
$SUDO mkdir -p "$INSTALL_DIR"

echo ""
echo -e "${G}   ┌─────────────────────────────────────────────────────┐${RESET}"
echo -e "${G}   │  ${W}Starting installation of ${C}9 tools${G}                       │${RESET}"
echo -e "${G}   │  ${D}This may take a few minutes...${G}                       │${RESET}"
echo -e "${G}   └─────────────────────────────────────────────────────┘${RESET}"
echo ""

total="${#TOOLS[@]}"
success=0
failed=0

for i in "${!TOOLS[@]}"; do
    entry="${TOOLS[$i]}"
    name="${entry%%:*}"
    url="${entry#*:}"

    print_tool_banner "$name" $((i+1)) "$total"

    if install_tool "$name" "$url"; then
        ((success++))
    else
        ((failed++))
    fi
    echo ""
done

# Summary
echo ""
echo -e "${G}   ╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${G}   ║${W}               INSTALLATION COMPLETE                 ${G}║${RESET}"
echo -e "${G}   ╠══════════════════════════════════════════════════════╣${RESET}"
printf "${G}   ║  ${W}Total tools:${G}  %-38d║${RESET}\n" "$total"
printf "${G}   ║  ${G}Successful:${G} %-38d║${RESET}\n" "$success"
printf "${G}   ║  ${R}Failed:${G}     %-38d║${RESET}\n" "$failed"
echo -e "${G}   ╠══════════════════════════════════════════════════════╣${RESET}"
echo -e "${G}   ║                                                       ║${RESET}"
echo -e "${G}   ║  ${C}  injectx${RESET}     ${D}— SQLi & XSS Scanner${G}                ║${RESET}"
echo -e "${G}   ║  ${C}  brutex${RESET}      ${D}— Multi-service Brute-forcer${G}         ║${RESET}"
echo -e "${G}   ║  ${C}  gitraider${RESET}   ${D}— GitHub Dorking Tool${G}               ║${RESET}"
echo -e "${G}   ║  ${C}  cloudraider${RESET} ${D}— Cloud Misconfiguration Checker${G}    ║${RESET}"
echo -e "${G}   ║  ${C}  reversex${RESET}    ${D}— Reverse Shell Generator${G}           ║${RESET}"
echo -e "${G}   ║  ${C}  crackstation${RESET} ${D}— Hash Cracker${G}                     ║${RESET}"
echo -e "${G}   ║  ${C}  phishnet${RESET}     ${D}— Phishing URL Analyzer${G}             ║${RESET}"
echo -e "${G}   ║  ${C}  droidx${RESET}      ${D}— Android Payload Builder${G}           ║${RESET}"
echo -e "${G}   ║  ${C}  spoofx${RESET}       ${D}— ARP Spoofing & MITM Toolkit${G}      ║${RESET}"
echo -e "${G}   ╠══════════════════════════════════════════════════════╣${RESET}"
echo -e "${G}   ║                                                     ║${RESET}"
echo -e "${G}   ║  ${D}Type any tool name in terminal to launch it${G}    ║${RESET}"
echo -e "${G}   ╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
