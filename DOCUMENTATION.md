# TowerDef — Documentation

This document summarizes the boilerplate and the playable prototype created in this workspace, and explains how to run and test it in various environments (emulator, web, desktop).

**Project summary**
- A lightweight Flutter 2D tower defense idle prototype.
- Single-screen playable demo with 3 tower types (Archer, Magic, Cannon), placement/play stages, map paths, configured waves, enemies, projectiles, coins, and upgrades (up to 3 levels per tower).
- Localization support (English/Spanish) and UI volume controls present in the app shell.

**Files & purpose**
- [lib/main.dart](lib/main.dart) — minimal app entry: launches `GameScreen`.
- [lib/screens/game_screen.dart](lib/screens/game_screen.dart) — main gameplay UI, rendering, HUD, tower selection and upgrade panel.
- [lib/game/game_engine.dart](lib/game/game_engine.dart) — game logic: waves, spawning, coins, health, tower shooting.
- [lib/models/game_config.dart](lib/models/game_config.dart) — tower stats, enemy defaults, movement patterns, and game stages.
- [lib/models/game_map.dart](lib/models/game_map.dart) — maps, paths, tower placeholders, start/end lines, and explicit wave definitions.
- [lib/models/tower.dart](lib/models/tower.dart) — `Tower` class, factory `Tower.create(...)`, stats, upgrade logic.
- [lib/models/enemy.dart](lib/models/enemy.dart) — `Enemy` model, movement and damage handling.
- [lib/models/projectile.dart](lib/models/projectile.dart) — `Projectile` model and movement logic.
- [lib/models/game_data.dart](lib/models/game_data.dart) — sample data and constants for shop UI.
- [lib/screens/play_screen.dart](lib/screens/play_screen.dart) — play / difficulty selector UI and settings panel.
- [lib/screens/market_screen.dart](lib/screens/market_screen.dart) — marketplace UI skeleton.
- [lib/screens/start_screen.dart](lib/screens/start_screen.dart) — main menu skeleton (not used in single-screen demo).
- [lib/localization/app_localizations.dart](lib/localization/app_localizations.dart) — simple localization map for English & Spanish.
- [lib/widgets/volume_controls.dart](lib/widgets/volume_controls.dart) — music and sound sliders (UI-only placeholder).
- [lib/README.md](README.md) and [GAMEPLAY.md](GAMEPLAY.md) — high level README and gameplay guide.

**Gameplay overview**
- The game starts in placement stage:
  - select Archer, Magic, or Cannon.
  - tap one of the five map placeholders to place or replace a tower.
  - press Start Play to begin combat.
- Tower types:
  - Archer: fast fire rate, moderate damage, longest range.
  - Magic: balanced stats with splash damage.
  - Cannon: high damage, slow fire rate, splash damage.
- Each enemy killed awards `25` coins.
- Each tower can be upgraded up to 3 times during the session. Upgrade effects (per level): +5 damage, +15 range, +0.3 fire rate. Upgrade cost: 150 + (level * 50).
- Waves are configured per map in `game_map.dart`.
- If an enemy reaches the end-line, you lose 1 life point; game over at 0.

**How to run locally (minimal)**
Prerequisites: Flutter SDK installed and available on PATH. For Android emulator testing you'll also need Android SDK command-line tools.

Quick start (from project root):

```bash
flutter pub get
flutter run
```

This tries to run on the default connected device. To run explicitly on web or desktop (fast iteration):

```bash
# Run in Chrome (fast UI/test loop)
flutter run -d chrome

# macOS desktop (if enabled in your Flutter install)
flutter run -d macos
```

**Testing in a virtual Android emulator**
1. Install Android SDK command-line tools (no full Android Studio required).
2. Create an AVD with `avdmanager` or via Android Studio.
3. Launch the emulator (or from terminal):

```bash
flutter emulators            # list available emulators
flutter emulators --launch <emulator_id>
flutter run -d <emulator_id>
```

Notes:
- Emulators are slower than device but useful for quick iterations when you don't want to deploy to your phone.
- Prefer web or macOS for very quick UI tweaks, then verify on emulator before device testing.

**How to test gameplay features**
- Start the app (see run commands above).
- The game starts in placement stage. Pick a tower type, tap highlighted slots to place towers, then press Start Play.
- With a placed tower selected during play, use the Upgrade button in the panel to spend coins (if you have enough). Up to 3 upgrades per tower.
- Watch waves follow the configured map path. Towers shoot automatically when enemies are in range.
- When an enemy dies you gain coins. If it escapes off-screen you lose 1 health.

**UI controls and behavior**
- Placement stage: tower selector chips choose the tower type, highlighted map placeholders accept tower placement, and range previews show coverage.
- Play stage: tap a tower to select it and show the stat panel with name, description, stats, upgrade button.
- Upgrade button: spends coins and increases tower stats (visual: small ring and stat chips update).
- HUD: shows coins, life, current/total wave, kills, map name, stage, and a Restart button.
- Localization and volume controls exist in `PlayScreen` and are a UI-level placeholder (no audio integrated yet).

**Developer notes & design choices**
- Lightweight: uses only Flutter built-ins, no heavy game engine dependency.
- Rendering: `CustomPaint` in `GameScreen` draws towers, enemies, projectiles, health bars and grid.
- Game loop: `Ticker` in `GameScreen` advances the `GameEngine` using delta-time.
- Collision: simple radius-based collision (projectiles vs enemies), with configured splash radius for Magic/Cannon.
- Waves: `GameMap.waves` contains explicit `WaveConfig` entries, each with enemy groups defining type/count/health/speed/movement pattern.

**Minimal install checklist (for your work Mac M2)**
- Install Flutter SDK (recommended install channel: stable).
- Optionally install OpenJDK and Android SDK command-line tools if you want emulator or APK builds.
- Use `flutter run -d chrome` or `flutter run -d macos` for rapid iteration without Android tooling.

**Quick troubleshooting**
- `flutter` not found: ensure `flutter` is on your PATH. Follow official Flutter macOS install steps.
- `emulator not listed`: run `flutter emulators` and create an AVD if none exist.
- App crashes: run `flutter run -v` to see verbose logs.

**Next development suggestions**
- Integrate simple sound effects and wire `volume_controls` to actual audio playback.
- Add tower placement and save/load of progression.
- Add particle effects (kept out for initial lightweight target).
- Add unit tests for `GameEngine` functions (wave progression, upgrade costs, spawn logic).

---

If you want, I can also:
- Add Spanish translations to the new UI strings for `Tower.displayName` and `abilityDescription`.
- Add quick unit tests for the `GameEngine` progression logic.
- Add simple audio and wire the UI sliders to actual audio playback.

---

## Helper scripts added

- `scripts/run_chrome.sh` — runs the app in Chrome for fast iteration.
- `scripts/run_emulator.sh` — launches an emulator and runs the app (usage: `./scripts/run_emulator.sh <emulator_id>`).
- `scripts/run_macos.sh` — runs the app on macOS (if enabled).
- `scripts/build_android_apk.sh` — builds a release Android APK.
- `scripts/run_tests.sh` — runs `flutter test` to execute unit tests.

Make scripts executable and run them as follows:

```bash
chmod +x scripts/*.sh
./scripts/run_chrome.sh
./scripts/run_emulator.sh <emulator_id>
./scripts/run_macos.sh
./scripts/build_android_apk.sh
./scripts/run_tests.sh
```

## Audio wiring

The project includes a minimal `AudioManager` (`lib/audio/audio_manager.dart`) using `audioplayers`.
- Volume controls in the game HUD open a bottom-sheet and are wired to `AudioManager`.
- No audio assets are included by default. To enable background music or SFX, add files under `assets/audio/` and reference them via `AudioManager.playMusicFromAsset('audio/yourfile.mp3')` or `playSfxFromAsset(...)`.

To include assets, add them in `pubspec.yaml` under `flutter.assets:` and run `flutter pub get`.

## Multi-platform notes

This project targets Flutter's supported platforms. Quick checklist per OS:

- **macOS**: Requires Xcode for macOS/iOS targets. Use `flutter config --enable-macos-desktop`.
- **Windows**: Requires Visual Studio (with Desktop workload) for desktop builds. Use `flutter config --enable-windows-desktop`. Helper PowerShell scripts are in `scripts/run_windows.ps1` and `scripts/run_windows_chrome.ps1`.
- **Linux**: Install GTK and other build deps and enable Linux desktop with `flutter config --enable-linux-desktop`.
- **Android**: Android SDK + command line tools; use `flutter build apk` for release builds.
- **Web**: Chrome is recommended for fastest iteration: `flutter run -d chrome`.

When switching development machines (e.g., Windows), follow Flutter's official setup guide for that platform and run `flutter doctor` to confirm required components are installed.

## CI/CD Pipeline (GitHub Actions)

This project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs on every push and pull request.

### What the CI does

1. **Runs on three platforms**: Ubuntu, macOS, Windows
2. **Verifies Flutter setup**: Runs `flutter doctor -v`
3. **Analyzes Dart code**: Checks for code quality issues (`flutter analyze`)
4. **Runs unit tests**: Executes `flutter test` on all platforms
5. **Builds platform-specific outputs**:
   - **Ubuntu**: Web + Android APK
   - **macOS**: Web + macOS desktop app
   - **Windows**: Web + Windows desktop app
6. **Checks code formatting**: Validates Dart format consistency
7. **Uploads artifacts**: Stores build outputs for 30 days

### Triggering CI

The workflow automatically triggers on:
- Push to `main` or `develop` branches
- Pull requests against `main` or `develop`

To view CI status:
1. Push code to GitHub: `git push`
2. Go to your repository → **Actions** tab
3. Click the latest workflow run to see detailed logs
4. Failed tests or lint errors will block the workflow

### Local CI simulation

To run the same checks locally before pushing:

```bash
# Install dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Check formatting
dart format --set-exit-if-changed lib test

# Build web
flutter build web --release

# Build for your platform
flutter build macos --release    # macOS
flutter build windows --release  # Windows
flutter build linux --release    # Linux
flutter build apk --release      # Android
```

### Downloading build artifacts

After a successful CI run:
1. Go to **Actions** → select the workflow run
2. Scroll to **Artifacts** section at the bottom
3. Download `build-ubuntu-latest`, `build-macos-latest`, or `build-windows-latest`
4. Extract and test locally

### Debugging CI failures

If CI fails:
1. Check the **Actions** tab for detailed logs
2. Look for error messages in the failed step
3. Common issues:
   - Missing dependencies: Run `flutter pub get` locally
   - Test failures: Run `flutter test` locally and fix
   - Format issues: Run `dart format lib test` to auto-fix
   - Platform-specific build issues: Check platform-specific setup (Xcode, Visual Studio, etc.)
4. Push fixes and CI will re-run automatically

### Customizing CI

Edit `.github/workflows/ci.yml` to:
- Change Flutter version (update `flutter-version`)
- Add or remove platforms (modify `matrix.os`)
- Add additional build steps (e.g., APK signing for release)
- Set up deployment to stores (Play Store, App Store, GitHub Releases)

Document created at: `DOCUMENTATION.md` in project root.
