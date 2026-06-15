# TowerDef

A lightweight Flutter tower defense idle game prototype with English and Spanish support.

## ✨ Features

- **3 Tower Types**: Archer, Magic, and Cannon towers with unique visual identities
- **Upgrade System**: Enhance towers up to 3 levels (damage, range, fire rate)
- **Dynamic Waves**: Progressive enemy difficulty and spawn rates
- **Real-time Combat**: Canvas-based 2D rendering with physics
- **Currency System**: Earn coins by defeating enemies, spend on upgrades
- **Multi-language**: Full English and Spanish localization
- **Volume Controls**: Adjustable music and sound effects
- **Lightweight**: ~300KB footprint, optimized for M2 macOS and Android

## 🎮 Gameplay

**Goal**: Survive enemy waves by upgrading towers strategically.

- Select towers to manage upgrades
- Each enemy killed grants 25 coins
- Each escaped enemy costs 1 health (start with 20)
- Waves increase in difficulty and frequency
- Game ends when health reaches 0

For detailed mechanics, see [GAMEPLAY.md](GAMEPLAY.md).

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry & navigation
├── game/
│   └── game_engine.dart     # Core game loop & logic
├── screens/
│   ├── start_screen.dart    # Main menu
│   ├── market_screen.dart   # Tower shop & upgrades
│   ├── play_screen.dart     # Level selector
│   └── game_screen.dart     # Active gameplay
├── models/
│   ├── game_data.dart       # Game constants
│   ├── tower.dart           # Tower class
│   ├── enemy.dart           # Enemy class
│   └── projectile.dart      # Projectile class
├── localization/
│   └── app_localizations.dart # EN/ES translations
└── widgets/
    └── volume_controls.dart  # Audio sliders
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0+)
- macOS M2 or Android device
- ~500 MB for minimal build (JDK + Android SDK tools)

### Installation

1. Clone/open the project:
```bash
cd /Users/manuel.boira/personal/towerdef
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run locally:
```bash
flutter run -d chrome          # Web browser (testing)
flutter run                    # Connected device/emulator
```

### Build for Android

```bash
flutter build apk --release    # APK file
flutter build appbundle        # Google Play Bundle
flutter install                # Direct to device
```

## 🧭 Multi-Platform Support

This project is set up to run on all Flutter-supported platforms: Web, Android, iOS (macOS only), macOS, Windows, and Linux. Below are platform-specific prerequisites and commands.

### Windows
- Install Flutter SDK for Windows and add `flutter` to your `PATH`.
- Install Android SDK / Android Studio if you plan to build Android APKs.
- Enable desktop support if needed:
```powershell
flutter config --enable-windows-desktop
```
- Run locally (PowerShell):
```powershell
flutter pub get
flutter run -d windows
```
- Helper scripts: `scripts/run_windows.ps1` and `scripts/run_windows_chrome.ps1` (PowerShell). Use `.
un_windows.ps1` from the `scripts/` folder.

### Linux
- Install Flutter SDK for Linux and required build dependencies for desktop.
- Enable desktop support:
```bash
flutter config --enable-linux-desktop
```
- Run:
```bash
flutter pub get
flutter run -d linux
```

### macOS
- Already supported; to enable desktop builds:
```bash
flutter config --enable-macos-desktop
flutter pub get
flutter run -d macos
```

### Web (cross-platform fast-iteration)
- Use Chrome for the fastest iteration:
```bash
flutter run -d chrome
```

Notes:
- Desktop targets require platform toolchains (Xcode for iOS/macOS, Visual Studio for Windows, GTK dev libs for Linux). Follow Flutter's platform setup docs when configuring a new machine.
- The project is intentionally lightweight: assets and platform-specific native code are minimal by default.

### Testing in a virtual environment

If you want to avoid deploying to a physical Android device each time, use one of these options:

- **Android Emulator**
  1. Install Android SDK command-line tools.
  2. Create an AVD in `Android Studio` or with `avdmanager`.
  3. Launch the emulator and run `flutter devices` to confirm it appears.
  4. Execute:
    ```bash
    flutter run -d <emulator_id>
    ```

- **Web testing**
  Run the game in Chrome or another supported browser:
    ```bash
    flutter run -d chrome
    ```
  This is useful for fast iteration and UI validation before testing on Android.

- **Desktop testing**
  On macOS you can try a local desktop build:
    ```bash
    flutter run -d macos
    ```
  This gives a similar environment without touching your Android device.

- **Flutter emulator helper**
  Start a saved emulator from the terminal:
    ```bash
    flutter emulators --launch <emulator_id>
    flutter run
    ```

Use the virtual emulator for development, then only deploy to a real device when you want final performance or touch testing.

## 🎨 Visual Design

- **Dark Theme**: Indigo/purple gradient backgrounds
- **Glow Effects**: Subtle light effects on towers and projectiles
- **Glass Morphism**: Semi-transparent UI panels with borders
- **2D Vector Style**: Circles and geometric shapes for all entities
- **Color Coding**: 
  - Green = Archer Tower
  - Purple = Magic Tower
  - Red = Cannon Tower
  - Gold/Amber = Coins & upgrades

## 🛠️ Architecture

### Game Engine (`game_engine.dart`)
- Delta-time based update loop
- Collision detection for projectiles & enemies
- Wave progression logic
- Coin & health management

### Rendering (`game_screen.dart`)
- `CustomPaint` for 2D canvas
- Efficient dirty-rect updates (Flutter handles this)
- Grid background for spatial reference
- Real-time tower range visualization

### State Management
- Stateful widget with `Ticker` for game loop
- Local state for selected tower & UI interactions
- No external dependencies (lightweight footprint)

## 📱 Mobile Optimization

- **Resolution Agnostic**: Adapts to any screen size
- **Touch-Friendly**: Large tap targets (towers 24px radius)
- **Performance**: 60 FPS target on M2 macOS, optimized for Android
- **Memory**: Entities pruned each frame, no memory leaks

## 🌍 Localization

Supports **English** and **Spanish** with runtime language switching.

Strings are defined in `lib/localization/app_localizations.dart`.

## 🔧 Development Tips

### Adding a New Tower Type

1. Add to `TowerType` enum in `tower.dart`
2. Update `Tower.color` getter
3. Adjust starting stats (fireRate, damage, range)
4. Update localization strings

### Adjusting Game Difficulty

Edit `game_engine.dart`:
- `enemiesInWave`: Base enemies per wave
- `spawnInterval`: Time between spawns
- `Enemy.health`: Starting enemy HP
- Wave scaling formulas

### Changing Visuals

Edit `game_screen.dart` `GamePainter`:
- Colors in `_drawTower()`, `_drawEnemy()`, `_drawProjectile()`
- Gradients and effects in `paint()`
- Grid size and spacing

## 📊 Performance Metrics

- **Build Size**: ~42 MB (Flutter + Dart runtime)
- **RAM Usage**: ~100-150 MB on device
- **FPS**: 60 on M2 macOS, 45-60 on modern Android
- **Compile Time**: ~30-60 seconds (first build)

## 🐛 Known Limitations

- No audio playback (UI sliders present for future integration)
- No particle effects (kept minimal for performance)
- Fixed tower positions (can be extended for placement)
- No save/load system (resets on app restart)

## 🚀 Future Enhancements

- Tower placement system (drag & drop)
- Particle effects & animations
- Sound effects & background music
- Save/load progression
- Additional tower types & abilities
- Leaderboard (local or cloud)
- Campaign mode with multiple maps

## 📄 License

Open source. Use as you wish.

## 🤝 Contributing

Feel free to fork and extend with:
- New tower types
- Advanced AI paths
- Cosmetic upgrades
- Difficulty settings
- Custom maps

Enjoy! 🎮

