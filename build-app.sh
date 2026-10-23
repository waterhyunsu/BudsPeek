#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP="$ROOT/build/BudsPeek.app"
SDK="$(xcrun --sdk macosx --show-sdk-path)"

mkdir -p "$APP/Contents/MacOS" "$ROOT/build"
clang++ -std=c++17 -target arm64-apple-macosx14.0 -isysroot "$SDK" \
  -I "$ROOT/Sources/BudsPeekCore/include" \
  -c "$ROOT/Sources/BudsPeekCore/budspeek_core.cpp" \
  -o "$ROOT/build/budspeek_core.o"
swiftc -target arm64-apple-macosx14.0 -sdk "$SDK" \
  -framework SwiftUI -framework AppKit -framework IOBluetooth -framework CoreBluetooth \
  -I "$ROOT/Sources/BudsPeekCore/include" -lc++ \
  $(find "$ROOT/Sources/BudsPeek" -name '*.swift' -print) \
  "$ROOT/build/budspeek_core.o" \
  -o "$APP/Contents/MacOS/BudsPeek"
cp "$ROOT/Packaging/Info.plist" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleVersion 1' "$APP/Contents/Info.plist" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c 'Add :CFBundleVersion string 1' "$APP/Contents/Info.plist"

echo "Built $APP"
