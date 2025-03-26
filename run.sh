#!/bin/bash

# Check operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS system detected"
    OS_TYPE="macos"

    # Check if Xcode Command Line Tools are installed
    if ! xcode-select -p &> /dev/null; then
        echo "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        echo "Please wait for Xcode Command Line Tools installation to complete..."
        echo "After installation completes, run this script again."
        exit 0
    else
        echo "Xcode Command Line Tools are installed"
    fi

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not found. Installing Homebrew..."
        yes "" | INTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed"
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux system detected"
    OS_TYPE="linux"

    # Check Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
            echo "Debian-based distribution detected: $PRETTY_NAME"

            echo "Some installations may require superuser privileges."
            read -p "Do you have sudo privileges? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                IS_SUPERUSER=true
            else
                IS_SUPERUSER=false
            fi

        else
            echo "Error: Only Debian-based distributions are supported"
            exit 1
        fi
    else
        echo "Error: Unsupported Linux distribution"
        exit 1
    fi

else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Install Dependencies
if [[ "$OS_TYPE" == "linux" ]]; then
    ./installs/install_ubuntu.sh
elif [[ "$OS_TYPE" == "macos" ]]; then
    ./installs/install_mac.sh
fi

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Backup and copy .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "Existing .zshrc found."
    read -p "Backup existing .zshrc and replace? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc_backup"
        cp ".zshrc" "$HOME/.zshrc"
    else
        echo "Skipping .zshrc update"
    fi
else
    cp ".zshrc" "$HOME/.zshrc"
fi

# Install theme
cp "minimal.zsh-theme" "$HOME/.oh-my-zsh/themes/minimal.zsh-theme"

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# Set default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi

# Install autojump
if ! command -v autojump &> /dev/null && [ ! -d "$HOME/.autojump" ]; then
    if [[ "$OS_TYPE" == "macos" ]]; then
        brew install autojump
    else
        if [[ "$IS_SUPERUSER" == true ]]; then
            sudo apt install autojump
        else
            git clone git://github.com/wting/autojump.git
            cd autojump
            ./install.py
            cd ..
            rm -rf autojump
        fi
    fi
fi

# Install mise
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        brew install mise
    else
        curl https://mise.run | sh
    fi
fi

# Activate mise
eval "$("$HOME/.local/bin/mise" activate bash)"

# Install latest Python and direnv with mise
mise use --global python@3
mise use --global direnv

# Install virtualenv
pip install virtualenv

# Virtualenv Setup (optional)
read -p "Do you want to install custom virtualenv? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.virtualenvs" ]; then
        mv "$HOME/.virtualenvs" "$HOME/.virtualenvs_backup"
    fi

    git clone https://github.com/taintlesscupcake/virtualenv "$HOME/.virtualenvs"

    if ! grep -q "export ENV_HOME=" "$HOME/.zshrc"; then
        echo "\n# Virtualenv configuration" >> "$HOME/.zshrc"
        echo "export ENV_HOME=\"\$HOME/.virtualenvs\"" >> "$HOME/.zshrc"
        echo "source \$ENV_HOME/virtualenv.sh" >> "$HOME/.zshrc"
        echo "export VIRTUAL_ENV_DISABLE_PROMPT=1" >> "$HOME/.zshrc"
    fi
fi

# Copy .aliases
cp ".aliases" "$HOME/.aliases"

# Copy .direnvrc to home
cp ".direnvrc" "$HOME/.direnvrc"
