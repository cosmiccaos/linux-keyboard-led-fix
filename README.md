# ⌨️ Linux Auto Scroll Lock / LED Keeper (LED Keeper Daemon)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[🇹🇷 Türkçe Dokümantasyon için Tıklayın](README_TR.md)

A lightweight `systemd` daemon solution to keep keyboard backlights (specifically for **Piranha 2345** and other budget LED keyboards) permanently turned on in **Linux**, even when toggling `NumLock` or reconnecting the device.


## 🔍 Understanding the Issue (Problem Overview)

On budget gaming keyboards like the **Piranha 2345**, the RGB/LED illumination circuit is hardwired to the **Scroll Lock (`SCLK`)** key line instead of a dedicated controller. Under Linux, this leads to two major issues:

1. **Disabled Scroll Lock by Default:**  
   Unlike Windows, the Linux kernel and display servers (X11 / Wayland) do not trigger the `Scroll Lock` LED signal out-of-the-box. As a result, the keyboard stays unlit when plugged in.

2. **NumLock Hardware Firmware Reset:**  
   The low-cost microcontroller inside the keyboard resets the USB LED data bus (`sysfs` interface) whenever the `NumLock` key is toggled. This means any manual command (like `xset` or `setleds`) gets instantly overridden, turning off the lights as soon as `NumLock` is pressed.

## 💡 The Solution

This repository provides a lightweight **Systemd LED Keeper Daemon** that operates beneath the desktop environment by monitoring the Linux kernel's LED interface (`/sys/class/leds/input*::scrolllock/brightness`) directly.

The service checks the Scroll Lock LED state in real-time (every 200ms). When `NumLock` turns off the illumination, the daemon automatically forces the LED brightness back to `1` (ON) in milliseconds—completely seamlessly to the user:
- No need to enter `sudo` passwords.
- Desktop environment and window manager independent.
- Prevents `NumLock` from ever disabling the backlight again.

***How to set-up:***
## 1. Single-command installation:

```
curl -sSL https://raw.githubusercontent.com/cosmiccaos/linux-keyboard-led-fix/main/install.sh | sudo bash
```

Or alternatively, to set everything up individually;
## 2. Step-by-Step Installation

The installation process is identical across **Arch Linux / SteamOS / Manjaro** and **Ubuntu / Debian / Pop!_OS / Linux Mint**.

### 1. Create the Daemon Script
Open your terminal and create the script:

```
sudo nano /usr/local/bin/led-keeper.sh
```

Paste the following script into the file:

```
#!/bin/bash
while true; do
    for led in /sys/class/leds/input*::scrolllock/brightness; do
        if [ -f "$led" ]; then
            val=$(cat "$led")
            if [ "$val" -eq 0 ]; then
                echo 1 > "$led"
            fi
        fi
    done
    sleep 0.2
done
```

Save: Ctrl + O -> Enter and Exit: Ctrl + X

## 2. Make it Executable

```
sudo chmod +x /usr/local/bin/led-keeper.sh
```

## 3. Create the Systemd Service

```
sudo nano /etc/systemd/system/led-keeper.service
```

Paste this configuration inside:

```
Ini, TOML
[Unit]
Description=Keyboard LED Keeper Service
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/led-keeper.sh
Restart=always

[Install]
WantedBy=multi-user.target
```
Save: Ctrl + O -> Enter and Exit: Ctrl + X

## 4. Enable and Start the Service

```
sudo systemctl daemon-reload
```

```
sudo systemctl enable --now led-keeper.service
```
All is done, keyboard leds must be active. Enjoy.

Management Commands

a. Check Service Status:
```
systemctl status led-keeper.service
```

b. Stop Service Temporarily:
```
sudo systemctl stop led-keeper.service
```

c. Disable Service Permanently:

```
sudo systemctl disable --now led-keeper.service
```


📜 License
Distributed under the MIT License. See LICENSE for more information.
