#!/usr/bin/env bash
set -e

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Force load direnv
eval "$(direnv export bash)"

echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
echo ""
echo "Available wlroots packages:"
pkg-config --list-all | grep -i wlr || echo "No wlroots packages found"
echo ""
echo "Checking wlroots-0.18:"
pkg-config --exists wlroots-0.18 && echo "✓ Found" || echo "✗ Not found"
echo ""
echo "Building dwl..."
make clean
make all