#!/bin/bash
# =============================================================================
# PRO Linux — utils.sh
# Shared utility functions used across all installer scripts
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAUVE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# =============================================================================
# Print functions
# =============================================================================

# Print a section header
print_header() {
    echo ""
    echo -e "${MAUVE}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAUVE}${BOLD}║  $1${RESET}"
    echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# Print a success message
print_success() {
    echo -e "${GREEN}${BOLD}[✔]${RESET} $1"
}

# Print an info message
print_info() {
    echo -e "${CYAN}${BOLD}[→]${RESET} $1"
}

# Print a warning message
print_warning() {
    echo -e "${YELLOW}${BOLD}[!]${RESET} $1"
}

# Print an error message and exit
print_error() {
    echo -e "${RED}${BOLD}[✘]${RESET} $1"
    exit 1
}

# Print a step message
print_step() {
    echo -e "${BLUE}${BOLD}[*]${RESET} $1"
}

# =============================================================================
# Utility functions
# =============================================================================

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root."
    fi
}

# Check internet connection
check_internet() {
    print_step "Checking internet connection..."
    if ping -c 1 archlinux.org &>/dev/null; then
        print_success "Internet connection detected."
    else
        print_error "No internet connection. Please connect and try again."
    fi
}

# Confirm action with user
confirm() {
    local message=$1
    echo -e "${YELLOW}${BOLD}[?]${RESET} $message [y/N] "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Ask user for input with a default value
ask() {
    local prompt=$1
    local default=$2
    echo -e "${CYAN}${BOLD}[→]${RESET} $prompt [${default}]: "
    read -r response
    echo "${response:-$default}"
}

# Ask user for password (hidden input)
ask_password() {
    local prompt=$1
    echo -e "${CYAN}${BOLD}[→]${RESET} $prompt: "
    read -rs password
    echo ""
    echo "$password"
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Run a command and print success or error
run() {
    local description=$1
    shift
    print_step "$description"
    if "$@" &>/dev/null; then
        print_success "$description — done."
    else
        print_error "$description — failed."
    fi
}

# Detect if system is UEFI or BIOS
detect_boot_mode() {
    if [ -d /sys/firmware/efi ]; then
        echo "UEFI"
    else
        echo "BIOS"
    fi
}

# List available disks
list_disks() {
    echo ""
    print_info "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
    echo ""
}
