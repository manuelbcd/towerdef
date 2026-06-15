#!/usr/bin/env bash
set -e

# Usage: ./run_emulator.sh <emulator_id>
EMULATOR_ID=$1
if [ -z "$EMULATOR_ID" ]; then
  echo "Please provide an emulator id. Run 'flutter emulators' to list available emulators."
  exit 2
fi

flutter emulators --launch "$EMULATOR_ID"
flutter pub get
flutter run -d "$EMULATOR_ID"
