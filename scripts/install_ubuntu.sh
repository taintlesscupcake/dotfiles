#!/bin/bash

# Ubuntu/Debian System Package Installation Script
# This script only installs system packages via apt

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

log_info "Installing Ubuntu/Debian system dependencies..."

if [[ "$IS_SUPERUSER" == true ]]; then
    # Update package list
    log_info "Updating package list..."
    sudo apt update
    
    # Install essential packages
    log_info "Installing essential packages..."
    sudo apt install -y \
        git \
        zsh \
        neovim \
        curl \
        wget \
        build-essential \
        fzf \
        bat \
        eza \
        just \
        zoxide \
        mcfly \
        yazi \
        tree \
        htop \
        unzip \
        software-properties-common \
        ripgrep \
        fd-find \
        jq
    
    log_success "System packages installed successfully"
    
else
    log_warning "No sudo privileges. Installing user-space tools only..."
    log_warning "Some tools may not be installed correctly."
    
    # Install tools that don't require sudo
    if ! command_exists fzf; then
        log_info "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc
    fi
    
    if ! command_exists bat; then
        log_info "Installing bat..."
        wget -O bat.deb https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
        dpkg -i bat.deb || true
        rm bat.deb
    fi
    
    if ! command_exists eza; then
        log_info "Installing eza..."
        wget -O eza.deb https://github.com/eza-community/eza/releases/download/v0.18.1/eza_0.18.1_amd64.deb
        dpkg -i eza.deb || true
        rm eza.deb
    fi
    
    log_success "User-space tools installed"
fi

log_success "Ubuntu/Debian system packages installation completed!"
