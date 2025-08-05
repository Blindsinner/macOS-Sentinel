#!/bin/zsh

# ┌──────────────────────────────────────────────────┐
# │ macOS Sentinel v6.1 (Logo Refined)               │
# │ Author: md faysal mahmud                         │
# │ A hardened, production-ready toolkit for modern  │
# │ macOS administration.                            │
# └──────────────────────────────────────────────────┘

# ------------------------------------------------------------------------------
# CONFIGURATION & CONSTANTS
# ------------------------------------------------------------------------------
# Source a user-specific override file ($HOME/.sentinelrc) if present.
if [ -f "$HOME/.sentinelrc" ]; then
    source "$HOME/.sentinelrc"
fi

# Use parameter expansion to set defaults if not overridden above.
: "${SCRIPT_VERSION:="6.1"}"
: "${SCRIPT_URL:="https://raw.githubusercontent.com/user/repo/main/sentinel.sh"}" # Replace with your actual URL
: "${LOG_FILE:="$HOME/Library/Logs/macOS_Sentinel.log"}"


# ------------------------------------------------------------------------------
# STYLE & ANSI COLOR CODES
# ------------------------------------------------------------------------------
C_BLUE_BG='\033[44m'
C_WHITE_BOLD='\033[1;37m'
C_BLUE='\033[1;34m'
C_GREEN='\033[1;32m'
C_RED='\033[1;31m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[1;36m'
C_MAGENTA='\033[1;35m'
C_NC='\033[0m'


# ------------------------------------------------------------------------------
# ASCII BANNER FUNCTION
# ------------------------------------------------------------------------------
display_art() {
    echo "${C_CYAN}"
    echo "          \`'::.\`"
    echo "      \`::::::::::::::::.\`"
    echo "    \`::::::::::::::::::::.\`"
    echo "   ::::::::::::::::::::::::\`"
    echo "  ::::::::::${C_NC}'    '${C_CYAN}::::::::::\`"
    echo " ::::::::::   ${C_RED}()${C_CYAN}   ::::::::::"
    echo ".:::::::::'        \`:::::::::."
    echo "::::::::::          ::::::::::"
    echo "::::::::::          ::::::::::"
    echo "\`:::::::::.        .:::::::::'"
    echo "${C_BLUE} ::::::::::,,,,,,::::::::::"
    echo "  \`::::::::::::::'::::::::\`"
    echo "   .::::::::::::'::::::::."
    echo "     \`::::::::'::::::::\`"
    echo "        \`::::'::::\`"
    echo "           \`'::\`${C_NC}"
    echo "\n     ${C_BLUE_BG}${C_WHITE_BOLD} macOS Sentinel v${SCRIPT_VERSION} ${C_NC}\n"
}


# ------------------------------------------------------------------------------
# UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
pause() {
    echo "\n${C_YELLOW}Press Enter to continue...${C_NC}"
    read -r
}

log_action() {
    # Using standard redirection, which is universally available.
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}


# ------------------------------------------------------------------------------
# DEPENDENCY & ENVIRONMENT CHECKS
# ------------------------------------------------------------------------------
check_dependencies() {
    local missing_deps=()
    local dependencies=("curl" "profiles" "osascript" "diskutil" "networksetup" \
                        "pkill" "pgrep" "sudo" "mktemp" "awk" "head")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        clear
        display_art
        echo "${C_RED}FATAL ERROR: Missing required system commands:${C_NC}"
        printf " - %s\n" "${missing_deps[@]}"
        echo "This script cannot run without them. Please ensure your macOS installation is not corrupted."
        pause
        exit 1
    fi
}

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
    
    # Expanded list of common applications
    local -A apps
    apps=(
        [Browsers]="google-chrome firefox microsoft-edge"
        [Communication]="slack microsoft-teams zoom discord"
        [Developer]="visual-studio-code iterm2 docker sublime-text postman"
        [Productivity]="microsoft-office notion rectangle 1password"
    )

    echo "${C_CYAN}--- Software Installer ---${C_NC}"
    echo "Enter the numbers of the apps you want to install, separated by spaces."
    
    local -A app_map
    local i=1
    
    for category in "${(@k)apps}"; do
        echo "\n${C_YELLOW}${category}${C_NC}"
        for app in ${(s: :)apps[$category]}; do
            printf "  ${C_GREEN}%2d)${C_NC} %s\n" $i "$app"
            app_map[$i]=$app
            ((i++))
        done
    done

    echo
    read -r "choices?Apps to install: "
    
    local apps_to_install=()
    for choice in ${(s: :)choices}; do
        if [[ -n "${app_map[$choice]}" ]]; then
            apps_to_install+=("${app_map[$choice]}")
        fi
    done

    if [ ${#apps_to_install[@]} -eq 0 ]; then
        echo "${C_YELLOW}No valid selections made.${C_NC}"
        pause
        return
    fi
    
    echo "\n${C_CYAN}Installing:${C_NC} ${apps_to_install[*]}"
    for app in "${apps_to_install[@]}"; do
        brew install --cask "$app" \
          && log_action "Installed $app" \
          || log_action "ERROR: Failed to install $app"
    done

    echo "${C_GREEN}✅ Installation tasks complete. Check logs for details.${C_NC}"
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
        echo "${C_RED}--- ☢️  DANGER ZONE ☢️  ---${C_NC}"
        echo "These actions are destructive. Proceed with extreme caution."
        echo "------------------------------------------"
        echo "${C_YELLOW}1)${C_NC} Unenroll from Intune (Company Portal)"
        echo "${C_YELLOW}2)${C_NC} Force-Delete All Management Profiles"
        echo "${C_YELLOW}3)${C_NC} Factory Reset Mac (Erase All Data)"
        echo "------------------------------------------"
        echo "${C_GREEN}B)${C_NC} Back to Main Menu"
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
# First, check for required system commands. This runs only once.
check_dependencies

# Now that dependencies are verified, we can safely create the log file and write to it.
mkdir -p "$(dirname "$LOG_FILE")"
log_action "=== Sentinel v${SCRIPT_VERSION} STARTED ==="

while true; do
    # Ensure Homebrew environment is active on Apple Silicon for each loop iteration
    [ -x "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    clear; display_art

    # Main menu
    echo "Select an option:"
    echo "--- ${C_CYAN}QUICK FIXES & MAINTENANCE${C_NC} -------------------------------------"
    echo " ${C_GREEN}1)${C_NC} Fix Wi-Fi         ${C_GREEN}4)${C_NC} Clear Caches"
    echo " ${C_GREEN}2)${C_NC} Fix Bluetooth     ${C_GREEN}5)${C_NC} Repair Permissions"
    echo " ${C_GREEN}3)${C_NC} Run Maintenance"
    echo "\n--- ${C_MAGENTA}SOFTWARE & ENTERPRISE${C_NC} ---------------------------------------"
    echo " ${C_GREEN}6)${C_NC} Install Apps      ${C_GREEN}8)${C_NC} Open Company Portal"
    echo " ${C_GREEN}7)${C_NC} Update All Apps"
    echo "\n--- ${C_BLUE}DIAGNOSTICS & INFO${C_NC} ------------------------------------------"
    echo " ${C_GREEN}9)${C_NC} Generate Report   ${C_GREEN}11)${C_NC} Check for Updates"
    echo " ${C_GREEN}10)${C_NC} Explain SMC/NVRAM"
    echo "\n--- ${C_RED}DANGER ZONE${C_NC} -------------------------------------------------"
    echo " ${C_YELLOW}D)${C_NC} Unenroll, Erase Mac..."
    echo "-------------------------------------------------------------------"
    echo " ${C_RED}Q)${C_NC} Quit"
    echo "-------------------------------------------------------------------"

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
