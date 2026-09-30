#!/bin/bash
# Package the macOS app for distribution: bundle SDL2 inside the .app and ad-hoc code sign.
# Run from the repo root AFTER building:
#   ./source/macos/build_macos.sh
#   ./source/macos/package_macos.sh
# Then zip it: cd build && zip -r -y ../GuessingGame-macOS-v2.5.2.zip GuessingGame.app
set -e

APP="build/GuessingGame.app"
BIN="$APP/Contents/MacOS/GuessingGame"

if [ ! -f "$BIN" ]; then
  echo "Build the app first: ./source/macos/build_macos.sh"
  exit 1
fi

SDL_DYLIB="$(otool -L "$BIN" | grep -o '/[^ ]*libSDL2[^ ]*\.dylib' | head -1)"
echo "Bundling $SDL_DYLIB ..."
mkdir -p "$APP/Contents/Frameworks"
cp "$SDL_DYLIB" "$APP/Contents/Frameworks/"
install_name_tool -change "$SDL_DYLIB" "@executable_path/../Frameworks/$(basename "$SDL_DYLIB")" "$BIN"

echo "Ad-hoc signing ..."
codesign --force --deep --sign - "$APP"
codesign --verify --verbose "$APP"

echo "Done. Package it with:"
echo "  cd build && zip -r -y ../GuessingGame-macOS-v2.5.2.zip GuessingGame.app"
