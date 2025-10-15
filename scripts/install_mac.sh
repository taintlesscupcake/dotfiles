#!/bin/bash

# macOS System Package Installation Script
# This script only installs system packages via Homebrew

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

log_info "Installing macOS system dependencies..."

# Check if Homebrew is installed
if ! command_exists brew; then
    log_error "Homebrew not found. Please install Homebrew first."
    log_info "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Install essential system packages
log_info "Installing system packages..."
brew install \
    git \
    zsh \
    neovim \
    fzf \
    bat \
    eza \
    just \
    zoxide \
    mcfly \
    yazi \
    tree \
    htop \
    unzip

# Install additional useful tools
log_info "Installing additional tools..."
brew install \
    ripgrep \
    fd \
    jq \
    curl \
    wget

log_success "macOS system packages installation completed!"
