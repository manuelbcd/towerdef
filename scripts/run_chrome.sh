#!/usr/bin/env bash
set -e

# Run the Flutter app in Chrome for fast iteration
flutter pub get
flutter run -d chrome
