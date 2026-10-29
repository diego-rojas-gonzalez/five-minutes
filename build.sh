#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP="Pomodoro.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp Info.plist "$APP/Contents/Info.plist"

swiftc -O -swift-version 6 $(find Sources -name '*.swift') -o "$APP/Contents/MacOS/Pomodoro"
codesign --force --sign - "$APP"

echo "Listo: $(pwd)/$APP"
