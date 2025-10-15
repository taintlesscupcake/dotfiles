# Personal Dotfiles

My personal dotfiles and setup scripts for development environment configuration. This repository contains my preferred settings and tools that I use daily for development.

## What's Included

- Custom Zsh configuration with Oh My Zsh
- Minimal terminal theme with Git status and virtual environment support
- Essential development tools setup
- Python development environment with [custom virtualenv](https://github.com/taintlesscupcake/virtualenv)
- Modern CLI tools: eza, bat, fzf, zoxide, mcfly, yazi, just
- Cross-platform support (macOS & Debian-based Linux)

## Quick Start

```bash
git clone https://github.com/taintlesscupcake/dotfiles
cd dotfiles
./run.sh
```

## Setup Details

### Shell Environment
- **Zsh** with Oh My Zsh framework
- Custom minimal theme for clean interface with Git status and virtual environment display
- Plugins:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - fzf-tab for fuzzy completion
  - you-should-use for command suggestions
  - zsh-hangul for Korean input support
  - urltools for URL manipulation
  - bgnotify for background notifications

### Development Tools
- **mise**: Version manager for runtime environments
- **Homebrew** (macOS)
- **Modern CLI Tools**:
  - eza: Modern ls replacement with Git integration
  - bat: Enhanced cat with syntax highlighting
  - fzf: Fuzzy finder for command line
  - zoxide: Smart cd command
  - mcfly: Intelligent command history search
  - yazi: Terminal file manager
  - just: Command runner
- **Python Environment**:
  - [Custom virtualenv setup](https://github.com/taintlesscupcake/virtualenv) (optional)
  - direnv integration
- **Editor**: Neovim as default editor

## Platform Support

### macOS
- Automatically installs:
  - Xcode Command Line Tools
  - Homebrew
  - Required development tools

### Linux (Debian-based)
- Supports Ubuntu, Linux Mint, and other Debian derivatives
- Requires sudo privileges for system-wide installations
- Provides alternative installation methods when sudo isn't available

## Installation Notes

- Existing configurations will be backed up automatically
- All installations are idempotent (safe to run multiple times)
- Interactive prompts for important decisions
- Modular setup allows skipping certain components

## Customization

Feel free to fork this repository and modify the configurations to match your preferences. The main configuration files are:

- `.zshrc`: Shell configuration
- `.aliases`: Command aliases and shortcuts
- `.direnvrc`: direnv configuration
- `minimal.zsh-theme`: Terminal theme
- `run.sh`: Main installation script
- `scripts/install_mac.sh`: macOS-specific system package installations
- `scripts/install_ubuntu.sh`: Ubuntu/Debian-specific system package installations
- `scripts/utils.sh`: Common utility functions

## Backup

The script automatically creates backups of:
- Existing `.zshrc` → `.zshrc_backup`
- Existing virtualenv configurations

## License

[Add your license information here]

---

**Note**: These are my personal configurations that work well for my development workflow. Feel free to use them as a starting point for your own dotfiles.
