# macOS Sentinel v5.0 (Final)

**Author:** MD FAYSAL MAHMUD\
**Version:** 5.0\
**License:** MIT

---

## Overview

macOS Sentinel v5.0 is a comprehensive, self‑updating, and production‑hardened Zsh toolkit designed for modern macOS administration on Apple Silicon (M1, M2, M3, M4+). It bundles common troubleshooting tasks, system maintenance, software management, enterprise integration (Intune), diagnostics, and irreversible "Danger Zone" operations into a single, interactive CLI menu.

Key features:

- **Interactive Menu:** Color‑coded sections for Quick Fixes, Maintenance, Software & Enterprise, Diagnostics & Info, and a separate Danger Zone.
- **Audit Logging:** All actions (successes and failures) are logged with timestamps in `~/Library/Logs/macOS_Sentinel.log` using atomic file locking.
- **Self‑Update:** Automatically fetches and applies updates from a configured GitHub raw URL.
- **Dependency Checks:** Validates required binaries on startup (e.g. `curl`, `networksetup`, `profiles`, `flock`).
- **Troubleshooting & Maintenance:** Wi‑Fi and Bluetooth resets, periodic scripts, DNS flush, Spotlight rebuild, cache clearing, and permissions repair.
- **Software Management:** Install or update apps via Homebrew Cask.
- **Enterprise Integration:** Launch Microsoft Intune Company Portal and generate compliance reports.
- **Diagnostics:** Generate a detailed system report, explain SMC/NVRAM reset procedures.
- **Danger Zone:** Unenroll from Intune, remove MDM profiles, and guide factory reset with strong confirmations.

---

## Prerequisites

- **macOS** on Apple Silicon (M1/M2/M3/M4+) or Intel (most functions supported).
- **Zsh** (default shell on modern macOS).
- **Git** (to clone the repository).
- **Homebrew** (optional, for software installation/update).
- **Microsoft Intune Company Portal** (optional, for enterprise commands).

Ensure the following commands are available in your `PATH`: `curl`, `profiles`, `osascript`, `diskutil`, `networksetup`, `pkill`, `pgrep`, `sudo`, `mktemp`, `awk`, `head`, `flock`.

---

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/youruser/macOS-Sentinel.git
   cd macOS-Sentinel
   ```

2. **Make the script executable**

   ```bash
   chmod +x sentinel.sh
   ```

3. **(Optional) Configure overrides**

   - Create `~/.sentinelrc` to override `SCRIPT_URL`, `SCRIPT_VERSION`, or `LOG_FILE`.
   - Example `.sentinelrc`:
     ```bash
     # Sentinel config
     SCRIPT_URL="https://raw.githubusercontent.com/youruser/macOS-Sentinel/main/sentinel.sh"
     LOG_FILE="$HOME/Library/Logs/MySentinel.log"
     ```

4. **Run Sentinel**

   ```bash
   ./sentinel.sh
   ```

---

## Usage

Upon launch, Sentinel presents a multi‑section menu. Navigate by typing the number (or letter) and pressing **Enter**:

```
macOS Sentinel v5.0

 QUICK FIXES & MAINTENANCE
 1) Fix Wi-Fi        4) Clear Caches
 2) Fix Bluetooth    5) Repair Permissions
 3) Run Maintenance

 SOFTWARE & ENTERPRISE
 6) Install Apps     8) Open Company Portal
 7) Update All Apps

 DIAGNOSTICS & INFO
 9) Generate Report  11) Check for Updates
 10) Explain SMC/NVRAM

 D) DANGER ZONE
 Q) Quit
```

### Menu Actions

#### Quick Fixes & Maintenance

- **1. Fix Wi‑Fi**: Toggles Wi‑Fi power off/on on the detected interface.
- **2. Fix Bluetooth**: Restarts the `bluetoothd` daemon.
- **3. Run Maintenance**: Executes `periodic daily weekly monthly`, flushes DNS, and reindexes Spotlight.
- **4. Clear Caches**: Closes visible apps, clears user and system caches, and recommends a reboot.
- **5. Repair Permissions**: Resets user‑home permissions via `diskutil resetUserPermissions`.

#### Software & Enterprise

- **6. Install Apps**: Install one or more Homebrew Cask apps by entering their slugs.
- **7. Update All Apps**: Runs `brew update && brew upgrade`.
- **8. Open Company Portal**: Launches Microsoft Intune Company Portal for enrollment or compliance.

#### Diagnostics & Info

- **9. Generate Report**: Creates a timestamped system report on the Desktop (hardware, software, disk usage, top processes, Intune status).
- **10. Explain SMC/NVRAM**: Displays Apple Silicon reset guidance.
- **11. Check for Updates**: Checks and applies script updates from the configured `SCRIPT_URL`.

#### Danger Zone

- **D. Danger Zone**: Opens a sub‑menu for destructive actions:
  - **1) Unenroll from Intune**: Guides you through Company Portal unenrollment.
  - **2) Delete MDM Profiles**: Removes all configuration profiles.
  - **3) Factory Reset Mac**: Opens System Settings for "Erase All Content and Settings" (confirmation required).

---

## Logging & Audit

All actions are logged to:

```
~/Library/Logs/macOS_Sentinel.log
```

Logs include timestamps, task names, and success/error statuses. File locking ensures no corruption if multiple instances run.

---

## Self‑Update

When selecting **"Check for Updates"**, Sentinel fetches the latest version from `SCRIPT_URL`:

- Download to a temp file.
- Byte‑compare with the running script.
- If different, prompt to overwrite and relaunch.

Configure the update source via `SCRIPT_URL` in `~/.sentinelrc` if needed.

---

## Best Practices

- **Run with sudo** only when prompted. Sentinel uses `sudo` for privileged operations.
- **Review logs** after mass operations (caches, profiles) for any errors.
- **Customize** by editing `~/.sentinelrc`—override URLs, log paths, or even add new menu functions.
- **Backup** your data and test destructive Danger Zone actions on a non‑production machine first.

---

## Contribution & Support

PRs, issues, and feature requests welcome on [GitHub](https://github.com/youruser/macOS-Sentinel). Please adhere to coding style and include tests where applicable.

---

© 2025 MD FAYSAL MAHMUD

