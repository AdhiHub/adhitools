#!/usr/bin/env bash
#
# ╔══════════════════════════════════════════════════════╗
# ║       ADHITOOLS — All-in-One Installer v1.0         ║
# ║           9 Advanced Hacking Tools                  ║
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

TOOL_DESC=(
    "SQLi & XSS Scanner with 24+ payloads"
    "Multi-service Brute-forcer (SSH/FTP/MySQL)"
    "GitHub Dorking — secrets, keys & passwords"
    "Cloud Misconfiguration Checker (S3, DNS)"
    "Reverse Shell Generator (Bash/Python/PHP)"
    "Hash Cracker (MD5/SHA1/SHA256) with auto-detect"
    "Phishing URL Analyzer & Page Scanner"
    "Android Payload Builder (reverse/bind/HTTPS)"
    "ARP Spoofing & MITM Toolkit"
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
    echo ""
    echo -e "   ${W}╔═══════════════════════════════════════════╗${RESET}"
    echo -e "   ${W}║     ${C}ADHITOOLS  —  9 TOOLS 1-CLICK SETUP${W}   ║${RESET}"
    echo -e "   ${W}╚═══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "   ${D}┃  For educational & authorized testing only${RESET}"
    echo -e "   ${D}┃  Developer assumes NO liability for misuse${RESET}"
    echo ""
    echo -e "   ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

print_tool_banner() {
    local name="$1"
    local num="$2"
    local total="$3"
    local desc="$4"
    echo ""
    echo -e "   ${W}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    printf "   ${W}┃  ${G}STEP %s/%s${W}  ─  ${C}%-20s${W}┃\n" "$num" "$total" "$name"
    echo -e "   ${W}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    [ -n "$desc" ] && echo -e "   ${D}${desc}${RESET}"
    echo ""
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
        $SUDO apt-get install -y git 2>&1 || $SUDO pacman -S --noconfirm git 2>&1 || true
    fi

    # Clean previous clone if exists
    if [ -d "$dir" ]; then
        echo -e "   ${Y}⟳ Updating $name...${RESET}"
        cd "$dir" && $SUDO git pull --ff-only 2>&1 || true
    else
        echo -e "   ${C}⬇ Cloning $name...${RESET}"
        $SUDO git clone --depth 1 "$url" "$dir" 2>&1 || {
            echo -e "   ${R}✘ Failed to clone $name${RESET}"
            return 1
        }
    fi
    $SUDO chmod -R 755 "$dir" 2>/dev/null || true

    # Run tool-specific installer
    local installed=false

    if [ -f "$dir/install.sh" ]; then
        echo -e "   ${C}⚙ Running installer...${RESET}"
        cd "$dir"
        bash install.sh 2>&1 && installed=true
    elif [ -f "$dir/install.py" ]; then
        echo -e "   ${C}⚙ Running installer...${RESET}"
        cd "$dir"
        $SUDO python3 install.py 2>&1 && installed=true
    else
        local script=""
        for s in "$name.sh" "$name.py" "main.sh" "main.py" "tool.sh" "tool.py"; do
            [ -f "$dir/$s" ] && script="$dir/$s" && break
        done
        if [ -n "$script" ]; then
            $SUDO ln -sf "$script" "/usr/bin/$name" 2>/dev/null && installed=true
        fi
    fi

    if [ "$installed" = true ]; then
        echo -e "   ${G}✔ $name installed successfully${RESET}"
    else
        echo -e "   ${Y}⚠ $name: manual install may be needed${RESET}"
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
echo -e "   ${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "   ${W}┃  ${G}Installing 9 tools...${W}                       ┃${RESET}"
echo -e "   ${W}┃  ${D}This may take a few minutes${W}                 ┃${RESET}"
echo -e "   ${W}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

total="${#TOOLS[@]}"
success=0
failed=0

for i in "${!TOOLS[@]}"; do
    entry="${TOOLS[$i]}"
    name="${entry%%:*}"
    url="${entry#*:}"

    print_tool_banner "$name" $((i+1)) "$total" "$TOOL_DESC[$i]"

    if install_tool "$name" "$url"; then
        ((success++))
    else
        ((failed++))
    fi
    echo ""
done

# Summary
echo ""
echo -e "   ${W}╔═══════════════════════════════════════════╗${RESET}"
echo -e "   ${W}║${G}         INSTALLATION COMPLETE            ${W}║${RESET}"
echo -e "   ${W}╠═══════════════════════════════════════════╣${RESET}"
printf "   ${W}║${G}  ✔ Successful:${W}  %-30d║${RESET}\n" "$success"
printf "   ${W}║${R}  ✘ Failed:${W}      %-30d║${RESET}\n" "$failed"
echo -e "   ${W}╠═══════════════════════════════════════════╣${RESET}"
echo -e "   ${W}║${C}  injectx      ${D}SQLi & XSS Scanner${W}         ║${RESET}"
echo -e "   ${W}║${C}  brutex       ${D}Multi-service Brute-forcer${W}  ║${RESET}"
echo -e "   ${W}║${C}  gitraider    ${D}GitHub Dorking${W}              ║${RESET}"
echo -e "   ${W}║${C}  cloudraider  ${D}Cloud Checker${W}               ║${RESET}"
echo -e "   ${W}║${C}  reversex     ${D}Reverse Shell Generator${W}     ║${RESET}"
echo -e "   ${W}║${C}  crackstation ${D}Hash Cracker${W}                ║${RESET}"
echo -e "   ${W}║${C}  phishnet     ${D}Phishing URL Analyzer${W}       ║${RESET}"
echo -e "   ${W}║${C}  droidx       ${D}Android Payload Builder${W}     ║${RESET}"
echo -e "   ${W}║${C}  spoofx       ${D}ARP Spoofing & MITM${W}         ║${RESET}"
echo -e "   ${W}╠═══════════════════════════════════════════╣${RESET}"
echo -e "   ${W}║${D}  Type any tool name in terminal       ${W}║${RESET}"
echo -e "   ${W}║${D}  to launch it                         ${W}║${RESET}"
echo -e "   ${W}╚═══════════════════════════════════════════╝${RESET}"
echo ""
