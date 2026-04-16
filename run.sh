#!/bin/bash

# Dotfiles Setup Script
# This script sets up the complete development environment
#
# Usage: ./run.sh [OPTIONS]
#   --dry-run          Show what would be done without making changes
#   --skip-deps        Skip system package installation
#   --skip-ohmyzsh     Skip Oh My Zsh and plugin installation
#   --skip-dotfiles    Skip dotfile deployment (symlinks)
#   --skip-mise        Skip mise setup
#   --skip-shell       Skip default shell change
#   --log-file <path>  Specify log file location
#   -h, --help         Show this help message

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# Skip flags
SKIP_DEPS=false
SKIP_OHMYZSH=false
SKIP_DOTFILES=false
SKIP_MISE=false
SKIP_SHELL=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                export DRY_RUN
                log_info "Dry-run mode enabled. No changes will be made."
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --skip-ohmyzsh)
                SKIP_OHMYZSH=true
                shift
                ;;
            --skip-dotfiles)
                SKIP_DOTFILES=true
                shift
                ;;
            --skip-mise)
                SKIP_MISE=true
                shift
                ;;
            --skip-shell)
                SKIP_SHELL=true
                shift
                ;;
            --log-file)
                if [[ -n "$2" ]]; then
                    LOG_FILE="$2"
                    export LOG_FILE
                    # Touch log file to ensure it's writable
                    touch "$LOG_FILE" 2>/dev/null || { echo "Cannot write to log file: $LOG_FILE"; exit 1; }
                    shift 2
                else
                    echo "Error: --log-file requires a path argument"
                    exit 1
                fi
                ;;
            -h|--help)
                echo "Usage: ./run.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dry-run          Show what would be done without making changes"
                echo "  --skip-deps        Skip system package installation"
                echo "  --skip-ohmyzsh     Skip Oh My Zsh and plugin installation"
                echo "  --skip-dotfiles    Skip dotfile deployment (symlinks)"
                echo "  --skip-mise        Skip mise setup"
                echo "  --skip-shell       Skip default shell change"
                echo "  --log-file <path>  Specify log file location"
                echo "  -h, --help         Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "macOS system detected"
        OS_TYPE="macos"

        # Check if Xcode Command Line Tools are installed
        if ! xcode-select -p &> /dev/null; then
            log_warning "Xcode Command Line Tools not found. Installing..."
            run_cmd xcode-select --install
            log_info "Please wait for Xcode Command Line Tools installation to complete..."
            log_info "After installation completes, run this script again."
            exit 0
        else
            log_success "Xcode Command Line Tools are installed"
        fi

        # Check if Homebrew is installed
        if ! command_exists brew; then
            log_warning "Homebrew not found. Installing Homebrew..."
            run_cmd /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            log_success "Homebrew is already installed"
        fi

    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_info "Linux system detected"
        OS_TYPE="linux"

        # Check Linux distribution
        if [ -f /etc/os-release ]; then
            # shellcheck disable=SC1091
            . /etc/os-release
            if [[ "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
                log_success "Debian-based distribution detected: $PRETTY_NAME"

                log_info "Some installations may require superuser privileges."
                read -rp "Do you have sudo privileges? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    IS_SUPERUSER=true
                else
                    IS_SUPERUSER=false
                fi
                # Export for use by sub-scripts
                export IS_SUPERUSER

            else
                log_error "Only Debian-based distributions are supported"
                exit 1
            fi
        else
            log_error "Unsupported Linux distribution"
            exit 1
        fi

    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    # Export for use by sub-scripts
    export OS_TYPE
}

# Install system dependencies
install_system_dependencies() {
    log_info "Installing system dependencies..."

    if [[ "$OS_TYPE" == "linux" ]]; then
        run_cmd "$SCRIPT_DIR/scripts/install_ubuntu.sh"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        run_cmd "$SCRIPT_DIR/scripts/install_mac.sh"
    fi

    log_success "System dependencies installation completed"
}

# Setup Oh My Zsh
setup_ohmyzsh() {
    if ! dir_exists "$HOME/.oh-my-zsh"; then
        log_info "Installing Oh My Zsh..."
        run_cmd sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    else
        log_info "Oh My Zsh already installed"
    fi
}

# Main setup function
main() {
    parse_args "$@"

    log_info "Starting dotfiles setup..."
    log_info "Log file: $LOG_FILE"

    # Detect OS and setup prerequisites
    detect_os

    # Install system dependencies
    if [[ "$SKIP_DEPS" == true ]]; then
        log_info "Skipping system dependencies (--skip-deps)"
    else
        install_system_dependencies
    fi

    # Setup Oh My Zsh
    if [[ "$SKIP_OHMYZSH" == true ]]; then
        log_info "Skipping Oh My Zsh setup (--skip-ohmyzsh)"
    else
        setup_ohmyzsh
        install_ohmyzsh_plugins
    fi

    # Copy dotfiles
    if [[ "$SKIP_DOTFILES" == true ]]; then
        log_info "Skipping dotfiles deployment (--skip-dotfiles)"
    else
        copy_dotfiles
    fi

    # Setup mise
    if [[ "$SKIP_MISE" == true ]]; then
        log_info "Skipping mise setup (--skip-mise)"
    else
        setup_mise
    fi

    # Set default shell
    if [[ "$SKIP_SHELL" == true ]]; then
        log_info "Skipping default shell change (--skip-shell)"
    else
        set_default_shell
    fi

    log_success "Dotfiles setup completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
    log_info "Log file saved to: $LOG_FILE"
}

# Run main function
main "$@"
