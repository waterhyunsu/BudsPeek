
#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/BudsPeek.app"
SDK="$(xcrun --sdk macosx --show-sdk-path)"

ICON_SOURCE="$ROOT/Packaging/AppIcon.png"
ICONSET="$BUILD/BudsPeek.iconset"
ICON_OUTPUT="$APP/Contents/Resources/AppIcon.icns"

echo "==> Preparing app bundle"

mkdir -p \
  "$APP/Contents/MacOS" \
  "$APP/Contents/Resources" \
  "$BUILD"

echo "==> Compiling C++ core"

clang++ -std=c++17 \
  -target arm64-apple-macosx14.0 \
  -isysroot "$SDK" \
  -I "$ROOT/Sources/BudsPeekCore/include" \
  -c "$ROOT/Sources/BudsPeekCore/budspeek_core.cpp" \
  -o "$BUILD/budspeek_core.o"

echo "==> Compiling Swift application"

swiftc \
  -target arm64-apple-macosx14.0 \
  -sdk "$SDK" \
  -framework SwiftUI \
  -framework AppKit \
  -framework IOBluetooth \
  -framework CoreBluetooth \
  -I "$ROOT/Sources/BudsPeekCore/include" \
  -lc++ \
  $(find "$ROOT/Sources/BudsPeek" -name '*.swift' -print) \
  "$BUILD/budspeek_core.o" \
  -o "$APP/Contents/MacOS/BudsPeek"

echo "==> Configuring Info.plist"

cp "$ROOT/Packaging/Info.plist" \
   "$APP/Contents/Info.plist"

PLIST="$APP/Contents/Info.plist"

/usr/libexec/PlistBuddy \
  -c 'Set :CFBundleVersion 1' "$PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy \
  -c 'Add :CFBundleVersion string 1' "$PLIST"

echo "==> Generating macOS app icon"

if [ ! -f "$ICON_SOURCE" ]; then
  echo "ERROR: AppIcon.png not found:"
  echo "$ICON_SOURCE"
  exit 1
fi

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$ICON_SOURCE" \
    --out "$ICONSET/icon_${size}x${size}.png" >/dev/null

  double=$((size * 2))

  sips -z "$double" "$double" "$ICON_SOURCE" \
    --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o "$ICON_OUTPUT"

rm -rf "$ICONSET"

/usr/libexec/PlistBuddy \
  -c 'Set :CFBundleIconFile AppIcon' "$PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy \
  -c 'Add :CFBundleIconFile string AppIcon' "$PLIST"

echo "==> Validating app bundle"

plutil -lint "$PLIST"

test -f "$ICON_OUTPUT"

echo "==> Build complete"
echo "App: $APP"
echo "Icon: $ICON_OUTPUT"
