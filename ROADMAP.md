# TowerDef Roadmap

This file documents the planned feature roadmap for TowerDef.

## Vision
Build a lightweight, multi-platform tower defense game with strong strategy, satisfying feedback, and persistent progression.

## Short-term roadmap
1. **Tower placement system**
   - Place towers on defined build slots before or during waves
   - Validate placement and prevent blocking enemy paths
   - Add UI for selecting tower types and build costs
2. **Particle effects & visual polish**
   - Add explosion and hit particles
   - Add tower attack muzzle flash and trail effects
   - Add damage popups, health bar animations, and impact feedback
3. **Sound effects**
   - Add shoot, hit, death, coin, and UI sounds
   - Wire `volume_controls` to actual audio playback
4. **Save/load progression**
   - Persist tower upgrades, coins, level progress, and settings
   - Use `shared_preferences` or local JSON file storage
5. **Multiple maps / levels**
   - Add at least 2 level layouts with different enemy paths
   - Add progression between maps and increasing challenge
6. **Enemy variety**
   - Introduce fast, armored, and flying enemy types
   - Add wave-specific enemy compositions and boss waves

## Medium-term roadmap
- Add tower abilities and special power-ups
- Add day/night or environment effects
- Add campaign mode with multiple difficulty tiers
- Add simple in-game statistics and achievements

## Notes for agents
- Primary app entry is `lib/main.dart`.
- Core game loop and rules are in `lib/game/game_engine.dart`.
- Gameplay rendering and user input are in `lib/screens/game_screen.dart`.
- Put all product-level roadmap changes in `ROADMAP.md` and update `CODEX.md` for short-term todos.
- Use `scripts/run_tests.sh`, `flutter analyze`, and `flutter test` to validate changes.
