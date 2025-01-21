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
            
            # Check for superuser privileges
            echo "Some installations may require superuser privileges."
            read -p "Do you have sudo privileges? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Will proceed with sudo for system-wide installations"
                IS_SUPERUSER=true
            else
                echo "Will skip package installations (assuming required packages are already installed)"
                IS_SUPERUSER=false
            fi

        else
            echo "Error: Only Debian-based distributions are supported"
            exit 1
        fi
    else
        echo "Error: How you could see this message?"
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
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed"
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "Oh My Zsh installation completed"
fi

# Backup and copy .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "Existing .zshrc found."
    read -p "Do you want to backup existing .zshrc and replace it with new one? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating backup of existing .zshrc..."
        cp "$HOME/.zshrc" "$HOME/.zshrc_backup"
        echo "Backup created at $HOME/.zshrc_backup"
        
        echo "Copying new .zshrc..."
        cp ".zshrc" "$HOME/.zshrc"
        echo ".zshrc has been updated"
    else
        echo "Skipping .zshrc update"
    fi
else
    echo "No existing .zshrc found. Copying new .zshrc..."
    cp ".zshrc" "$HOME/.zshrc"
    echo ".zshrc has been created"
fi

# Install theme
cp "minimal.zsh-theme" "$HOME/.oh-my-zsh/themes/minimal.zsh-theme"

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# Check if default shell is zsh
if [ "$SHELL" = "$(which zsh)" ]; then
    echo "Default shell is already zsh"
else
    echo "Default shell is not zsh"

    cp ".zshrc" "$HOME/.zshrc"
    
    # Change default shell to zsh
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
fi

# Install autojump
if command -v autojump &> /dev/null || [ -d "$HOME/.autojump" ]; then
    echo "autojump is already installed"
else
    echo "Installing autojump..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        brew install autojump
    else
        if [[ "$IS_SUPERUSER" == true ]]; then
            sudo apt install autojump
        else
            echo "Manual autojump installation is required"
            git clone git://github.com/wting/autojump.git
            cd autojump
            ./install.py
            cd ..
            rm -rf autojump
        fi
    fi
fi

# Install asdf
if [ -d "$HOME/.asdf" ]; then
    echo "asdf is already installed"
else
    echo "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
    echo "asdf installation completed"
fi

. "$HOME/.asdf/asdf.sh"

# Check is asdf installed correctly
if [ -d "$HOME/.asdf" ]; then
    echo "asdf is installed correctly"
else
    echo "asdf is not installed correctly. Please check the installation logs."
    exit 1
fi

# Virtualenv Setup (optional)
read -p "Do you want to install custom virtualenv? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing custom virtualenv..."
    
    # Clone virtualenv repository
    if [ -d "$HOME/.virtualenvs" ]; then
        echo "Existing virtualenv setup found. Backing up..."
        mv "$HOME/.virtualenvs" "$HOME/.virtualenvs_backup"
    fi
    
    echo "Cloning virtualenv repository..."
    git clone https://github.com/taintlesscupcake/virtualenv "$HOME/.virtualenvs"

    # Install python
    echo "Installing asdf plugins for virtualenvs..."
    asdf plugin add python
    asdf install python latest
    asdf global python latest

    asdf plugin add direnv
    asdf install direnv latest
    asdf global direnv latest

    asdf direnv setup --shell zsh --version latest

    pip3 install virtualenv
    
    # Add configuration to .zshrc if not already present
    if ! grep -q "export ENV_HOME=" "$HOME/.zshrc"; then
        echo "Adding virtualenv configuration to .zshrc..."
        echo "" >> "$HOME/.zshrc"
        echo "# Virtualenv configuration" >> "$HOME/.zshrc"
        echo "export ENV_HOME=\"\$HOME/.virtualenvs\"" >> "$HOME/.zshrc"
        echo "source \$ENV_HOME/virtualenv.sh" >> "$HOME/.zshrc"
        echo "export VIRTUAL_ENV_DISABLE_PROMPT=1" >> "$HOME/.zshrc"
    else
        echo "Virtualenv configuration already exists in .zshrc"
    fi
    
    echo "Custom virtualenv installation completed"
fi

# Copy .aliases to ~/.aliases
cp ".aliases" "$HOME/.aliases"

