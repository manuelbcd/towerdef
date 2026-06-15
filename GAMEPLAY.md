# Gameplay Guide

## Basic Game Mechanics

### How to Play

1. **Start Game**: Press the START button from the Play screen to launch the game.
2. **Select Tower**: Tap any of the 3 towers on the board (Archer, Magic, or Cannon).
3. **Upgrade Tower**: With a tower selected, tap the Upgrade button to pay coins and improve it.
4. **Eliminate Enemies**: Your towers automatically shoot enemies that enter their range.
5. **Earn Coins**: Each enemy killed drops 25 coins.
6. **Survive Waves**: Keep your health above 0 by preventing enemies from escaping the screen.

---

## Tower Types

### Archer Tower (Green)
- **Starting Damage**: 10
- **Starting Range**: 100
- **Starting Fire Rate**: 1.0 shots/sec
- **Description**: Fast-firing with long range.

### Magic Tower (Purple)
- **Starting Damage**: 10
- **Starting Range**: 100
- **Starting Fire Rate**: 1.0 shots/sec
- **Description**: Deals area slow damage.

### Cannon Tower (Red)
- **Starting Damage**: 10
- **Starting Range**: 100
- **Starting Fire Rate**: 1.0 shots/sec
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
- Each wave spawns increasingly difficult enemies.
- **Wave 1**: 5 enemies (20 HP each)
- **Wave 2**: 9 enemies (23 HP each)
- **Wave 3**: 13 enemies (26 HP each)
- Enemy health increases by 3 per wave.

### Enemy Spawning
- Enemies spawn from the edges of the screen.
- Spawn rate increases as waves progress.
- Moving toward the center of the screen.

### Losing
- If an enemy escapes off-screen, you lose 1 health.
- Game over when health reaches 0.

---

## Strategy Tips

1. **Early Upgrades**: Save coins to upgrade a single tower quickly for maximum coverage.
2. **Tower Positioning**: Your 3 towers are already placed; focus on optimizing upgrades.
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
- Tower ranges shown with transparent circles.
- Health bars for enemies.

### Physics
- Enemies move in straight lines from spawn to off-screen.
- Projectiles travel at 200 pixels/second.
- Simple distance-based collision detection.

### Performance
- Delta-time based game loop (updates per frame).
- Efficient memory management (dead entities removed).
- Optimized for mobile devices.
