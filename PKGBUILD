# Maintainer: Your Name <your.email@example.com>
# Contributor: Your Name <your.email@example.com>

pkgname=axicli
pkgver=3.9.6
pkgrel=1
pkgdesc="AxiDraw Command Line Interface (CLI) for controlling AxiDraw pen plotters"
arch=('any')
url="https://axidraw.com/doc/cli_api"
license=('custom')
depends=('python>=3.8')
makedepends=('python-pip' 'python-setuptools' 'python-wheel')
optdepends=('python-serial: For USB communication with AxiDraw devices'
            'python-numpy: For enhanced mathematical operations'
            'python-pillow: For image processing capabilities')
source=("https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip")
sha256sums=('SKIP')  # The source URL doesn't provide checksums, using SKIP

# Function to detect if this is an upgrade
_is_upgrade() {
    # Check if axicli is already installed
    if command -v axicli &> /dev/null; then
        return 0  # This is an upgrade
    else
        return 1  # This is a fresh install
    fi
}

# Function to get current installed version
_get_current_version() {
    if command -v axicli &> /dev/null; then
        axicli --version 2>/dev/null | head -n1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown"
    else
        echo "not_installed"
    fi
}

# Function to get pip installation location
_get_pip_install_location() {
    if python -c "import axicli" &> /dev/null; then
        python -c "import axicli, os; print(os.path.dirname(axicli.__file__))" 2>/dev/null || echo "unknown"
    else
        echo "not_found"
    fi
}

# Function to check if axicli was installed via pip to user environment
_is_user_pip_install() {
    local pip_location
    pip_location=$(_get_pip_install_location)
    if [[ "$pip_location" == *"/home/"* ]] || [[ "$pip_location" == *"/.local/"* ]]; then
        return 0  # User pip install
    else
        return 1  # System or package install
    fi
}

# Function to perform official pip upgrade
_do_official_upgrade() {
    echo "=== Performing Official AxiCLI Upgrade ==="
    echo "Current version: $(_get_current_version)"
    
    # Run the official upgrade command
    if python -m pip install https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip --upgrade --upgrade-strategy eager; then
        NEW_VERSION=$(_get_current_version)
        echo "✅ Successfully upgraded to: $NEW_VERSION"
        return 0
    else
        echo "❌ Official upgrade failed, falling back to package installation"
        return 1
    fi
}

# Function to create installation method marker
_create_install_method_marker() {
    local install_method="$1"
    local install_location="$2"
    
    install -d "$pkgdir/usr/share/$pkgname"
    cat > "$pkgdir/usr/share/$pkgname/install_method.txt" << EOF
AxiCLI Installation Method
========================

Installation Method: $install_method
Installation Date: $(date)
Version: $(_get_current_version)
Location: $install_location

For uninstallation, this information will be used to determine
what needs to be cleaned up.
EOF
}

prepare() {
    cd "$srcdir"
    # Extract the zip file
    unzip -q AxiDraw_API.zip
}

build() {
    cd "$srcdir"
    
    # Check if this is an upgrade
    if _is_upgrade; then
        echo "=== AxiCLI Upgrade Detected ==="
        
        # Attempt official upgrade first
        if _do_official_upgrade; then
            echo "✅ Official upgrade successful"
            
            # Create a marker file to indicate official upgrade was used
            touch "$srcdir/.official_upgrade_successful"
            
            # Get installation location for marker
            local pip_location
            pip_location=$(_get_pip_install_location)
            
            # Skip the rest of the build process since we used official upgrade
            return 0
        else
            echo "⚠️  Official upgrade failed, using package installation"
        fi
    fi
    
    # Build the Python package (for fresh installs or fallback)
    echo "=== Building Python Package ==="
    python -m pip build --wheel --no-isolation
}

check() {
    cd "$srcdir"
    
    # Skip checks if official upgrade was successful
    if [ -f "$srcdir/.official_upgrade_successful" ]; then
        echo "✅ Skipping checks - official upgrade completed"
        return 0
    fi
    
    # Run basic tests if available
    if [ -f "test_axicli.py" ]; then
        python test_axicli.py
    fi
    
    # Test CLI basic functionality
    if python -c "import axicli; print('AxiCLI import successful')"; then
        echo "✅ AxiCLI package import test passed"
    else
        echo "❌ AxiCLI package import test failed"
        return 1
    fi
}

package() {
    cd "$srcdir"
    
    # Check if official upgrade was successful
    if [ -f "$srcdir/.official_upgrade_successful" ]; then
        echo "=== Installing from Official Upgrade ==="
        
        # Create package structure
        install -d "$pkgdir/usr/bin"
        install -d "$pkgdir/usr/share/doc/$pkgname"
        install -d "$pkgdir/usr/share/licenses/$pkgname"
        
        # Get installation location
        local pip_location
        pip_location=$(_get_pip_install_location)
        
        # Create symlink to axicli command (should already exist from pip)
        if command -v axicli &> /dev/null; then
            AXICLI_PATH=$(which axicli)
            echo "Creating symlink to: $AXICLI_PATH"
            ln -sf "$AXICLI_PATH" "$pkgdir/usr/bin/axicli"
        fi
        
        # Create installation method marker
        _create_install_method_marker "official_pip_upgrade" "$pip_location"
        
        # Install documentation from extracted files
        install -m644 *.md "$pkgdir/usr/share/doc/$pkgname/" 2>/dev/null || true
        install -m644 *.txt "$pkgdir/usr/share/doc/$pkgname/" 2>/dev/null || true
        
        # Install examples if they exist
        if [ -d "examples" ]; then
            cp -r examples "$pkgdir/usr/share/doc/$pkgname/"
        fi
        if [ -d "examples_config" ]; then
            cp -r examples_config "$pkgdir/usr/share/doc/$pkgname/"
        fi
        
        # Install license if available
        if [ -f "LICENSE" ]; then
            install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
        elif [ -f "COPYING" ]; then
            install -Dm644 COPYING "$pkgdir/usr/share/licenses/$pkgname/COPYING"
        fi
        
        # Create uninstall script for user pip installations
        if _is_user_pip_install; then
            cat > "$pkgdir/usr/share/$pkgname/uninstall_user_pip.sh" << 'EOF'
#!/bin/bash
# Script to uninstall user-installed pip packages

echo "=== AxiCLI User Pip Uninstallation ==="
echo ""

# Get the actual installation location
if python -c "import axicli" &> /dev/null; then
    PIP_LOCATION=$(python -c "import axicli, os; print(os.path.dirname(axicli.__file__))" 2>/dev/null)
    echo "AxiCLI is installed at: $PIP_LOCATION"
    echo ""
    
    read -p "Do you want to uninstall these pip packages? [y/N] " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstalling AxiCLI pip packages..."
        
        # Uninstall the packages
        if pip uninstall -y axicli axidrawinternal; then
            echo "✅ Successfully uninstalled AxiCLI pip packages"
        else
            echo "❌ Failed to uninstall some packages"
            echo "You may need to manually run: pip uninstall -y axicli axidrawinternal"
        fi
    else
        echo "Skipping pip package uninstallation."
        echo "The packages will remain in your Python environment."
    fi
else
    echo "AxiCLI pip packages not found or already removed."
fi

echo ""
echo "Note: Arch package files have already been removed by pacman."
EOF
            chmod +x "$pkgdir/usr/share/$pkgname/uninstall_user_pip.sh"
        fi
        
        return 0
    fi
    
    # Standard package installation (for fresh installs or fallback)
    echo "=== Installing from Package ==="
    
    # Install the package using pip
    python -m pip install --root="$pkgdir" --no-deps --ignore-installed --no-warn-script-location .
    
    # Create installation method marker
    _create_install_method_marker "arch_package" "/usr/lib/python3.x/site-packages/"
    
    # Install documentation
    install -d "$pkgdir/usr/share/doc/$pkgname"
    install -m644 *.md "$pkgdir/usr/share/doc/$pkgname/" 2>/dev/null || true
    install -m644 *.txt "$pkgdir/usr/share/doc/$pkgname/" 2>/dev/null || true
    
    # Install examples if they exist
    if [ -d "examples" ]; then
        cp -r examples "$pkgdir/usr/share/doc/$pkgname/"
    fi
    if [ -d "examples_config" ]; then
        cp -r examples_config "$pkgdir/usr/share/doc/$pkgname/"
    fi
    
    # Install license if available
    if [ -f "LICENSE" ]; then
        install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    elif [ -f "COPYING" ]; then
        install -Dm644 COPYING "$pkgdir/usr/share/licenses/$pkgname/COPYING"
    fi
}

post_install() {
    echo "=== AxiCLI Installation Complete ==="
    
    # Check installation method
    if [ -f "/usr/share/$pkgname/install_method.txt" ]; then
        echo "Installation method information saved to: /usr/share/$pkgname/install_method.txt"
    fi
    
    # Check if this was an official upgrade
    if [ -f "/usr/share/doc/$pkgname/UPGRADE_INFO.txt" ]; then
        echo "✅ AxiCLI was upgraded using the official pip method"
        echo ""
        echo "Current version:"
        axicli --version 2>/dev/null || echo "Run 'axicli --version' to check"
        echo ""
        echo "Upgrade information saved to: /usr/share/doc/$pkgname/UPGRADE_INFO.txt"
    else
        echo "✅ AxiCLI was installed using the Arch package method"
        echo ""
        echo "To get started:"
        echo "  1. Connect your AxiDraw device via USB"
        echo "  2. Test the installation: axicli --version"
        echo "  3. Check for connected devices: axicli -m manual -M list_names"
        echo "  4. Plot an SVG file: axicli your_file.svg"
    fi
    
    echo ""
    echo "For more information, visit: https://axidraw.com/doc/cli_api/"
    echo "Documentation and examples are in: /usr/share/doc/$pkgname/"
}

post_upgrade() {
    echo "=== AxiCLI Upgrade Complete ==="
    
    # Check if this was an official upgrade
    if [ -f "/usr/share/doc/$pkgname/UPGRADE_INFO.txt" ]; then
        echo "✅ AxiCLI was successfully upgraded using the official pip method"
        echo ""
        echo "New version:"
        axicli --version 2>/dev/null || echo "Run 'axicli --version' to check"
        echo ""
        echo "The upgrade used the official command recommended by Evil Mad Scientist Laboratories:"
        echo "python -m pip install https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip --upgrade --upgrade-strategy eager"
    else
        echo "✅ AxiCLI was upgraded using the Arch package method"
        echo ""
        echo "To verify the upgrade:"
        echo "  axicli --version"
    fi
    
    echo ""
    echo "Future upgrades will automatically use the official pip method when available."
}

post_remove() {
    echo "=== AxiCLI Removal Complete ==="
    
    # Check if there was an installation method marker
    if [ -f "/usr/share/$pkgname/install_method.txt" ]; then
        echo ""
        echo "Installation method information:"
        cat "/usr/share/$pkgname/install_method.txt"
        echo ""
        
        # Check if this was a user pip installation
        if [ -f "/usr/share/$pkgname/uninstall_user_pip.sh" ]; then
            echo "⚠️  Important: AxiCLI was installed using pip to your user environment."
            echo ""
            echo "The Arch package files have been removed, but the pip packages may still exist."
            echo ""
            echo "To completely remove AxiCLI, run:"
            echo "  /usr/share/$pkgname/uninstall_user_pip.sh"
            echo ""
            echo "Or manually run:"
            echo "  pip uninstall -y axicli axidrawinternal"
            echo ""
            
            # Offer to run the uninstall script
            read -p "Do you want to run the pip uninstall script now? [y/N] " -n 1 -r
            echo ""
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ -f "/usr/share/$pkgname/uninstall_user_pip.sh" ]; then
                    /usr/share/$pkgname/uninstall_user_pip.sh
                else
                    echo "Uninstall script not found."
                fi
            fi
        else
            echo "✅ AxiCLI was installed using the Arch package method."
            echo "All files have been removed by pacman."
        fi
    else
        echo "✅ AxiCLI and all its files have been removed."
        echo ""
        echo "If you believe some files may remain, you can check:"
        echo "  pip list | grep axi"
        echo "And if found, run:"
        echo "  pip uninstall -y axicli axidrawinternal"
    fi
    
    echo ""
    echo "Thank you for using AxiCLI!"
}
