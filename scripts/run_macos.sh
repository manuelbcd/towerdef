#!/usr/bin/env bash
set -e

# Run on macOS (if enabled in your Flutter environment)
flutter pub get
flutter run -d macos
