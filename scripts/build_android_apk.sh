#!/usr/bin/env bash
set -e

# Simple wrapper to build Android APK
flutter pub get
flutter build apk --release
echo "APK built: build/app/outputs/flutter-apk/app-release.apk"
