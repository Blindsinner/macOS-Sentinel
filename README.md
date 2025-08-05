# macOS Sentinel v5.0 (Final)

**Author:** MD FAYSAL MAHMUD\
**Version:** 5.0\
**License:** MIT

---

## Overview

macOS Sentinel v5.0 is a comprehensive, self‑updating, production‑hardened Zsh toolkit for modern macOS administration on Apple Silicon (M1, M2, M3, M4+) and Intel. It consolidates troubleshooting tasks, system maintenance, software management, enterprise integration (Intune), diagnostics, and irreversible "Danger Zone" operations into a unified, interactive CLI menu.

### Key Features

- **Interactive Menu:** Color‑coded sections for Quick Fixes, Maintenance, Software & Enterprise, Diagnostics & Info, and a dedicated Danger Zone.
- **Audit Logging:** Timestamped logs of every action (successes and errors) at `~/Library/Logs/macOS_Sentinel.log` with atomic file locking.
- **Self‑Update:** In-place script updates from a configurable GitHub raw URL.
- **Dependency Checks:** Verifies essential binaries (`curl`, `networksetup`, `profiles`, `flock`, etc.) at startup.
- **Troubleshooting & Maintenance:** Wi‑Fi/Bluetooth resets, periodic scripts, DNS flush, Spotlight rebuild, cache clearing, permissions repair.
- **Software Management:** Install and update applications via Homebrew Cask.
- **Enterprise Integration:** Launch Microsoft Intune Company Portal and generate compliance reports.
- **Diagnostics:** Generate detailed system reports and display Apple Silicon SMC/NVRAM reset guidance.
- **Danger Zone:** Unenroll from Intune, remove MDM profiles, and guide factory reset with strong confirmations.

---

## Prerequisites

- **macOS** (Apple Silicon or Intel) with Zsh as the shell.
- **Git** (to clone the repo).
- **Homebrew** (optional, for software install/update).
- **Microsoft Intune Company Portal** (optional, for enterprise tasks).

Ensure the following commands exist in your `PATH`:

```
curl profiles osascript diskutil networksetup pkill pgrep sudo mktemp awk head flock
```

---

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Blindsinner/macOS-Sentinel.git
   cd macOS-Sentinel
   ```

2. **Make the script executable**

   ```bash
   chmod +x macOS-Sentinel.sh
   ```

3. **(Optional) Create a configuration file**

   - To override settings, create `~/.sentinelrc` and define variables:
     ```bash
     # ~/.sentinelrc example
     SCRIPT_URL="https://raw.githubusercontent.com/Blindsinner/macOS-Sentinel/main/macOS-Sentinel.sh"
     LOG_FILE="$HOME/Library/Logs/MySentinel.log"
     ```

4. **Run Sentinel**

   ```bash
   ./macOS-Sentinel.sh
   ```

---

## Usage

Upon launch, Sentinel presents a menu. Enter the number or letter and press **Enter**:

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

### Sections & Actions

**Quick Fixes & Maintenance**

- **1. Fix Wi‑Fi:** Toggle Wi‑Fi off/on.
- **2. Fix Bluetooth:** Restart Bluetooth daemon.
- **3. Run Maintenance:** Run daily/weekly/monthly scripts, flush DNS, reindex Spotlight.
- **4. Clear Caches:** Close apps, clear user/system caches, prompt for reboot.
- **5. Repair Permissions:** Reset home-folder permissions.

**Software & Enterprise**

- **6. Install Apps:** Install Homebrew Cask apps by slug (e.g. `google-chrome`).
- **7. Update All Apps:** `brew update && brew upgrade`.
- **8. Open Company Portal:** Launch Intune for enrollment/compliance.

**Diagnostics & Info**

- **9. Generate Report:** Create a timestamped system report on Desktop.
- **10. Explain SMC/NVRAM:** Show Apple Silicon reset guidance.
- **11. Check for Updates:** Self‑update the script from GitHub.

**Danger Zone**

- **D. Danger Zone:** Opens sub-menu for destructive operations:
  - **1) Unenroll from Intune**
  - **2) Delete MDM Profiles**
  - **3) Factory Reset Mac**

---

## Logging & Audit

Sentinel logs every action to:

```
~/Library/Logs/macOS_Sentinel.log
```

Logs include timestamps, actions, and outcomes. File locking via `flock` prevents corruption.

---

## Self‑Update Mechanism

- Fetches latest script from `SCRIPT_URL`.
- Compares against the running script.
- Prompts to overwrite and relaunch if an update is available.

Override `SCRIPT_URL` in `~/.sentinelrc` as needed.

---

## Best Practices

- Use **sudo** only when prompted.
- Review logs after major tasks.
- Customize via `~/.sentinelrc` for organization-specific defaults.
- Test Danger Zone actions on non-production devices first.

---

## Contributing

Contributions, issues, and feature requests are welcome!\
Please open them on [GitHub](https://github.com/Blindsinner/macOS-Sentinel).

---

© 2025 MD FAYSAL MAHMUD

