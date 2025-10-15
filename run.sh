#!/bin/bash

# Dotfiles Setup Script
# This script sets up the complete development environment

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "macOS system detected"
        OS_TYPE="macos"
        
        # Check if Xcode Command Line Tools are installed
        if ! xcode-select -p &> /dev/null; then
            log_warning "Xcode Command Line Tools not found. Installing..."
            xcode-select --install
            log_info "Please wait for Xcode Command Line Tools installation to complete..."
            log_info "After installation completes, run this script again."
            exit 0
        else
            log_success "Xcode Command Line Tools are installed"
        fi
        
        # Check if Homebrew is installed
        if ! command_exists brew; then
            log_warning "Homebrew not found. Installing Homebrew..."
            yes "" | INTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            log_success "Homebrew is already installed"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_info "Linux system detected"
        OS_TYPE="linux"
        
        # Check Linux distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [[ "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
                log_success "Debian-based distribution detected: $PRETTY_NAME"
                
                log_info "Some installations may require superuser privileges."
                read -p "Do you have sudo privileges? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    IS_SUPERUSER=true
                else
                    IS_SUPERUSER=false
                fi
                
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
}

# Install system dependencies
install_system_dependencies() {
    log_info "Installing system dependencies..."
    
    if [[ "$OS_TYPE" == "linux" ]]; then
        ./scripts/install_ubuntu.sh
    elif [[ "$OS_TYPE" == "macos" ]]; then
        ./scripts/install_mac.sh
    fi
    
    log_success "System dependencies installation completed"
}

# Setup Oh My Zsh
setup_ohmyzsh() {
    if ! dir_exists "$HOME/.oh-my-zsh"; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    else
        log_info "Oh My Zsh already installed"
    fi
}

# Main setup function
main() {
    log_info "Starting dotfiles setup..."
    
    # Detect OS and setup prerequisites
    detect_os
    
    # Install system dependencies
    install_system_dependencies
    
    # Setup Oh My Zsh
    setup_ohmyzsh
    
    # Install Oh My Zsh plugins
    install_ohmyzsh_plugins
    
    # Copy dotfiles
    copy_dotfiles
    
    # Setup mise
    setup_mise
    
    # Setup custom virtualenv (optional)
    setup_custom_virtualenv
    
    # Set default shell
    set_default_shell
    
    log_success "Dotfiles setup completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

# Run main function
main "$@"
