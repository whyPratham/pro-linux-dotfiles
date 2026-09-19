#!/bin/bash
# =============================================================================
# PRO Linux — awesome.sh
# Installs and configures the complete AwesomeWM setup
# Usage: sudo bash awesome.sh <username>
# =============================================================================

# =============================================================================
# Print functions embedded directly (fixes "command not found" errors
# that occur when utils.sh is missing or fails to source)
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAUVE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

print_header() {
    echo ""
    echo -e "${MAUVE}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAUVE}${BOLD}║  $1${RESET}"
    echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
    echo ""
}
print_success() { echo -e "${GREEN}${BOLD}[✔]${RESET} $1"; }
print_info() { echo -e "${CYAN}${BOLD}[→]${RESET} $1"; }
print_warning() { echo -e "${YELLOW}${BOLD}[!]${RESET} $1"; }
print_error() {
    echo -e "${RED}${BOLD}[✘]${RESET} $1"
    exit 1
}
print_step() { echo -e "${BLUE}${BOLD}[*]${RESET} $1"; }
command_exists() { command -v "$1" &>/dev/null; }

# =============================================================================
# Root check
# =============================================================================

if [ "$EUID" -ne 0 ]; then
    print_error "Run as root: sudo bash awesome.sh <username>"
fi

# =============================================================================
# Validate username argument
# =============================================================================

if [ -z "$1" ]; then
    print_error "Usage: sudo bash awesome.sh <username>"
fi

USERNAME="$1"
HOME_DIR="/home/$USERNAME"

if ! id "$USERNAME" &>/dev/null; then
    print_error "User '$USERNAME' does not exist."
fi

# =============================================================================
# Internet check
# =============================================================================

print_step "Checking internet connection..."
if ping -c 1 archlinux.org &>/dev/null; then
    print_success "Internet connection detected."
else
    print_error "No internet connection. Please connect and try again."
fi

print_header "PRO Linux — AwesomeWM Installer"
print_info "Setting up AwesomeWM for user: ${BOLD}$USERNAME${RESET}"
print_info "Home directory: ${BOLD}$HOME_DIR${RESET}"
echo ""

# =============================================================================
# Helper: Run command as the target user
# =============================================================================

run_as_user() {
    sudo -u "$USERNAME" bash -c "$1"
}

# =============================================================================
# Helper: Install pacman package with error handling (one at a time)
# =============================================================================

install_pacman() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        print_step "Installing: $pkg"
        if pacman -S --noconfirm --needed "$pkg" &>/dev/null; then
            print_success "Installed: $pkg"
        else
            print_warning "Failed to install: $pkg — skipping."
        fi
    done
}

# =============================================================================
# Helper: Install AUR package with error handling (one at a time)
# =============================================================================

install_aur() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        print_step "Installing from AUR: $pkg"
        if run_as_user "yay -S \
            --noconfirm \
            --needed \
            --answerdiff None \
            --answerclean None \
            --answerupgrade None \
            --answeredit None \
            --removemake \
            --cleanafter \
            --pgpfetch \
            --sudoloop \
            --mflags '--noconfirm' \
            $pkg"; then
            print_success "Installed from AUR: $pkg"
        else
            print_warning "Failed to install from AUR: $pkg — skipping."
        fi
    done
}

# =============================================================================
# Helper: Copy config file safely
# =============================================================================

copy_config() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir" 2>/dev/null
    if [ -f "$src" ]; then
        if cp "$src" "$dest" 2>/dev/null; then
            print_success "Copied: $(basename "$dest")"
        else
            print_warning "Failed to copy: $src"
        fi
    else
        print_warning "Source not found: $src — skipping."
    fi
}

# =============================================================================
# Step 1 — Update system
# (reflector used AFTER it is installed in step 2)
# =============================================================================

update_system() {
    print_header "Step 1 — Updating System"
    print_step "Updating system packages..."
    if pacman -Syu --noconfirm &>/dev/null; then
        print_success "System updated."
    else
        print_warning "System update had warnings — continuing."
    fi
}

# =============================================================================
# Step 2 — Install build tools + update mirrors with reflector
# =============================================================================

install_build_tools() {
    print_header "Step 2 — Installing Build Tools"

    install_pacman \
        base-devel git curl wget rsync reflector python python-pip

    print_step "Updating mirrors with reflector..."
    if reflector --country India --latest 10 --sort rate \
        --save /etc/pacman.d/mirrorlist &>/dev/null; then
        print_success "Mirrors updated."
    else
        print_warning "Mirror update failed — using existing mirrors."
    fi
}

# =============================================================================
# Step 3 — Install yay
# =============================================================================

install_yay() {
    print_header "Step 3 — Installing yay (AUR Helper)"

    # Grant temporary passwordless sudo for AUR builds
    echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur-build
    chmod 440 /etc/sudoers.d/aur-build
    print_success "Temporary passwordless sudo configured."

    # Ensure sudoers file is always cleaned up even on crash
    trap 'rm -f /etc/sudoers.d/aur-build; print_warning "Cleaned up temporary sudo access."' EXIT

    # Pre-configure GPG to auto-fetch keys without prompting
    print_step "Configuring GPG for automatic key fetching..."
    run_as_user "mkdir -p $HOME_DIR/.gnupg && chmod 700 $HOME_DIR/.gnupg"
    run_as_user "echo 'keyserver hkps://keyserver.ubuntu.com' >> $HOME_DIR/.gnupg/gpg.conf"
    run_as_user "echo 'keyserver-options auto-key-retrieve' >> $HOME_DIR/.gnupg/gpg.conf"
    print_success "GPG configured."

    if command_exists yay; then
        print_success "yay already installed — skipping build."
        return
    fi

    local yay_dir="/tmp/yay-build"
    rm -rf "$yay_dir"

    print_step "Cloning yay from AUR..."
    if run_as_user "git clone https://aur.archlinux.org/yay.git $yay_dir"; then
        print_success "yay cloned."
    else
        print_error "Failed to clone yay. Check internet connection."
    fi

    print_step "Building and installing yay..."
    if run_as_user "cd $yay_dir && makepkg -si --noconfirm --needed"; then
        print_success "yay installed successfully."
    else
        print_error "Failed to build yay."
    fi

    rm -rf "$yay_dir"
}

# =============================================================================
# Step 4 — Core system packages
# (xorg-server instead of xorg group to avoid conflicts)
# =============================================================================

install_core_packages() {
    print_header "Step 4 — Installing Core System Packages"

    print_step "Installing Xorg..."
    install_pacman \
        xorg-server xorg-xinit xorg-xrandr xorg-xset \
        xorg-xprop xorg-xev xorg-xdpyinfo xdotool xclip xss-lock

    print_step "Installing SDDM..."
    install_pacman sddm

    print_step "Installing audio stack..."
    install_pacman \
        pipewire pipewire-pulse pipewire-alsa wireplumber pamixer pavucontrol sof-firmware
    install_pacman alsa-utils alsa-plugins

    print_step "Installing bluetooth..."
    install_pacman bluez bluez-utils blueman

    print_step "Installing graphics drivers..."
    install_pacman mesa libgl xf86-video-intel xf86-video-amdgpu xf86-video-nouveau

    print_step "Installing network tools..."
    install_pacman networkmanager network-manager-applet nm-connection-editor
}

# =============================================================================
# Step 5 — Desktop utilities
# (unrar moved to AUR step since it is not in official repos)
# =============================================================================

install_desktop_utilities() {
    print_header "Step 5 — Installing Desktop Utilities"

    install_pacman \
        xdg-utils xdg-user-dirs gvfs gvfs-mtp \
        udisks2 upower acpi tumbler ffmpegthumbnailer

    install_pacman zip unzip tar p7zip

    install_pacman \
        htop man-db man-pages bash-completion \
        dbus polkit lm_sensors fastfetch
}

# =============================================================================
# Step 6 — AwesomeWM stack
# =============================================================================

install_awesome_packages() {
    print_header "Step 6 — Installing AwesomeWM Stack"

    install_pacman \
        awesome picom rofi dunst libnotify \
        flameshot brightnessctl playerctl \
        copyq polkit-gnome \
        nemo nemo-fileroller xfce4-terminal \
        lxappearance papirus-icon-theme \
        feh zsh zsh-autosuggestions \
        zsh-syntax-highlighting starship
}

# =============================================================================
# Step 7 — AUR packages
# (unrar and lightdm-gtk-greeter-settings added here)
# =============================================================================

install_aur_packages() {
    print_header "Step 7 — Installing AUR Packages"

    install_aur i3lock-color
    install_aur betterlockscreen
    install_aur catppuccin-gtk-theme-mocha
    install_aur preload
    install_aur unrar
    install_aur lightdm-gtk-greeter-settings
    install_aur gtk-engine-murrine

    # Remove temporary passwordless sudo
    rm -f /etc/sudoers.d/aur-build
    # Remove the trap since we cleaned up manually
    trap - EXIT
    print_success "Temporary sudo access removed — normal permissions restored."
}

# =============================================================================
# Step 8 — Fonts
# =============================================================================

install_fonts() {
    print_header "Step 8 — Installing Fonts"

    install_pacman \
        ttf-jetbrains-mono-nerd noto-fonts \
        noto-fonts-emoji noto-fonts-cjk \
        ttf-dejavu ttf-liberation

    print_step "Updating font cache..."
    if fc-cache -fv &>/dev/null; then
        print_success "Font cache updated."
    else
        print_warning "Font cache update had warnings."
    fi
}

# =============================================================================
# Step 9 — awesome-wm-widgets
# =============================================================================

install_awesome_widgets() {
    print_header "Step 9 — Installing awesome-wm-widgets"

    local widgets_dir="$HOME_DIR/.config/awesome/awesome-wm-widgets"
    mkdir -p "$HOME_DIR/.config/awesome"

    if [ -d "$widgets_dir" ]; then
        print_warning "awesome-wm-widgets exists — re-cloning."
        rm -rf "$widgets_dir"
    fi

    if run_as_user "git clone https://github.com/streetturtle/awesome-wm-widgets $widgets_dir"; then
        chown -R "$USERNAME:$USERNAME" "$widgets_dir"
        print_success "awesome-wm-widgets cloned."
    else
        print_warning "Failed to clone awesome-wm-widgets."
    fi
}

# =============================================================================
# Step 10 — Oh My Zsh + plugins
# (RUNZSH=no CHSH=no KEEP_ZSHRC=yes prevents interactive prompts)
# =============================================================================

install_oh_my_zsh() {
    print_header "Step 10 — Installing Oh My Zsh"

    local omz_dir="$HOME_DIR/.oh-my-zsh"

    if [ ! -d "$omz_dir" ]; then
        print_step "Installing Oh My Zsh..."
        if run_as_user "RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""; then
            print_success "Oh My Zsh installed."
        else
            print_warning "Failed to install Oh My Zsh."
        fi
    else
        print_warning "Oh My Zsh already installed — skipping."
    fi

    local suggestions_dir="$omz_dir/custom/plugins/zsh-autosuggestions"
    if [ ! -d "$suggestions_dir" ]; then
        print_step "Installing zsh-autosuggestions..."
        if run_as_user "git clone https://github.com/zsh-users/zsh-autosuggestions $suggestions_dir"; then
            print_success "zsh-autosuggestions installed."
        else
            print_warning "Failed to install zsh-autosuggestions."
        fi
    else
        print_warning "zsh-autosuggestions already installed — skipping."
    fi

    local highlighting_dir="$omz_dir/custom/plugins/zsh-syntax-highlighting"
    if [ ! -d "$highlighting_dir" ]; then
        print_step "Installing zsh-syntax-highlighting..."
        if run_as_user "git clone https://github.com/zsh-users/zsh-syntax-highlighting $highlighting_dir"; then
            print_success "zsh-syntax-highlighting installed."
        else
            print_warning "Failed to install zsh-syntax-highlighting."
        fi
    else
        print_warning "zsh-syntax-highlighting already installed — skipping."
    fi
}

# =============================================================================
# Step 11 — Set zsh as default shell
# =============================================================================

set_default_shell() {
    print_header "Step 11 — Setting Zsh as Default Shell"

    local zsh_path
    zsh_path=$(which zsh 2>/dev/null)

    if [ -z "$zsh_path" ]; then
        print_warning "zsh not found — skipping."
        return
    fi

    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" >>/etc/shells
        print_success "Added $zsh_path to /etc/shells"
    fi

    if chsh -s "$zsh_path" "$USERNAME"; then
        print_success "Default shell set to $zsh_path"
    else
        print_warning "Failed to set zsh — run manually: chsh -s $zsh_path $USERNAME"
    fi
}

# =============================================================================
# Step 12 — Create user directories first then clone dotfiles
# =============================================================================

setup_xdg_dirs() {
    print_header "Step 12 — Setting Up User Directories"

    local dirs=(
        "$HOME_DIR/Desktop"
        "$HOME_DIR/Downloads"
        "$HOME_DIR/Documents"
        "$HOME_DIR/Pictures/wallpapers"
        "$HOME_DIR/Pictures/screenshots"
        "$HOME_DIR/Music"
        "$HOME_DIR/Videos"
        "$HOME_DIR/.config"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done

    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"
    print_success "User directories created."

    if command_exists xdg-user-dirs-update; then
        run_as_user "xdg-user-dirs-update" &>/dev/null
    fi
}

# =============================================================================
# Step 13 — Clone dotfiles and copy configs
# =============================================================================

clone_dotfiles() {
    print_header "Step 13 — Cloning Dotfiles"

    local DOTFILES_REPO="https://github.com/whyPratham/pro-linux-dotfiles"
    local DOTFILES_DIR="$HOME_DIR/.dotfiles"

    if [ -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles dir exists — re-cloning."
        rm -rf "$DOTFILES_DIR"
    fi

    print_step "Cloning dotfiles from $DOTFILES_REPO..."
    if run_as_user "git clone $DOTFILES_REPO $DOTFILES_DIR"; then
        print_success "Dotfiles cloned."
    else
        print_warning "Failed to clone dotfiles — skipping config copy."
        print_info "Push your configs to $DOTFILES_REPO and re-run this script."
        return
    fi

    # AwesomeWM
    copy_config "$DOTFILES_DIR/awesome/rc.lua" \
        "$HOME_DIR/.config/awesome/rc.lua"
    copy_config "$DOTFILES_DIR/awesome/powermenu.sh" \
        "$HOME_DIR/.config/awesome/powermenu.sh"
    copy_config "$DOTFILES_DIR/awesome/themes/default/theme.lua" \
        "$HOME_DIR/.config/awesome/themes/default/theme.lua"

    # Picom
    copy_config "$DOTFILES_DIR/picom/picom.conf" \
        "$HOME_DIR/.config/picom/picom.conf"

    # Dunst
    copy_config "$DOTFILES_DIR/dunst/dunstrc" \
        "$HOME_DIR/.config/dunst/dunstrc"

    # Rofi
    copy_config "$DOTFILES_DIR/rofi/config.rasi" \
        "$HOME_DIR/.config/rofi/config.rasi"
    copy_config "$DOTFILES_DIR/rofi/themes/catppuccin-mauve.rasi" \
        "$HOME_DIR/.config/rofi/themes/catppuccin-mauve.rasi"

    # xfce4-terminal
    copy_config "$DOTFILES_DIR/xfce4/terminal/terminalrc" \
        "$HOME_DIR/.config/xfce4/terminal/terminalrc"

    # Starship
    copy_config "$DOTFILES_DIR/starship/starship.toml" \
        "$HOME_DIR/.config/starship/starship.toml"

    # Zsh
    copy_config "$DOTFILES_DIR/zsh/.zshrc" \
        "$HOME_DIR/.zshrc"

    # Wallpaper (support both png and jpg)
    if [ -f "$DOTFILES_DIR/wallpapers/wallpaper.png" ]; then
        copy_config "$DOTFILES_DIR/wallpapers/wallpaper.png" \
            "$HOME_DIR/Pictures/wallpapers/wallpaper.png"
    elif [ -f "$DOTFILES_DIR/wallpapers/wallpaper.jpg" ]; then
        copy_config "$DOTFILES_DIR/wallpapers/wallpaper.jpg" \
            "$HOME_DIR/Pictures/wallpapers/wallpaper.jpg"
    else
        print_warning "No wallpaper found in dotfiles."
    fi

    chmod +x "$HOME_DIR/.config/awesome/powermenu.sh" 2>/dev/null
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR/.config" 2>/dev/null
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR/Pictures" 2>/dev/null
    chown "$USERNAME:$USERNAME" "$HOME_DIR/.zshrc" 2>/dev/null

    print_success "All config files copied."
}

# =============================================================================
# Step 14 — Apply GTK theme via settings files (no lxappearance needed)
# =============================================================================

apply_gtk_theme() {
    print_header "Step 14 — Applying GTK Theme"

    mkdir -p "$HOME_DIR/.config/gtk-3.0"

    cat >"$HOME_DIR/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=catppuccin-mocha-mauve-standard+default
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=16
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
EOF

    cat >"$HOME_DIR/.gtkrc-2.0" <<EOF
gtk-theme-name="catppuccin-mocha-mauve-standard+default"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="JetBrainsMono Nerd Font 10"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=16
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
EOF

    chown "$USERNAME:$USERNAME" "$HOME_DIR/.config/gtk-3.0/settings.ini"
    chown "$USERNAME:$USERNAME" "$HOME_DIR/.gtkrc-2.0"
    print_success "GTK theme applied."
}

# =============================================================================
# Step 15 — Configure logind
# (regex handles both commented and uncommented lines)
# =============================================================================

configure_logind() {
    print_header "Step 15 — Configuring logind"

    sed -i 's/^#*HandleLidSwitch=.*/HandleLidSwitch=lock/' \
        /etc/systemd/logind.conf
    sed -i 's/^#*HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=lock/' \
        /etc/systemd/logind.conf
    sed -i 's/^#*HandlePowerKey=.*/HandlePowerKey=ignore/' \
        /etc/systemd/logind.conf
    print_success "logind configured — lid closes lock, power button opens menu."

    if grep -q "vm.swappiness" /etc/sysctl.conf 2>/dev/null; then
        sed -i 's/vm.swappiness=.*/vm.swappiness=10/' /etc/sysctl.conf
    else
        echo "vm.swappiness=10" >>/etc/sysctl.conf
    fi
    print_success "Swappiness set to 10."
}

# =============================================================================
# Step 16 — Enable services
# =============================================================================

enable_services() {
    print_header "Step 16 — Enabling Services"

    local services=(
        "NetworkManager"
        "bluetooth"
        "sddm"
        "preload"
        "udisks2"
    )

    for service in "${services[@]}"; do
        print_step "Enabling $service..."
        if systemctl enable "$service" &>/dev/null; then
            print_success "$service enabled."
        else
            print_warning "Failed to enable $service — skipping."
        fi
    done
}

# =============================================================================
# Step 17 — Betterlockscreen
# (skipped if no X display — must be run after first login)
# =============================================================================

setup_betterlockscreen() {
    print_header "Step 17 — Setting Up Betterlockscreen"

    local wallpaper=""
    if [ -f "$HOME_DIR/Pictures/wallpapers/wallpaper.png" ]; then
        wallpaper="$HOME_DIR/Pictures/wallpapers/wallpaper.png"
    elif [ -f "$HOME_DIR/Pictures/wallpapers/wallpaper.jpg" ]; then
        wallpaper="$HOME_DIR/Pictures/wallpapers/wallpaper.jpg"
    else
        print_warning "No wallpaper found — run 'betterlockscreen -u ~/Pictures/wallpapers/wallpaper.png' after first login."
        return
    fi

    if [ -z "$DISPLAY" ]; then
        print_warning "No X display active — run 'betterlockscreen -u $wallpaper' after first login."
        return
    fi

    if run_as_user "betterlockscreen -u $wallpaper"; then
        print_success "Betterlockscreen wallpaper cached."
    else
        print_warning "Betterlockscreen cache failed — run manually after login."
    fi
}

# =============================================================================
# Step 18 — lm-sensors
# (yes | sensors-detect avoids interactive prompts)
# =============================================================================

setup_sensors() {
    print_header "Step 18 — Setting Up lm-sensors"

    print_step "Auto-detecting sensors..."
    if yes | sensors-detect &>/dev/null; then
        print_success "Sensors configured."
    else
        print_warning "Sensor detection had issues — CPU temp widget may need manual config."
    fi
}

# =============================================================================
# Finish
# =============================================================================

finish() {
    print_header "AwesomeWM Setup Complete!"
    echo -e "${GREEN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║      PRO Linux AwesomeWM Setup Complete!         ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "  ${WHITE}Log in as ${MAUVE}${BOLD}$USERNAME${RESET}${WHITE} and select AwesomeWM at the login screen.${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}After first login run:${RESET}"
    echo -e "  ${MAUVE}  betterlockscreen -u ~/Pictures/wallpapers/wallpaper.png${RESET}"
    echo ""
    echo -e "  ${YELLOW}If dotfiles failed to clone, push configs to GitHub and re-run:${RESET}"
    echo -e "  ${MAUVE}  sudo bash awesome.sh $USERNAME${RESET}"
    echo ""
}

# =============================================================================
# Main — order matters
# =============================================================================

main() {
    update_system
    install_build_tools
    install_yay
    install_core_packages
    install_desktop_utilities
    install_awesome_packages
    install_aur_packages
    install_fonts
    install_awesome_widgets
    install_oh_my_zsh
    set_default_shell
    setup_xdg_dirs
    clone_dotfiles
    apply_gtk_theme
    configure_logind
    enable_services
    setup_betterlockscreen
    setup_sensors
    finish
}

main
