#!/bin/bash

# AxiCLI PKGBUILD Updater
# Based on prepare.sh pattern for AUR package maintenance

set -e

echo "=== AxiCLI PKGBUILD Updater ==="
echo ""

# Check if PKGBUILD exists
if [ ! -f "PKGBUILD" ]; then
    echo "Error: PKGBUILD not found in current directory"
    exit 1
fi

# Check if git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get current version from PKGBUILD
CURRENT_VERSION=$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2)
echo "Current version: $CURRENT_VERSION"

# Get latest version from official source
echo "Checking for latest version..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

python -m pip download --no-deps https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip 2>/dev/null || true
unzip -q AxiDraw_API.zip 2>/dev/null || true

# Try to get version from setup.py or pyproject.toml
if [ -f "setup.py" ]; then
    LATEST_VERSION=$(grep "version=" setup.py | cut -d"'" -f2 2>/dev/null || grep "version=" setup.py | cut -d"'" -f2 2>/dev/null || echo "unknown")
elif [ -f "pyproject.toml" ]; then
    LATEST_VERSION=$(grep "^version =" pyproject.toml | cut -d"'" -f2 2>/dev/null || echo "unknown")
else
    LATEST_VERSION=$(python -m pip show --files axicli 2>/dev/null | grep "^Version:" | cut -d' ' -f2 2>/dev/null || echo "unknown")
fi

cd - > /dev/null
rm -rf "$TEMP_DIR"

if [ "$LATEST_VERSION" = "unknown" ]; then
    echo "Could not determine latest version automatically."
    read -p "Enter latest version manually: " LATEST_VERSION
    if [ -z "$LATEST_VERSION" ]; then
        echo "No version provided. Exiting."
        exit 1
    fi
fi

echo "Latest version: $LATEST_VERSION"

# Compare versions
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "PKGBUILD is already up to date (version $CURRENT_VERSION)"
    exit 0
fi

echo "New version available: $LATEST_VERSION"
read -p "Update PKGBUILD to version $LATEST_VERSION? [Y/n] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
    echo "Update cancelled."
    exit 0
fi

# Update PKGBUILD
echo "Updating PKGBUILD..."

# Create backup
cp PKGBUILD PKGBUILD.backup

# Update pkgver
sed -i "s/^pkgver=.*/pkgver=$LATEST_VERSION/" PKGBUILD

# Reset pkgrel to 1
sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD

# Remove SKIP line for checksums
sed -i "/sha256sums=(SKIP)/d" PKGBUILD

echo "PKGBUILD updated to version $LATEST_VERSION"

# Execute makepkg commands (like prepare.sh)
echo ""
echo "Running makepkg commands..."
makepkg -Co && \
makepkg --printsrcinfo > .SRCINFO || exit 1

echo "Checksums generated and .SRCINFO created"

# Extract pkgver from .SRCINFO
PKGVER=$(grep -E "^\s*pkgver = " .SRCINFO | cut -d" " -f3)

# Create commit message with v prefix
MESSAGE="v$PKGVER"

echo ""
echo "Commit message: $MESSAGE"

# Add files, commit and push (like prepare.sh)
echo "Committing and pushing changes..."
git add .SRCINFO PKGBUILD && \
git commit -m "$MESSAGE" && \
git push

echo ""
echo "Update complete!"
echo "Version updated from $CURRENT_VERSION to $LATEST_VERSION"
echo "Changes pushed to remote repository"
