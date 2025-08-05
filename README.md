# macOS Sentinel v6.1

**Author:** MD FAYSAL MAHMUD

**Version:** 6.1 (Logo Refined)

**License:** MIT

## Overview

**macOS Sentinel** is a comprehensive, production-hardened Zsh toolkit designed for modern macOS administration. It consolidates troubleshooting tasks, system maintenance, software management, and enterprise integration into a unified, interactive command-line interface. Built for IT administrators and power users, Sentinel streamlines common workflows on both Apple Silicon and Intel-based Macs.

## Key Features

* **Interactive Menu:** A color-coded, easy-to-navigate menu guides you through every function.
* **Comprehensive Maintenance:** Run a full suite of maintenance tasks, including Wi-Fi/Bluetooth resets, DNS flushing, Spotlight re-indexing, cache clearing, and home folder permission repair.
* **Software Management:** Install a curated list of common applications or update all existing packages using Homebrew.
* **Enterprise Ready:** Includes functions to open the Microsoft Intune Company Portal for device enrollment and compliance checks.
* **Self-Updating:** The script can check for new versions from its GitHub repository and perform an in-place update automatically.
* **Diagnostics & Reporting:** Generate a detailed system report on your Desktop for easy troubleshooting and record-keeping.
* **Safe by Design:** Destructive actions are isolated in a separate **"Danger Zone"** menu, requiring explicit confirmation to prevent accidents.
* **Audit Logging:** Every action is timestamped and logged to `~/Library/Logs/macOS_Sentinel.log` for a complete audit trail.

## Prerequisites

Sentinel is designed to be self-contained but relies on standard macOS command-line tools.

* **macOS:** Apple Silicon or Intel.
* **Zsh:** The default shell in modern macOS.
* **Homebrew (Optional):** Required for installing and updating software. The script will prompt you to install it if it's missing.
    > **Note:** Before installing Homebrew on a company-managed Mac, check with your IT department to ensure it complies with corporate software policies.

## Installation

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/your-username/macOS-Sentinel.git](https://github.com/your-username/macOS-Sentinel.git)
    cd macOS-Sentinel
    ```
    *(Replace `your-username` with the actual repository path)*

2.  **Make the Script Executable**
    ```bash
    chmod +x macOS-Sentinel.sh
    ```

3.  **(Optional) Create a Configuration File**
    To override default settings like the update URL, create a file at `~/.sentinelrc`:
    ```bash
    # ~/.sentinelrc example
    SCRIPT_URL="[https://raw.githubusercontent.com/your-fork/macOS-Sentinel/main/macOS-Sentinel.sh](https://raw.githubusercontent.com/your-fork/macOS-Sentinel/main/macOS-Sentinel.sh)"
    LOG_FILE="$HOME/Library/Logs/MyCustomSentinel.log"
    ```

4.  **Run Sentinel**
    ```bash
    ./macOS-Sentinel.sh
    ```

## Usage

Launch the script to display the main menu. Enter the number or letter corresponding to your desired action and press **Enter**.

```
Select an option:
--- QUICK FIXES & MAINTENANCE -------------------------------------
 1) Fix Wi-Fi         4) Clear Caches
 2) Fix Bluetooth     5) Repair Permissions
 3) Run Maintenance

--- SOFTWARE & ENTERPRISE ---------------------------------------
 6) Install Apps      8) Open Company Portal
 7) Update All Apps

--- DIAGNOSTICS & INFO ------------------------------------------
 9) Generate Report   11) Check for Updates
 10) Explain SMC/NVRAM

--- DANGER ZONE -------------------------------------------------
 D) Unenroll, Erase Mac...
-------------------------------------------------------------------
 Q) Quit
-------------------------------------------------------------------
```

### The Danger Zone

This special section contains irreversible actions and requires extra confirmation.

* **Unenroll from Intune:** Guides you to remove the device from Company Portal.
* **Force-Delete All Management Profiles:** Attempts to sever all MDM control over the device.
* **Factory Reset Mac:** Opens the system utility to erase all content and settings, effectively wiping the Mac.

## Best Practices

* **Review Before Running:** Always understand what an option does before selecting it.
* **Test Safely:** Test "Danger Zone" actions on a non-production or virtual machine first.
* **Check Logs:** After running a task, review the log file for detailed success or error messages.
* **Use `sudo` Responsibly:** The script will prompt for your password when `sudo` is required.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request on the project's GitHub repository.

© 2025 MD FAYSAL MAHMUD
