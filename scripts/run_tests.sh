#!/usr/bin/env bash
set -e

# Run Flutter unit tests
flutter pub get
flutter test
