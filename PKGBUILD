# Maintainer: Bernardo Kuri <aur+axicli@bkuri.com>

pkgname=axicli
pkgver=3.9.6
pkgrel=1
pkgdesc="AxiDraw Command Line Interface (CLI) for controlling AxiDraw pen plotters"
url="https://axidraw.com/doc/cli_api"
arch=('any')
license=('custom')
depends=('python>=3.8' 'python-lxml' 'python-pyserial' 'python-requests')
makedepends=('python-pip' 'python-setuptools' 'python-wheel' 'python-tqdm' 'python-pyclipper' 'python-build' 'python-virtualenv')
optdepends=('python-numpy: For enhanced mathematical operations'
            'python-pillow: For image processing capabilities')
source=("https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip")
sha256sums=('c29ef0792dc8a2006a3a4abcb306e8d7fa5b93f8ce83c0c781eed226d7eeca24')

# Function to get the source directory name
_get_srcdir() {
    ls -d "$srcdir"/AxiDraw_API_* 2>/dev/null | head -n1
}

# Function to get current installed version
_get_current_version() {
    # Try to get version from pyproject.toml in source directory
    local srcdir=$(_get_srcdir)
    if [ -f "$srcdir/pyproject.toml" ]; then
        grep -o 'version = "[^"]*"' "$srcdir/pyproject.toml" 2>/dev/null | cut -d'"' -f2 || echo "unknown"
    else
        echo "unknown"
    fi
}

# Function to create installation method marker
_create_install_method_marker() {
    local install_method="$1"
    local install_location="$2"
    local current_version="$(_get_current_version)"
    
    install -d "$pkgdir/usr/share/$pkgname"
    cat > "$pkgdir/usr/share/$pkgname/install_method.txt" << EOF
AxiCLI Installation Method
========================

Installation Method: $install_method
Installation Date: $(date)
Version: $current_version
Location: $install_location

For uninstallation, this information will be used to determine
what needs to be cleaned up.
EOF
}

prepare() {
    cd "$srcdir"
    # Extract zip file, overwriting existing files without prompting
    unzip -o AxiDraw_API.zip
}

build() {
    local srcdir=$(_get_srcdir)
    cd "$srcdir"
    
    # Create a virtual environment for building
    echo "=== Creating build virtual environment ==="
    python -m venv build_venv
    source build_venv/bin/activate
    
    # Upgrade pip in the venv
    pip install --upgrade pip setuptools wheel
    
    # Install missing dependencies that aren't in official repos using pip in venv
    echo "=== Installing Missing Dependencies ==="
    pip install plotink ink_extensions
    
    # Build Python package for system installation using modern tools
    echo "=== Building Python Package ==="
    
    # First, try to build with python-build (modern approach)
    if command -v python-build >/dev/null 2>&1; then
        echo "Using python-build to build wheel"
        python -m build --wheel --no-isolation
    elif [ -f "setup.py" ]; then
        echo "Using setup.py to build wheel (deprecated)"
        python setup.py bdist_wheel
    elif [ -f "pyproject.toml" ]; then
        echo "Using pip wheel with pyproject.toml"
        pip wheel --no-deps --no-build-isolation .
    else
        echo "No build method found, trying pip wheel"
        pip wheel --no-deps --no-build-isolation .
    fi
    
    # Deactivate virtual environment
    deactivate
    
    # Check if wheel was created
    echo "=== Checking for wheel file ==="
    if [ ! -d "dist" ]; then
        echo "ERROR: dist directory was not created"
        echo "Current directory contents:"
        ls -la
        return 1
    fi
    echo "Contents of dist/:"
    ls -la dist/
    if [ -z "$(ls -A dist/)" ]; then
        echo "ERROR: dist/ directory is empty"
        return 1
    fi
    local wheel_count=$(ls dist/*.whl 2>/dev/null | wc -l)
    if [ "$wheel_count" -eq 0 ]; then
        echo "ERROR: No wheel file found in dist/ directory"
        return 1
    fi
    echo "Found $wheel_count wheel file(s) in dist/"
}

check() {
    local srcdir=$(_get_srcdir)
    cd "$srcdir"
    
    # Test CLI basic functionality
    if python -c "import axicli; print('AxiCLI import successful')" 2>/dev/null; then
        echo "✅ AxiCLI package import test passed"
    else
        echo "❌ AxiCLI package import test failed"
        return 1
    fi
}

package() {
    local srcdir=$(_get_srcdir)
    cd "$srcdir"
    
    # Install package to system location using pip
    echo "=== Installing from Package ==="
    
    # Install missing dependencies first using pip
    python -m pip install --root="$pkgdir" --prefix=/usr --no-deps --ignore-installed --no-warn-script-location plotink ink_extensions
    
    # Install package using pip - expand the glob
    local wheel_file
    wheel_file=$(ls dist/*.whl | head -n1)
    if [ -n "$wheel_file" ]; then
        python -m pip install --root="$pkgdir" --prefix=/usr --no-deps --ignore-installed --no-warn-script-location "$wheel_file"
    else
        echo "ERROR: No wheel file found in dist/ directory"
        return 1
    fi
    
    # Also install axidrawinternal wheel using pip - expand the glob
    local axidrawinternal_wheel
    axidrawinternal_wheel=$(ls prebuilt_dependencies/axidrawinternal-*.whl | head -n1)
    if [ -n "$axidrawinternal_wheel" ]; then
        python -m pip install --root="$pkgdir" --prefix=/usr --no-deps --ignore-installed --no-warn-script-location "$axidrawinternal_wheel"
    else
        echo "ERROR: No axidrawinternal wheel file found in prebuilt_dependencies/ directory"
        return 1
    fi
    
    # Create proper executable scripts instead of symlinks
    install -d "$pkgdir/usr/bin"
    
    # Create axicli executable script
    cat > "$pkgdir/usr/bin/axicli" << 'EOF'
#!/usr/bin/env python3
import sys
from axicli.__main__ import main
if __name__ == '__main__':
    sys.exit(main())
EOF
    
    # Create htacli executable script  
    cat > "$pkgdir/usr/bin/htacli" << 'EOF'
#!/usr/bin/env python3
import sys
from axicli.__main__ import main
if __name__ == '__main__':
    sys.exit(main())
EOF
    
    # Make scripts executable
    chmod +x "$pkgdir/usr/bin/axicli"
    chmod +x "$pkgdir/usr/bin/htacli"
    
    # Create installation method marker
    _create_install_method_marker "arch_package" "/usr/lib/python3.x/site-packages/"
    
    # Install documentation
    install -d "$pkgdir/usr/share/doc/$pkgname"
    install -m644 *.md "$pkgdir/usr/share/doc/$pkgname/" 2>/dev/null || true
    install -m644 *.txt "$pkgdir/usr/share/doc/$pkgname/" 2>/dev/null || true
    
    # Install examples if they exist
    if [ -d "examples_py_axidraw" ]; then
        cp -r examples_py_axidraw "$pkgdir/usr/share/doc/$pkgname/"
    fi
    if [ -d "examples_config" ]; then
        cp -r examples_config "$pkgdir/usr/share/doc/$pkgname/"
    fi
    
    # Install license if available
    if [ -f "pyaxidraw/LICENSE.txt" ]; then
        install -Dm644 pyaxidraw/LICENSE.txt "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    elif [ -f "LICENSE" ]; then
        install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    elif [ -f "COPYING" ]; then
        install -Dm644 COPYING "$pkgdir/usr/share/licenses/$pkgname/COPYING"
    fi
}

post_install() {
    echo "=== AxiCLI Installation Complete ==="
    
    echo "✅ AxiCLI was installed using Arch package method"
    echo ""
    echo "To get started:"
    echo "  1. Connect your AxiDraw device via USB"
    echo "  2. Test installation: axicli --version"
    echo "  3. Check for connected devices: axicli -m manual -M list_names"
    echo "  4. Plot an SVG file: axicli your_file.svg"
    echo ""
    echo "For more information, visit: https://axidraw.com/doc/cli_api/"
    echo "Documentation and examples are in: /usr/share/doc/$pkgname/"
}

post_upgrade() {
    echo "=== AxiCLI Upgrade Complete ==="
    
    echo "✅ AxiCLI was upgraded using Arch package method"
    echo ""
    echo "To verify upgrade:"
    echo "  axicli --version"
    echo ""
    echo "Future upgrades will use standard Arch package method."
}

post_remove() {
    echo "=== AxiCLI Removal Complete ==="
    
    echo "✅ AxiCLI and all its files have been removed by pacman."
    echo ""
    echo "Thank you for using AxiCLI!"
}
