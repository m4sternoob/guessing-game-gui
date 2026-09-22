#!/bin/bash
# Build script for macOS
# Prerequisites:
# 1. Install Homebrew: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 2. Install dependencies: brew install cmake sdl2

set -e  # Exit on error

echo "🔨 Building Guessing Game GUI for macOS..."

# Check for dependencies
if ! command -v cmake &> /dev/null; then
    echo "❌ cmake not found. Install with: brew install cmake"
    exit 1
fi

if ! command -v sdl2-config &> /dev/null; then
    echo "❌ SDL2 not found. Install with: brew install sdl2"
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
echo "⚙️  Configuring with CMake..."
cmake ..

# Build
echo "🔨 Building..."
make -j$(sysctl -n hw.ncpu)

echo ""
echo "✅ Build complete!"
echo "📦 App bundle: ./GuessingGame.app"
echo ""
echo "To run: open ./GuessingGame.app"
echo "Or from terminal: ./GuessingGame.app/Contents/MacOS/GuessingGame"