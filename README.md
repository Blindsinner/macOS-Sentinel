# macOS Sentinel v5.1 (Patched)

**Author:** MD FAYSAL MAHMUD\
**Version:** 5.1 (Patched)\
**License:** MIT

---

## Overview

macOS Sentinel v5.0 is a comprehensive, self-updating, production-hardened Zsh toolkit for modern macOS administration on Apple Silicon (M1, M2, M3, M4+) and Intel. It consolidates troubleshooting tasks, system maintenance, software management, enterprise integration (Intune), diagnostics, and irreversible "Danger Zone" operations into a unified, interactive CLI menu.

### Key Features

- **Interactive Menu:** Color-coded sections for Quick Fixes, Maintenance, Software & Enterprise, Diagnostics & Info, and a dedicated Danger Zone.
- **Audit Logging:** Timestamped logs of every action (successes and errors) at `~/Library/Logs/macOS_Sentinel.log` using standard redirection (no flock dependency).
- **Self-Update:** In-place script updates from a configurable GitHub raw URL.
- **Dependency Checks:** Verifies essential binaries (`curl`, `networksetup`, `profiles`, `flock`, etc.) at startup.
- **Troubleshooting & Maintenance:** Wi-Fi/Bluetooth resets, periodic scripts, DNS flush, Spotlight rebuild, cache clearing, permissions repair.
- **Software Management:** Install and update applications via Homebrew Cask.
- **Enterprise Integration:** Launch Microsoft Intune Company Portal and generate compliance reports.
- **Diagnostics:** Generate detailed system reports and display Apple Silicon SMC/NVRAM reset guidance.
- **Danger Zone:** Unenroll from Intune, remove MDM profiles, and guide factory reset with strong confirmations.

---

## Prerequisites

Before running Sentinel, ensure your environment can execute built-in macOS and installed utilities.

- **macOS** (Apple Silicon or Intel) with Zsh as the default shell.
- **Git** (to clone the repository).
- **Homebrew** (optional, for installing and updating software—before installing it on a company-managed Mac, check with your IT or security team to ensure it's allowed under corporate software policies. Some organizations restrict package managers or software that modifies system paths due to security or compliance concerns. If permitted, Homebrew can streamline installation of many common tools and utilities.)
- **Microsoft Intune Company Portal** (optional, for enterprise tasks).

Sentinel uses standard macOS commands and utilities. These must be accessible via your `PATH` environment variable, which is a list of directories the shell searches when you type a command.

Typical macOS default `PATH` includes directories like `/usr/bin`, `/usr/sbin`, `/bin`, and `/sbin`.  Sentinel relies on the following commands, which live in those system directories:

```bash
curl       # /usr/bin/curl
profiles   # /usr/bin/profiles
osascript  # /usr/bin/osascript
diskutil   # /usr/sbin/diskutil
networksetup  # /usr/sbin/networksetup
pkill      # /usr/bin/pkill
pgrep      # /usr/bin/pgrep
sudo       # /usr/bin/sudo
mktemp     # /usr/bin/mktemp
awk        # /usr/bin/awk
head       # /usr/bin/head
```

> If you see “command not found” errors, it means the directory containing that command is not in your `PATH`, or the utility is missing. You can view your current `PATH` with:
>
> ```bash
> echo $PATH
> ```
>
> and add missing directories in your shell profile (e.g., `~/.zshrc`).

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

- **1. Fix Wi-Fi:** Toggle Wi-Fi off/on.
- **2. Fix Bluetooth:** Restart Bluetooth daemon.
- **3. Run Maintenance:** Execute daily/weekly/monthly scripts, flush DNS, reindex Spotlight.
- **4. Clear Caches:** Close apps, clear user/system caches, prompt for reboot.
- **5. Repair Permissions:** Reset home-folder permissions via `diskutil resetUserPermissions`.

**Software & Enterprise**

- **6. Install Apps:** Install Homebrew Cask apps by slug (e.g., `google-chrome slack`).
- **7. Update All Apps:** Run `brew update && brew upgrade`.
- **8. Open Company Portal:** Launch Intune for enrollment/compliance.

**Diagnostics & Info**

- **9. Generate Report:** Create a timestamped system report on the Desktop.
- **10. Explain SMC/NVRAM:** Display Apple Silicon reset guidance.
- **11. Check for Updates:** Self-update the script from GitHub.

**Danger Zone**

- **D. Danger Zone:** Opens sub-menu for destructive operations:
  - **1) Unenroll from Intune**
  - **2) Delete MDM Profiles**
  - **3) Factory Reset Mac**

---

## Logging & Audit

All actions are logged with timestamps, action names, and outcomes in:

```
$HOME/Library/Logs/macOS_Sentinel.log
```

File locking prevents log corruption when running multiple instances.

---

## Self-Update Mechanism

Selecting **"Check for Updates"** fetches the latest script from `SCRIPT_URL`, compares it, and prompts to overwrite and relaunch if there’s a newer version. Override `SCRIPT_URL` in `~/.sentinelrc` as needed.

---

## Best Practices

- Use **sudo** only when prompted.
- Review logs after major operations.
- Customize behavior via `~/.sentinelrc`.
- Test Danger Zone actions on non-production devices first.

---

## Contributing

Contributions welcome! Please open issues or PRs on [GitHub](https://github.com/Blindsinner/macOS-Sentinel).

---

© 2025 MD FAYSAL MAHMUD

