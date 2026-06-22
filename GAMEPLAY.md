# Gameplay Guide

## Basic Game Mechanics

### How to Play

1. **Placement Stage**: Choose Archer, Magic, or Cannon in the placement panel.
2. **Place Towers**: Tap highlighted placeholders on the map. Each map currently has 5 tower slots.
3. **Start Play**: Press Start Play to begin the configured wave sequence.
4. **Upgrade Tower**: During play, tap a placed tower and use the Upgrade button to spend coins and improve it.
5. **Eliminate Enemies**: Your towers automatically shoot enemies that enter their range.
6. **Earn Coins**: Each enemy killed drops 25 coins.
7. **Survive Waves**: Keep your life points above 0 by preventing enemies from reaching the end-line.

---

## Tower Types

### Archer Tower (Green)
- **Starting Damage**: 10
- **Starting Range**: 155
- **Starting Fire Rate**: 1.4 shots/sec
- **Description**: Fast-firing with long range.

### Magic Tower (Purple)
- **Starting Damage**: 12
- **Starting Range**: 135
- **Starting Fire Rate**: 1.0 shots/sec
- **Blast Radius**: 28
- **Description**: Balanced magical splash damage.

### Cannon Tower (Red)
- **Starting Damage**: 18
- **Starting Range**: 125
- **Starting Fire Rate**: 0.7 shots/sec
- **Blast Radius**: 42
- **Description**: High burst damage per shot.

---

## Upgrades

Each tower can be upgraded up to **3 times** during gameplay.

### Per Upgrade Level:
- **Damage**: +5
- **Range**: +15
- **Fire Rate**: +0.3

### Upgrade Costs:
- **Level 1**: 150 coins
- **Level 2**: 200 coins
- **Level 3**: 250 coins

---

## Game Progression

### Waves
- Waves are configured in `lib/models/game_map.dart`.
- Each `WaveConfig` defines its spawn interval and one or more enemy groups.
- Each enemy group defines enemy type, count, health, speed, and movement pattern.
- Maps can share `standardMapWaves` or provide their own custom wave list.

### Enemy Spawning
- Enemies spawn from the map start-line.
- Enemies follow the configured curved map path.
- Enemy movement can be straight or step-stop-step.

### Losing
- If an enemy reaches the map end-line, you lose 1 life point.
- Game over when health reaches 0.

---

## Strategy Tips

1. **Early Upgrades**: Save coins to upgrade a single tower quickly for maximum coverage.
2. **Tower Positioning**: Use placement-stage range previews to cover as much of the path as possible.
3. **Priority**: Upgrade the tower with the best range coverage first.
4. **Chain Reactions**: Overlapping tower ranges create a more effective defense.

---

## UI Overview

### Top HUD
- 💰 **Coins**: Current currency
- ❤️ **Health**: Remaining lives (starts at 20)
- **Wave**: Current wave number
- **Kills**: Total enemies eliminated

### Tower Control Panel
When a tower is selected:
- Shows tower type and stats (Damage, Range, Fire Rate)
- Displays upgrade level (X/3)
- Upgrade button with cost (if not max level)

### Game Over
Shows final wave reached and total kills. Press "Play Again" to restart.

---

## Technical Details

### Rendering
- 2D canvas-based rendering for lightweight performance.
- Grid background for spatial reference.
- Tower ranges shown with transparent circles, including placement-stage range previews.
- Health bars for enemies.

### Physics
- Enemies follow sampled map paths from start-line to end-line.
- Projectiles travel at 200 pixels/second.
- Simple distance-based collision detection.

### Performance
- Delta-time based game loop (updates per frame).
- Efficient memory management (dead entities removed).
- Optimized for mobile devices.
