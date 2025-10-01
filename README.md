# AxiCLI Arch Linux Package

This repository contains an Arch Linux PKGBUILD for installing the AxiDraw Command Line Interface (AxiCLI).

## About AxiCLI

AxiCLI is the official command line interface for controlling AxiDraw pen plotters from Evil Mad Scientist Laboratories. It allows you to:

- Plot SVG files with your AxiDraw
- Control pen movements and settings
- Configure multiple AxiDraw units
- Automate plotting workflows
- Integrate with shell scripts and other tools

## Package Information

- **Package Name**: `axicli`
- **Version**: 3.9.6
- **License**: Custom (Evil Mad Scientist Laboratories)
- **Architecture**: `any` (Python package)
- **Dependencies**: Python 3.8+

## Installation

### Method 1: Using the build script (recommended)

```bash
# Clone or download this repository
cd axicli

# Run the build script
./build.sh

# Install the built package (replace filename with actual package name)
sudo pacman -U axicli-3.9.6-1-any.pkg.tar.zst
```

### Method 2: Manual build with makepkg

```bash
# Install build dependencies if needed
sudo pacman -S base-devel python-pip python-setuptools python-wheel

# Build the package
makepkg -s

# Install the package
sudo pacman -U axicli-*.pkg.tar.*
```

### Method 3: Direct installation (alternative)

```bash
# Install directly from the official source
python -m pip install https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip
```

## Usage

After installation, you can use the `axicli` command:

### Basic Commands

```bash
# Check installation
axicli --version

# List connected AxiDraw devices
axicli -m manual -M list_names

# Plot an SVG file
axicli your_file.svg

# Plot with progress bar
axicli your_file.svg --progress

# Plot multiple copies
axicli your_file.svg --copies 5

# Preview a plot (no actual plotting)
axicli your_file.svg --preview --report_time
```

### Configuration

```bash
# Use a custom configuration file
axicli your_file.svg --config my_config.py

# Set pen down speed
axicli your_file.svg --speed_pendown 30

# Set pen up speed
axicli your_file.svg --speed_penup 80

# Plot specific layers only
axicli your_file.svg --mode layers --layer 1
```

### Setup Commands

```bash
# Cycle pen down and up
axicli --mode cycle

# Raise pen and disable motors
axicli --mode align

# Toggle pen position
axicli --mode toggle

# Get system information
axicli --mode sysinfo
```

## Files and Locations

- **Executable**: `/usr/bin/axicli`
- **Documentation**: `/usr/share/doc/axicli/`
- **Examples**: `/usr/share/doc/axicli/examples/`
- **Configuration templates**: `/usr/share/doc/axicli/examples_config/`
- **License**: `/usr/share/licenses/axicli/`

## Dependencies

### Required

- `python>=3.8` - Python interpreter

### Optional

- `python-serial` - USB communication with AxiDraw devices
- `python-numpy` - Enhanced mathematical operations
- `python-pillow` - Image processing capabilities

## Troubleshooting

### USB Permission Issues

If you encounter permission errors when accessing the AxiDraw:

```bash
# Add your user to the uucp group
sudo usermod -a -G uucp $USER

# Log out and log back in, or run:
newgrp uucp
```

### Python Module Issues

If the axicli command is not found:

```bash
# Ensure the Python packages are properly installed
python -m pip install --force-reinstall https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip

# Or check if the package is installed
python -c "import axicli; print('AxiCLI installed successfully')"
```

### Device Not Found

If your AxiDraw is not detected:

```bash
# Check USB permissions
ls -l /dev/ttyACM*

# List all serial devices
axicli -m manual -M list_names

# Check if the device is recognized
dmesg | grep -i acm
```

## Documentation

- **Official API Documentation**: https://axidraw.com/doc/cli_api/
- **AxiDraw User Guide**: https://axidraw.com/guide
- **Evil Mad Scientist Wiki**: http://axidraw.com/docs
- **GitHub Repository**: https://github.com/evil-mad/axidraw

## Support

- **Contact Form**: https://shop.evilmadscientist.com/contact
- **Discord Chat**: https://discord.gg/axhTzmr
- **GitHub Issues**: https://github.com/evil-mad/axidraw/issues

## Contributing

To contribute improvements to this PKGBUILD:

1. Fork the repository
2. Make your changes
3. Test the build process
4. Submit a pull request

## License

The AxiCLI software is Copyright 2023 Windell H. Oskay, Evil Mad Scientist Laboratories. Please refer to the license file included with the package for specific terms.

## Changelog

### Version 3.9.6
- Added Python 3.12 support
- Dropped Python 3.7 support
- Maintenance release

### Version 3.9.4
- Pen-lift servo motor initialization improvements
- Last version to support Python 3.7

For older versions, see the official API documentation.
