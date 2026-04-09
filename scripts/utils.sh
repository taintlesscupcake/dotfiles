#!/bin/bash

# Common utility functions for dotfiles setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Check if file exists
file_exists() {
    [ -f "$1" ]
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if file_exists "$file"; then
        local backup="${file}_backup_$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
        return 0
    fi
    return 1
}

# Install Oh My Zsh plugin
install_ohmyzsh_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    
    if ! dir_exists "$plugin_dir"; then
        log_info "Installing Oh My Zsh plugin: $plugin_name"
        git clone "$plugin_url" "$plugin_dir"
        if [ $? -eq 0 ]; then
            log_success "Installed $plugin_name plugin"
        else
            log_error "Failed to install $plugin_name plugin"
            return 1
        fi
    else
        log_info "$plugin_name plugin already installed"
    fi
}

# Install Oh My Zsh plugins
install_ohmyzsh_plugins() {
    log_info "Installing Oh My Zsh plugins..."
    
    # Create custom plugins directory
    mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    
    # Install each plugin
    install_ohmyzsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    install_ohmyzsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_ohmyzsh_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab.git"
    install_ohmyzsh_plugin "you-should-use" "https://github.com/MichaelAquilina/zsh-you-should-use.git"
    install_ohmyzsh_plugin "zsh-hangul" "https://github.com/gomjellie/zsh-hangul.git"

    
    log_success "All Oh My Zsh plugins installed"
}

# Setup mise
setup_mise() {
    if ! command_exists mise; then
        log_info "Installing mise..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command_exists brew; then
                brew install mise
            else
                log_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
        else
            curl https://mise.run | sh
        fi
    else
        log_info "mise already installed"
    fi
    
    # Activate mise
    if [[ "$OSTYPE" == "darwin"* ]]; then
        eval "$(mise activate zsh)"
    else
        eval "$("$HOME/.local/bin/mise" activate zsh)"
    fi
    
    # Install Python and direnv
    log_info "Installing Python and direnv with mise..."
    mise use --global python@3
    mise use --global direnv
    
    
    log_success "mise setup completed"
}


# Copy dotfiles
copy_dotfiles() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    # Copy .zshrc
    if file_exists "$HOME/.zshrc"; then
        log_info "Existing .zshrc found."
        read -p "Backup existing .zshrc and replace? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            backup_file "$HOME/.zshrc"
            cp "$script_dir/.zshrc" "$HOME/.zshrc"
            log_success "Updated .zshrc"
        else
            log_info "Skipping .zshrc update"
        fi
    else
        cp "$script_dir/.zshrc" "$HOME/.zshrc"
        log_success "Installed .zshrc"
    fi
    
    # Copy .aliases
    cp "$script_dir/.aliases" "$HOME/.aliases"
    log_success "Installed .aliases"
    
    # Copy .direnvrc
    cp "$script_dir/.direnvrc" "$HOME/.direnvrc"
    log_success "Installed .direnvrc"
    
    # Copy theme
    cp "$script_dir/minimal.zsh-theme" "$HOME/.oh-my-zsh/themes/minimal.zsh-theme"
    log_success "Installed minimal theme"
}

# Set default shell to zsh
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting zsh as default shell..."
        chsh -s $(which zsh)
        log_success "Default shell set to zsh"
    else
        log_info "zsh is already the default shell"
    fi
}
