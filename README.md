<div align="center">

# 🐧 PRO Linux

**An Arch-based Linux distro built for CS/IT students and developers**  
*Get a fully pre-configured, ready-to-code environment — right from the first boot.*

![PRO Linux Banner](./assets/banner.png)
> 📸 *Replace with your actual banner/screenshot*

[![Made with Love](https://img.shields.io/badge/Made%20with-❤️-cba6f7?style=for-the-badge)](https://github.com/whyPratham/pro-linux)
[![Arch Based](https://img.shields.io/badge/Based%20on-Arch%20Linux-1793d1?style=for-the-badge&logo=arch-linux)](https://archlinux.org)
[![WM](https://img.shields.io/badge/WM-AwesomeWM-cba6f7?style=for-the-badge)](https://awesomewm.org)
[![Theme](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-1e1e2e?style=for-the-badge)](https://catppuccin.com)
[![Shell](https://img.shields.io/badge/Shell-Zsh-89b4fa?style=for-the-badge)](https://zsh.org)

</div>

---

## 🤔 What is PRO Linux?

**PRO Linux** is a lightweight, opinionated Arch-based Linux distribution made specifically for **CS/IT students and developers**. 

The idea is simple — when you install PRO Linux, you shouldn't have to spend days setting up your environment. No hunting for packages, no manually configuring window managers, no theming headaches. Just boot up, and you're already in a clean, fast, developer-ready workspace. ⚡

> The name **PRO** covers the initials of the founding team members who built this together.

---

## ✨ Features

### 🖥️ 1. Fully Customized AwesomeWM Desktop

A complete, hand-crafted tiling window manager setup themed with **Catppuccin Mocha + Mauve**. Everything is pre-configured and looks good right out of the box — no extra setup needed.

![AwesomeWM Desktop](./assets/desktop.png)
> 📸 *Replace with your actual desktop screenshot*

Here's everything that comes with the desktop setup:

| Component | Tool | Purpose |
|-----------|------|---------|
| 🪟 Window Manager | AwesomeWM | Tiling WM — keyboard driven, fast |
| 🎨 Compositor | Picom | Rounded corners, blur, animations |
| 🚀 App Launcher | Rofi | Launch apps, switch windows, power menu |
| 🔔 Notifications | Dunst | Styled notification popups |
| 🌐 Network | nm-applet | Wifi/ethernet management from tray |
| 🔊 Audio | Pipewire + pamixer | Volume control with media keys |
| 🔵 Bluetooth | Blueman | Bluetooth manager in tray |
| 📋 Clipboard | CopyQ | Clipboard history manager |
| 🔒 Lock Screen | Betterlockscreen | Blurred wallpaper lock screen |
| 📸 Screenshots | Flameshot | Region and fullscreen screenshots |
| 🔆 Brightness | Brightnessctl | Brightness keys support |
| 🎵 Media Keys | Playerctl | Play/pause/next across all apps |
| 📁 File Manager | Nemo | Clean file manager |
| 💻 Terminal | xfce4-terminal | Themed terminal emulator |
| 🐚 Shell | Zsh + Oh My Zsh | With autosuggestions and syntax highlighting |
| ✨ Prompt | Starship | Fast, beautiful shell prompt |
| 📝 Editor | Neovim + LazyVim | Pre-configured with Catppuccin theme |
| 🖌️ GTK Theme | Catppuccin Mocha Mauve | Consistent theming across all apps |
| 🗂️ Icons | Papirus Dark | Clean icon theme |
| 🔤 Font | JetBrainsMono Nerd Font | For icons and readability |
| 🖼️ Wallpaper | Catppuccin wallpaper | Matches the overall theme |

**Wibar (status bar) includes:**
- 🌡️ CPU temperature
- 🧠 RAM usage
- ⚙️ CPU usage
- 🔊 Volume
- 🔋 Battery percentage
- 🌐 System tray (network, bluetooth, clipboard)
- 🕐 Clock
- ⏻ Power menu

---

### 🛠️ 2. Utility Applications

A set of custom-built tools that make day-to-day CS/IT work faster and less annoying.

---

#### ▶️ Universal Runner

Run any program in one click — no need to remember compile commands for different languages.

![Universal Runner](./assets/universal-runner.png)
> 📸 *Replace with your actual Universal Runner screenshot*

Write your code, hit run — Universal Runner figures out the language, compiles if needed, and executes it. Supports C, C++, Python, Java, JavaScript, and more.

---

#### 🐙 GUI-Based Git Manager

A clean, terminal-integrated GUI for managing your git repositories — no need to memorize git commands for everyday tasks.

![Git GUI Manager](./assets/git-gui.png)
> 📸 *Replace with your actual Git GUI screenshot*

Manage all your repos from one centralized interface — stage, commit, push, pull, branch management — all without leaving the terminal feel.

---

### ⚙️ 3. One-Click Developer Setup *(in progress 🚧)*

A single command that sets up your full development environment — languages, package managers, editors, SDKs — based on what you're working with.

```bash
# coming soon
pro setup
```

---

### 🤖 4. Local AI Assistant *(in progress 🚧)*

An AI assistant built directly into the terminal — runs locally on your machine, no API keys, no internet required.

```bash
# coming soon
pro ai "explain this error"
```

---

## 🤖 Fully Automated — Zero Manual Work

Everything in PRO Linux is handled by **shell scripts**. From partitioning the disk to theming the desktop — no manual steps required.

Here's what happens behind the scenes:

```
Boot the ISO
    ↓
install.sh runs
    ↓
├── Detects UEFI or BIOS automatically
├── Partitions and formats your disk
├── Installs base Arch Linux
├── Sets up users, locale, timezone, hostname
└── Installs GRUB bootloader
    ↓
First boot
    ↓
awesome.sh runs automatically
    ↓
├── Installs all packages (pacman + AUR)
├── Clones and applies all dotfiles
├── Sets up Zsh + Oh My Zsh + Starship
├── Applies Catppuccin GTK theme
├── Configures all system settings
└── Enables all services
    ↓
Login screen appears
    ↓
You're in 🎉
```

No manual intervention. Just answer a few questions during installation (hostname, username, password, disk) and PRO Linux takes care of the rest.

---

## 📦 What Gets Installed

<details>
<summary>Click to expand full package list</summary>

### Core System
`xorg-server` `lightdm` `pipewire` `pipewire-pulse` `wireplumber` `networkmanager` `bluez` `bluez-utils` `polkit-gnome`

### AwesomeWM Stack
`awesome` `picom` `rofi` `dunst` `feh` `betterlockscreen` `i3lock-color` `xss-lock` `flameshot` `brightnessctl` `playerctl` `copyq` `blueman` `nm-applet`

### Terminal & Shell
`xfce4-terminal` `zsh` `oh-my-zsh` `zsh-autosuggestions` `zsh-syntax-highlighting` `starship` `neovim`

### Theming
`catppuccin-gtk-theme-mocha` `papirus-icon-theme` `ttf-jetbrains-mono-nerd` `noto-fonts` `noto-fonts-emoji`

### File Management
`nemo` `nemo-fileroller` `gvfs` `gvfs-mtp` `udisks2` `tumbler`

### Developer Tools
`git` `base-devel` `curl` `wget` `python` `lm-sensors` `htop`

</details>

---

## 🚀 Installation

> ⚠️ PRO Linux will **completely erase** the selected disk. Back up your data first.

```bash
# Boot from the PRO Linux ISO
# Then run:
bash install.sh
```

The installer will ask you for:
- 👤 Username and password
- 🖥️ Hostname
- 🕐 Timezone
- 💾 Which disk to install on

Everything else is automatic.

---

## 👥 The Team

PRO Linux is built by **Surgeons of Tech** — a team of CS/IT students who wanted a better out-of-the-box Linux experience.

| Member | GitHub |
|--------|--------|
| Pratham | [@whyPratham](https://github.com/whyPratham) |
| Raghav | *add link* |
| Omkar | *add link* |

---

## 🗺️ Roadmap

- [x] AwesomeWM desktop setup
- [x] Automated installer scripts
- [x] Dotfiles system
- [ ] Universal Runner
- [ ] GUI Git Manager
- [ ] One-click developer setup
- [ ] Local AI Assistant
- [ ] Custom ISO build pipeline

---

## 📄 License

MIT License — feel free to use, modify and share.

---

<div align="center">

Built with 🤍 by the Surgeons of Tech  
*For students, by students*

</div>
