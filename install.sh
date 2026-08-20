#!/bin/bash
# =============================================================================
# PRO Linux — install.sh
# Main entry point for the PRO Linux installer
# Installs base Arch Linux system with GRUB bootloader
# Supports both UEFI and BIOS systems
# Partition scheme: Boot (512M) + Swap (4G) + Root (remaining)
# Filesystem: ext4
# =============================================================================

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# =============================================================================
# Welcome Screen
# =============================================================================

welcome() {
    clear
    echo -e "${MAUVE}${BOLD}"
    echo "  ██████╗ ██████╗  ██████╗     ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗"
    echo "  ██╔══██╗██╔══██╗██╔═══██╗    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝"
    echo "  ██████╔╝██████╔╝██║   ██║    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ "
    echo "  ██╔═══╝ ██╔══██╗██║   ██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ "
    echo "  ██║     ██║  ██║╚██████╔╝    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗"
    echo "  ╚═╝     ╚═╝  ╚═╝ ╚═════╝     ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
    echo -e "${RESET}"
    echo -e "${WHITE}${BOLD}  A clean, minimal, and opinionated Arch Linux distribution${RESET}"
    echo -e "${MAUVE}  Themed with Catppuccin Mocha + Mauve · Powered by AwesomeWM${RESET}"
    echo ""
    echo -e "${WHITE}  Version: 1.0.0${RESET}"
    echo -e "${WHITE}  https://github.com/yourusername/pro-linux${RESET}"
    echo ""
    echo -e "${YELLOW}${BOLD}  WARNING: This installer will format your disk.${RESET}"
    echo -e "${YELLOW}  Make sure you have backed up all important data.${RESET}"
    echo ""
    echo -e "${WHITE}  Press ENTER to continue or Ctrl+C to exit...${RESET}"
    read -r
}

# =============================================================================
# Collect user input
# =============================================================================

collect_input() {
    print_header "System Configuration"

    # Hostname
    HOSTNAME=$(ask "Enter hostname" "pro-linux")

    # Username
    USERNAME=$(ask "Enter username" "user")

    # Password
    while true; do
        PASSWORD=$(ask_password "Enter password for $USERNAME")
        PASSWORD_CONFIRM=$(ask_password "Confirm password")
        if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
            print_success "Passwords match."
            break
        else
            print_warning "Passwords do not match. Please try again."
        fi
    done

    # Root password
    while true; do
        ROOT_PASSWORD=$(ask_password "Enter root password")
        ROOT_PASSWORD_CONFIRM=$(ask_password "Confirm root password")
        if [ "$ROOT_PASSWORD" = "$ROOT_PASSWORD_CONFIRM" ]; then
            print_success "Root passwords match."
            break
        else
            print_warning "Passwords do not match. Please try again."
        fi
    done

    # Timezone
    TIMEZONE=$(ask "Enter timezone" "Asia/Kolkata")

    # Locale
    LOCALE=$(ask "Enter locale" "en_US.UTF-8")

    # Disk selection
    list_disks
    DISK=$(ask "Enter disk to install to (e.g. sda, nvme0n1)" "sda")
    DISK="/dev/$DISK"

    # Verify disk exists
    if [ ! -b "$DISK" ]; then
        print_error "Disk $DISK not found."
    fi

    # Detect boot mode
    BOOT_MODE=$(detect_boot_mode)
    print_info "Boot mode detected: ${BOLD}$BOOT_MODE${RESET}"

    # Summary
    echo ""
    print_header "Installation Summary"
    echo -e "  ${WHITE}Hostname:${RESET}   $HOSTNAME"
    echo -e "  ${WHITE}Username:${RESET}   $USERNAME"
    echo -e "  ${WHITE}Timezone:${RESET}   $TIMEZONE"
    echo -e "  ${WHITE}Locale:${RESET}     $LOCALE"
    echo -e "  ${WHITE}Disk:${RESET}       $DISK"
    echo -e "  ${WHITE}Boot mode:${RESET}  $BOOT_MODE"
    echo -e "  ${WHITE}Partitions:${RESET}"
    if [ "$BOOT_MODE" = "UEFI" ]; then
        echo -e "    ${MAUVE}${DISK}1${RESET} → EFI  (512M)"
    else
        echo -e "    ${MAUVE}${DISK}1${RESET} → Boot (512M)"
    fi
    echo -e "    ${MAUVE}${DISK}2${RESET} → Swap (4G)"
    echo -e "    ${MAUVE}${DISK}3${RESET} → Root (remaining)"
    echo ""

    if ! confirm "Proceed with installation? This will erase all data on $DISK"; then
        print_warning "Installation cancelled."
        exit 0
    fi
}

# =============================================================================
# Partition the disk
# =============================================================================

partition_disk() {
    print_header "Partitioning Disk"

    print_step "Wiping existing partition table on $DISK..."
    wipefs -af "$DISK" &>/dev/null
    sgdisk -Z "$DISK" &>/dev/null
    print_success "Disk wiped."

    if [ "$BOOT_MODE" = "UEFI" ]; then
        print_step "Creating UEFI partition scheme..."
        sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$DISK" &>/dev/null
        sgdisk -n 2:0:+4G -t 2:8200 -c 2:"SWAP" "$DISK" &>/dev/null
        sgdisk -n 3:0:0 -t 3:8300 -c 3:"ROOT" "$DISK" &>/dev/null
        print_success "UEFI partition scheme created."
    else
        print_step "Creating BIOS partition scheme..."
        parted -s "$DISK" mklabel msdos &>/dev/null
        parted -s "$DISK" mkpart primary ext4 1MiB 513MiB &>/dev/null
        parted -s "$DISK" set 1 boot on &>/dev/null
        parted -s "$DISK" mkpart primary linux-swap 513MiB 4.5GiB &>/dev/null
        parted -s "$DISK" mkpart primary ext4 4.5GiB 100% &>/dev/null
        print_success "BIOS partition scheme created."
    fi

    # Set partition variables
    if [[ "$DISK" == *"nvme"* ]]; then
        PART1="${DISK}p1"
        PART2="${DISK}p2"
        PART3="${DISK}p3"
    else
        PART1="${DISK}1"
        PART2="${DISK}2"
        PART3="${DISK}3"
    fi

    print_success "Partitions created: $PART1 $PART2 $PART3"
}

# =============================================================================
# Format partitions
# =============================================================================

format_partitions() {
    print_header "Formatting Partitions"

    if [ "$BOOT_MODE" = "UEFI" ]; then
        print_step "Formatting EFI partition ($PART1) as FAT32..."
        mkfs.fat -F32 "$PART1" &>/dev/null
        print_success "EFI partition formatted."
    else
        print_step "Formatting boot partition ($PART1) as ext4..."
        mkfs.ext4 -F "$PART1" &>/dev/null
        print_success "Boot partition formatted."
    fi

    print_step "Formatting swap partition ($PART2)..."
    mkswap "$PART2" &>/dev/null
    print_success "Swap partition formatted."

    print_step "Formatting root partition ($PART3) as ext4..."
    mkfs.ext4 -F "$PART3" &>/dev/null
    print_success "Root partition formatted."
}

# =============================================================================
# Mount partitions
# =============================================================================

mount_partitions() {
    print_header "Mounting Partitions"

    print_step "Mounting root partition..."
    mount "$PART3" /mnt
    print_success "Root mounted at /mnt"

    print_step "Enabling swap..."
    swapon "$PART2"
    print_success "Swap enabled."

    if [ "$BOOT_MODE" = "UEFI" ]; then
        print_step "Mounting EFI partition..."
        mkdir -p /mnt/boot/efi
        mount "$PART1" /mnt/boot/efi
        print_success "EFI partition mounted at /mnt/boot/efi"
    else
        print_step "Mounting boot partition..."
        mkdir -p /mnt/boot
        mount "$PART1" /mnt/boot
        print_success "Boot partition mounted at /mnt/boot"
    fi
}

# =============================================================================
# Install base system
# =============================================================================

install_base() {
    print_header "Installing Base System"

    print_step "Updating pacman mirrors..."
    reflector --country India --latest 10 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
    print_success "Mirrors updated."

    print_step "Installing base system (this may take a while)..."
    pacstrap /mnt \
        base \
        base-devel \
        linux \
        linux-firmware \
        linux-headers \
        nano \
        vim \
        git \
        curl \
        wget \
        networkmanager \
        grub \
        efibootmgr \
        os-prober \
        reflector \
        sudo \
        zsh \
        &>/dev/null
    print_success "Base system installed."
}

# =============================================================================
# Generate fstab
# =============================================================================

generate_fstab() {
    print_header "Generating fstab"
    print_step "Generating fstab..."
    genfstab -U /mnt >>/mnt/etc/fstab
    print_success "fstab generated."
}

# =============================================================================
# Configure system (chroot)
# =============================================================================

configure_system() {
    print_header "Configuring System"

    print_step "Setting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    arch-chroot /mnt hwclock --systohc
    print_success "Timezone set to $TIMEZONE"

    print_step "Setting locale..."
    echo "$LOCALE UTF-8" >>/mnt/etc/locale.gen
    arch-chroot /mnt locale-gen &>/dev/null
    echo "LANG=$LOCALE" >/mnt/etc/locale.conf
    print_success "Locale set to $LOCALE"

    print_step "Setting hostname..."
    echo "$HOSTNAME" >/mnt/etc/hostname
    cat >/mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF
    print_success "Hostname set to $HOSTNAME"

    print_step "Setting root password..."
    echo "root:$ROOT_PASSWORD" | arch-chroot /mnt chpasswd
    print_success "Root password set."

    print_step "Creating user $USERNAME..."
    arch-chroot /mnt useradd -m -G wheel,audio,video,storage,optical,network -s /bin/zsh "$USERNAME"
    echo "$USERNAME:$PASSWORD" | arch-chroot /mnt chpasswd
    print_success "User $USERNAME created."

    print_step "Configuring sudo..."
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
    print_success "Sudo configured for wheel group."

    print_step "Enabling NetworkManager..."
    arch-chroot /mnt systemctl enable NetworkManager &>/dev/null
    print_success "NetworkManager enabled."
}

# =============================================================================
# Install GRUB bootloader
# =============================================================================

install_grub() {
    print_header "Installing GRUB Bootloader"

    if [ "$BOOT_MODE" = "UEFI" ]; then
        print_step "Installing GRUB for UEFI..."
        arch-chroot /mnt grub-install \
            --target=x86_64-efi \
            --efi-directory=/boot/efi \
            --bootloader-id=PRO-Linux \
            &>/dev/null
        print_success "GRUB installed for UEFI."
    else
        print_step "Installing GRUB for BIOS..."
        arch-chroot /mnt grub-install \
            --target=i386-pc \
            "$DISK" \
            &>/dev/null
        print_success "GRUB installed for BIOS."
    fi

    print_step "Generating GRUB config..."
    # Enable os-prober for dual boot detection
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' \
        /mnt/etc/default/grub
    # Set PRO Linux as the GRUB name
    sed -i 's/GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="PRO Linux"/' \
        /mnt/etc/default/grub
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
    print_success "GRUB config generated."
}

# =============================================================================
# Copy installer scripts to new system
# =============================================================================

copy_scripts() {
    print_header "Copying Installer Scripts"

    print_step "Copying scripts to new system..."
    mkdir -p /mnt/home/$USERNAME/pro-linux
    cp -r "$SCRIPT_DIR"/* /mnt/home/$USERNAME/pro-linux/
    arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/pro-linux
    arch-chroot /mnt chmod +x /home/$USERNAME/pro-linux/*.sh
    print_success "Scripts copied to /home/$USERNAME/pro-linux/"
}

# =============================================================================
# Run awesome.sh inside chroot
# =============================================================================

run_awesome_installer() {
    print_header "Running AwesomeWM Installer"

    print_step "Running awesome.sh..."
    arch-chroot /mnt bash /home/$USERNAME/pro-linux/awesome.sh "$USERNAME"
    print_success "AwesomeWM setup complete."
}

# =============================================================================
# Finish installation
# =============================================================================

finish() {
    print_header "Installation Complete!"

    echo -e "${GREEN}${BOLD}"
    echo "  PRO Linux has been successfully installed!"
    echo -e "${RESET}"
    echo -e "  ${WHITE}You can now reboot into your new system.${RESET}"
    echo -e "  ${WHITE}Login with username: ${MAUVE}${BOLD}$USERNAME${RESET}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}Remember to remove the installation media before rebooting.${RESET}"
    echo ""

    if confirm "Reboot now?"; then
        print_step "Unmounting partitions..."
        umount -R /mnt
        swapoff "$PART2"
        print_success "Partitions unmounted."
        print_step "Rebooting..."
        reboot
    else
        print_info "You can reboot manually when ready."
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    check_root
    check_internet
    welcome
    collect_input
    partition_disk
    format_partitions
    mount_partitions
    install_base
    generate_fstab
    configure_system
    install_grub
    copy_scripts
    run_awesome_installer
    finish
}

main
