#!/bin/bash

# Common utility functions for dotfiles setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging
LOG_FILE="${LOG_FILE:-/tmp/dotfiles_setup_$(date +%Y%m%d_%H%M%S).log}"

# Dry-run mode
DRY_RUN="${DRY_RUN:-false}"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_dry() {
    echo -e "${CYAN}[DRY-RUN]${NC} $1" | tee -a "$LOG_FILE"
}

# Execute a command (respects dry-run mode)
run_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Would run: $*"
    else
        "$@"
    fi
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
        local backup
        backup="${file}_backup_$(date +%Y%m%d_%H%M%S)"
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "Would back up $file to $backup"
        else
            cp "$file" "$backup"
            log_info "Backed up $file to $backup"
        fi
        return 0
    fi
    return 1
}

# Create symlink (with backup of existing target)
# Usage: create_symlink <source> <target>
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_error "Source file does not exist: $source"
        return 1
    fi

    # If target is already the correct symlink, skip
    if [[ -L "$target" ]]; then
        local current_target
        current_target="$(readlink "$target")"
        if [[ "$current_target" == "$source" ]]; then
            log_info "$target already points to $source"
            return 0
        fi
    fi

    # Backup existing file or broken symlink
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        backup_file "$target"
        run_cmd rm -f "$target"
    fi

    run_cmd ln -sf "$source" "$target"
    if [[ "$DRY_RUN" != true ]]; then
        log_success "Linked $target -> $source"
    fi
}

# Install Oh My Zsh plugin
install_ohmyzsh_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"

    if ! dir_exists "$plugin_dir"; then
        log_info "Installing Oh My Zsh plugin: $plugin_name"
        if run_cmd git clone "$plugin_url" "$plugin_dir"; then
            log_success "Installed $plugin_name plugin"
        else
            log_error "Failed to install $plugin_name plugin"
            return 1
        fi
    else
        log_info "$plugin_name plugin already installed"
    fi
}

# Oh My Zsh plugins configuration
OHMYZSH_PLUGINS=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "fzf-tab|https://github.com/Aloxaf/fzf-tab.git"
    "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use.git"
    "zsh-hangul|https://github.com/gomjellie/zsh-hangul.git"
)

# Install Oh My Zsh plugins
install_ohmyzsh_plugins() {
    log_info "Installing Oh My Zsh plugins..."

    # Create custom plugins directory
    run_cmd mkdir -p "$HOME/.oh-my-zsh/custom/plugins"

    # Install each plugin
    for plugin_entry in "${OHMYZSH_PLUGINS[@]}"; do
        local name="${plugin_entry%%|*}"
        local url="${plugin_entry##*|}"
        install_ohmyzsh_plugin "$name" "$url"
    done

    log_success "All Oh My Zsh plugins installed"
}

# Setup mise
setup_mise() {
    if ! command_exists mise; then
        log_info "Installing mise..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command_exists brew; then
                run_cmd brew install mise
            else
                log_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
        else
            run_cmd sh -c "$(curl -fsSL https://mise.run)"
        fi
    else
        log_info "mise already installed"
    fi

    # Ensure mise activate line exists in .zshrc
    local zshrc="$HOME/.zshrc"
    # shellcheck disable=SC2016  # Intentional single quotes: we want literal text in .zshrc
    local mise_activate_line='eval "$(mise activate zsh)"'

    if file_exists "$zshrc"; then
        if ! grep -qF 'mise activate zsh' "$zshrc"; then
            if [[ "$DRY_RUN" == true ]]; then
                log_dry "Would add mise activate line to $zshrc"
            else
                # Insert after the oh-my-zsh source line
                sed -i.bak "/source.*oh-my-zsh\.sh/a\\
${mise_activate_line}" "$zshrc" && rm -f "${zshrc}.bak"
                log_success "Added mise activate to $zshrc"
            fi
        else
            log_info "mise activate already in $zshrc"
        fi
    fi

    # Run mise commands to install runtimes (only if mise is available)
    if command_exists mise; then
        log_info "Installing Python and direnv with mise..."
        run_cmd mise use --global python@3
        run_cmd mise use --global direnv
    fi

    log_success "mise setup completed"
}

# Copy dotfiles using symlinks
copy_dotfiles() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # Symlink .zshrc (with interactive prompt for existing files)
    if file_exists "$HOME/.zshrc" && [[ ! -L "$HOME/.zshrc" ]]; then
        log_info "Existing .zshrc found."
        read -rp "Backup existing .zshrc and replace with symlink? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_symlink "$script_dir/.zshrc" "$HOME/.zshrc"
        else
            log_info "Skipping .zshrc update"
        fi
    else
        create_symlink "$script_dir/.zshrc" "$HOME/.zshrc"
    fi

    # Symlink .aliases
    create_symlink "$script_dir/.aliases" "$HOME/.aliases"

    # Symlink .direnvrc
    create_symlink "$script_dir/.direnvrc" "$HOME/.direnvrc"

    # Symlink theme
    create_symlink "$script_dir/minimal.zsh-theme" "$HOME/.oh-my-zsh/themes/minimal.zsh-theme"
}

# Set default shell to zsh
set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [ "$SHELL" != "$zsh_path" ]; then
        log_info "Setting zsh as default shell..."
        log_info "You may be prompted for your password."
        run_cmd chsh -s "$zsh_path"
        log_success "Default shell set to zsh"
    else
        log_info "zsh is already the default shell"
    fi
}
