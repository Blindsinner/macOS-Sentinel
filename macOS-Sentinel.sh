#!/bin/zsh

# ┌──────────────────────────────────────────────────┐
# │ macOS Sentinel v5.0 (Final)                      │
# │ Author: md faysal mahmud                         │
# │ A hardened, production-ready toolkit for modern  │
# │ macOS administration.                            │
# └──────────────────────────────────────────────────┘

# ------------------------------------------------------------------------------
# CONFIGURATION & CONSTANTS
# ------------------------------------------------------------------------------
# Source a user-specific override file ($HOME/.sentinelrc) if present.
# This allows an admin to customize SCRIPT_URL, SCRIPT_VERSION, LOG_FILE, etc.
if [ -f "$HOME/.sentinelrc" ]; then
    source "$HOME/.sentinelrc"
fi

# Use parameter expansion to set defaults if not overridden above.
# SCRIPT_VERSION: Identify this release in logs and banners.
: "${SCRIPT_VERSION:="5.0"}"
# SCRIPT_URL: Raw GitHub URL to fetch updates from.
: "${SCRIPT_URL:="https://raw.githubusercontent.com/user/repo/main/sentinel.sh"}"
# LOG_FILE: Central audit log to track every action.
: "${LOG_FILE:="$HOME/Library/Logs/macOS_Sentinel.log"}"


# ------------------------------------------------------------------------------
# STYLE & ANSI COLOR CODES
# ------------------------------------------------------------------------------
# These variables define colored output for clarity and emphasis.
# - C_BLUE: Section headers
# - C_GREEN: Success messages
# - C_RED: Errors / Danger
# - C_YELLOW: Prompts and warnings
# - C_NC: Reset to default terminal color
C_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_RED='\033[1;31m'
C_YELLOW='\033[0;33m'
C_NC='\033[0m'


# ------------------------------------------------------------------------------
# ASCII BANNER FUNCTION
# ------------------------------------------------------------------------------
# display_art prints a stylized Sentinel logo + version header.
display_art() {
    echo "          \`'::.\`"
    echo "      \`::::::::::::::::.\`"
    echo "    \`::::::::::::::::::::.\`"
    echo "   ::::::::::::::::::::::::\`"
    echo "  ::::::::::'    '::::::::::\`"
    echo " ::::::::::   ()   ::::::::::"
    echo ".:::::::::'        \`:::::::::."
    echo "::::::::::          ::::::::::"
    echo "::::::::::          ::::::::::"
    echo "\`:::::::::.        .:::::::::'"
    echo " ::::::::::,,,,,,::::::::::"
    echo "  \`::::::::::::::'::::::::\`"
    echo "   .::::::::::::'::::::::."
    echo "     \`::::::::'::::::::\`"
    echo "        \`::::'::::\`"
    echo "           \`'::\`"
    echo "\n     ${C_BLUE}macOS Sentinel v${SCRIPT_VERSION}${C_NC}\n"
}


# ------------------------------------------------------------------------------
# UTILITY FUNCTIONS
# ------------------------------------------------------------------------------

# pause: Wait for the user to hit Enter before returning to menu
pause() {
    echo "\n${C_YELLOW}Press Enter to continue...${C_NC}"
    read -r
}

# log_action: Append a timestamped message to LOG_FILE, using flock
# for atomic writes even if multiple instances run concurrently.
log_action() {
    (
        flock -x 200
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    ) 200>> "$LOG_FILE"
}


# ------------------------------------------------------------------------------
# DEPENDENCY & ENVIRONMENT CHECKS
# ------------------------------------------------------------------------------

# check_dependencies: Ensure all required commands are present, or abort.
check_dependencies() {
    local missing_deps=()
    local dependencies=("curl" "profiles" "osascript" "diskutil" "networksetup" \
                        "pkill" "pgrep" "sudo" "mktemp" "awk" "head" "flock")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "${C_RED}FATAL ERROR: Missing commands:${C_NC}"
        printf " - %s\n" "${missing_deps[@]}"
        echo "Install these or add them to \$PATH, then rerun Sentinel."
        log_action "FATAL: Missing dependencies: ${missing_deps[*]}"
        pause
        exit 1
    fi
}

# check_brew: Prompt to install Homebrew if missing, so cask installs work.
check_brew() {
    if ! command -v brew &> /dev/null; then
        log_action "Homebrew not found. Prompting user to install."
        echo "${C_RED}Homebrew is not installed.${C_NC}"
        read -r -q "choice?Install Homebrew now? (y/n) "
        echo
        if [[ "$choice" == "y" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            local code=$?
            if [ $code -ne 0 ]; then
                echo "${C_RED}❌ Homebrew install failed (exit $code).${C_NC}"
                log_action "ERROR: Homebrew install failed ($code)."
                return 1
            fi
            # Initialize brew environment for Apple Silicon
            if [ -x "/opt/homebrew/bin/brew" ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        else
            log_action "User declined Homebrew installation."
            return 1
        fi
    fi
    return 0
}


# ------------------------------------------------------------------------------
# CORE FUNCTIONALITY
# ------------------------------------------------------------------------------

### 1) Fix Wi-Fi Connectivity
fix_wifi() {
    log_action "Task: Fix Wi-Fi"
    local port
    port=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
    if [ -z "$port" ]; then
        echo "${C_RED}❌ No Wi-Fi port found.${C_NC}"
        log_action "ERROR: No Wi-Fi hardware port detected."
    else
        if sudo networksetup -setairportpower "$port" off && sleep 2 && sudo networksetup -setairportpower "$port" on; then
            echo "${C_GREEN}✅ Wi-Fi toggled on $port.${C_NC}"
            log_action "SUCCESS: Wi-Fi toggled on $port."
        else
            echo "${C_RED}❌ Failed to toggle Wi-Fi.${C_NC}"
            log_action "ERROR: Could not toggle Wi-Fi on $port."
        fi
    fi
    pause
}

### 2) Fix Bluetooth Connectivity
fix_bluetooth() {
    log_action "Task: Fix Bluetooth"
    if sudo pkill bluetoothd; then
        sleep 2
        if pgrep -x bluetoothd &> /dev/null; then
            echo "${C_GREEN}✅ Bluetooth daemon restarted.${C_NC}"
            log_action "SUCCESS: bluetoothd restarted."
        else
            echo "${C_RED}❌ bluetoothd did not restart.${C_NC}"
            log_action "ERROR: bluetoothd failed to restart."
        fi
    else
        echo "${C_RED}❌ Could not stop bluetoothd.${C_NC}"
        log_action "ERROR: Could not pkill bluetoothd."
    fi
    pause
}

### 3) Run Standard Maintenance
run_maintenance() {
    log_action "Task: Run maintenance scripts"
    if sudo periodic daily weekly monthly \
       && sudo dscacheutil -flushcache \
       && sudo killall -HUP mDNSResponder \
       && sudo mdutil -E /; then
        echo "${C_GREEN}✅ Maintenance complete (Spotlight reindex backgrounded).${C_NC}"
        log_action "SUCCESS: Maintenance tasks done."
    else
        echo "${C_RED}❌ Some maintenance tasks failed.${C_NC}"
        log_action "ERROR: One or more maintenance tasks failed."
    fi
    pause
}

### 4) Clear All Caches
clear_caches() {
    log_action "Task: Clear caches"
    read -r -q "choice?This will close apps and need a reboot. Proceed? (y/n) "
    echo
    if [[ "$choice" != "y" ]]; then
        log_action "User cancelled cache clearing."
        pause; return
    fi
    osascript -e 'tell application "System Events" to quit every process whose visible is true and name is not "Terminal"'
    rm -rf ~/Library/Caches/*
    if sudo rm -rf /Library/Caches/*; then
        echo "${C_GREEN}✅ Caches cleared. Please restart your Mac.${C_NC}"
        log_action "SUCCESS: Caches cleared."
    else
        echo "${C_RED}❌ Could not clear system caches.${C_NC}"
        log_action "ERROR: Failed to clear /Library/Caches."
    fi
    pause
}

### 5) Repair Home-Folder Permissions
fix_permissions() {
    log_action "Task: Repair home-folder permissions"
    read -r -q "choice?Proceed with permissions reset? (y/n) "
    echo
    if [[ "$choice" == "y" ]]; then
        if diskutil resetUserPermissions / "$(id -u)"; then
            echo "${C_GREEN}✅ Permissions repaired.${C_NC}"
            log_action "SUCCESS: Permissions reset."
        else
            echo "${C_RED}❌ Permissions reset failed.${C_NC}"
            log_action "ERROR: diskutil resetUserPermissions failed."
        fi
    else
        log_action "User cancelled permissions reset."
    fi
    pause
}


# ------------------------------------------------------------------------------
# SOFTWARE & ENTERPRISE MANAGEMENT
# ------------------------------------------------------------------------------

### 6) Install Apps via Homebrew Cask
software_installer() {
    if ! check_brew; then pause; return; fi
    log_action "Task: Install apps"
    echo "Enter app slugs (e.g. google-chrome slack):"
    read -r "apps?Apps: "
    for app in ${(s: :)apps}; do
        brew install --cask "$app" \
          && log_action "Installed $app" \
          || log_action "ERROR: Failed to install $app"
    done
    echo "${C_GREEN}✅ Installation complete. Check logs for details.${C_NC}"
    pause
}

### 7) Update All Homebrew Packages & Casks
software_updater() {
    if ! check_brew; then pause; return; fi
    log_action "Task: Update all brew packages"
    if brew update && brew upgrade; then
        echo "${C_GREEN}✅ All Homebrew packages updated.${C_NC}"
        log_action "SUCCESS: brew update && upgrade"
    else
        echo "${C_RED}❌ Brew update/upgrade had errors.${C_NC}"
        log_action "ERROR: brew update or upgrade failed."
    fi
    pause
}

### 8) Open Microsoft Intune Company Portal
open_intune() {
    log_action "Task: Open Company Portal"
    if [ -d "/Applications/Company Portal.app" ]; then
        open -a "Company Portal"
        echo "➡️ Please sign in to enroll or check compliance."
        log_action "Opened Company Portal."
    else
        echo "${C_RED}❌ Company Portal.app not installed.${C_NC}"
        log_action "ERROR: Company Portal.app missing."
    fi
    pause
}


# ------------------------------------------------------------------------------
# DIAGNOSTICS & SCRIPT MANAGEMENT
# ------------------------------------------------------------------------------

### 9) Generate Comprehensive System Report
generate_report() {
    log_action "Task: Generate system report"
    local out="$HOME/Desktop/macOS_Sentinel_Report_$(date +%F_%H-%M-%S).txt"
    {
        echo "=== macOS Sentinel System Report (v${SCRIPT_VERSION}) ==="
        echo "Date: $(date)"
        echo "\n-- Hardware --"; system_profiler SPHardwareDataType
        echo "\n-- Software --"; sw_vers
        echo "\n-- Disk Usage --"; df -h
        echo "\n-- Top Processes --"; ps aux | sort -rk 3 | head -n 10
        echo "\n-- Intune Status --"
        if [ -d "/Applications/Company Portal.app" ]; then
            defaults read com.microsoft.CompanyPortal RegisteredDate 2>/dev/null \
            && defaults read com.microsoft.CompanyPortal LastSyncDate 2>/dev/null
        else
            echo "Not installed"
        fi
    } > "$out"
    echo "${C_GREEN}✅ Report saved to $out${C_NC}"
    log_action "Report generated: $out"
    pause
}

### 10) Explain SMC / NVRAM Reset on Silicon
explain_smc_nvram() {
    log_action "Task: Explain SMC/NVRAM"
    echo "\n--- SMC & NVRAM Reset on Apple Silicon ---"
    echo "Apple Silicon combines SMC/NVRAM logic into the firmware stack."
    echo "${C_GREEN}➡️ To “reset,” shut down the Mac, wait 30s, then power on.${C_NC}"
    pause
}

### 11) Self-Update Sentinel from GitHub
self_update() {
    log_action "Task: Self-update check"
    echo "\nChecking for updates..."
    local tmp; tmp=$(mktemp)
    if ! curl -fsSL "$SCRIPT_URL" -o "$tmp"; then
        echo "${C_RED}❌ Could not fetch updates.${C_NC}"
        rm "$tmp"; pause; return
    fi
    if ! cmp -s "$tmp" "$0"; then
        echo "${C_GREEN}Update available!${C_NC}"
        read -r -q "choice?Install now? (y/n) "; echo
        if [[ "$choice" == "y" ]]; then
            mv "$tmp" "$0" && chmod +x "$0"
            echo "Update applied. Relaunching..."
            exec "$0"
        else
            rm "$tmp"
            log_action "User skipped self-update."
        fi
    else
        echo "${C_GREEN}✅ Already at latest version.${C_NC}"
        rm "$tmp"
    fi
    pause
}


# ------------------------------------------------------------------------------
# DANGER ZONE: IRREVERSIBLE ACTIONS
# ------------------------------------------------------------------------------

### Unenroll from Intune Company Portal (Guided)
unenroll_intune() {
    log_action "DANGER: Unenroll Intune"
    echo "${C_RED}This will remove corporate management access.${C_NC}"
    read -r -q "choice?Continue? (y/n) "; echo
    if [[ "$choice" == "y" && -d "/Applications/Company Portal.app" ]]; then
        open -a "Company Portal"
        echo "Follow Portal UI: Devices → This Mac → Remove."
    else
        log_action "User cancelled or Company Portal missing."
    fi
}

### Remove All MDM Configuration Profiles
delete_management_profiles() {
    log_action "DANGER: Delete MDM profiles"
    read -r -q "choice?This severs ALL MDM. Are you sure? (y/n) "; echo
    if [[ "$choice" != "y" ]]; then
        log_action "Cancelled profile purge."; return
    fi
    local ids; ids=("${(@f)$(profiles list -type Configuration | awk -F': ' '/Identifier/{print $2}')}")
    for id in "${ids[@]}"; do
        sudo profiles remove -identifier "$id" \
          && log_action "Removed profile $id" \
          || log_action "ERROR: Failed to remove $id"
    done
    echo "${C_GREEN}✅ Profiles removed (if possible).${C_NC}"
}

### Factory-Reset Mac (Erase All Content & Settings)
factory_reset_mac() {
    log_action "DANGER: Factory reset"
    echo "${C_RED}‼️ EXTREME DANGER: This ERASES ALL DATA ‼️${C_NC}"
    echo "Type exactly 'ERASE THIS MAC' to confirm:"
    read -r "confirmation? "
    if [[ "$confirmation" == "ERASE THIS MAC" ]]; then
        open "x-apple.systempreferences:com.apple.Reset-Settings.extension"
        echo "${C_YELLOW}Follow on-screen steps to wipe device.${C_NC}"
        log_action "User initiated factory reset."
    else
        echo "Confirmation mismatch—aborting."
        log_action "Factory reset aborted (confirmation)."
    fi
}

# Danger Zone menu loop
danger_zone_menu() {
    while true; do
        clear; display_art
        echo "${C_RED}--- DANGER ZONE ---${C_NC}"
        echo "1) Unenroll from Intune"
        echo "2) Delete MDM Profiles"
        echo "3) Factory Reset Mac"
        echo "B) Back to Main Menu"
        read -r "choice?Choice: "
        case "$choice" in
            1) unenroll_intune; pause ;;
            2) delete_management_profiles; pause ;;
            3) factory_reset_mac; pause ;;
            [bB]) return ;;
            *) echo "${C_RED}Invalid choice.${C_NC}"; pause ;;
        esac
    done
}


# ------------------------------------------------------------------------------
# MAIN EXECUTION LOOP
# ------------------------------------------------------------------------------
# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"
log_action "=== Sentinel v${SCRIPT_VERSION} STARTED ==="
check_dependencies

while true; do
    # Ensure Homebrew environment on Apple Silicon
    [ -x "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    clear; display_art

    # Main menu
    echo "Select an option:"
    echo "------------------------------------------"
    echo " ${C_BLUE}QUICK FIXES & MAINTENANCE${C_NC}"
    echo " 1) Fix Wi-Fi        4) Clear Caches"
    echo " 2) Fix Bluetooth    5) Repair Permissions"
    echo " 3) Run Maintenance"
    echo "\n ${C_BLUE}SOFTWARE & ENTERPRISE${C_NC}"
    echo " 6) Install Apps     8) Open Company Portal"
    echo " 7) Update All Apps"
    echo "\n ${C_BLUE}DIAGNOSTICS & INFO${C_NC}"
    echo " 9) Generate Report  11) Check for Updates"
    echo " 10) Explain SMC/NVRAM"
    echo "\n ${C_RED}D) DANGER ZONE${C_NC}"
    echo "------------------------------------------"
    echo " Q) Quit"
    echo "------------------------------------------"

    read -r "choice?Enter choice: "
    case "$choice" in
        1) fix_wifi ;;
        2) fix_bluetooth ;;
        3) run_maintenance ;;
        4) clear_caches ;;
        5) fix_permissions ;;
        6) software_installer ;;
        7) software_updater ;;
        8) open_intune ;;
        9) generate_report ;;
        10) explain_smc_nvram ;;
        11) self_update ;;
        [dD]) danger_zone_menu ;;
        [qQ]) log_action "=== Sentinel EXITED ==="; exit 0 ;;
        *) echo "${C_RED}Invalid choice.${C_NC}"; pause ;;
    esac
done
