# TODO

## Gameplay QA

- [x] Investigate why some enemies do not appear to receive damage.
  - Symptom: their life bar does not go down.
  - Check projectile collision, splash damage, enemy path position, and health bar redraw timing.
  - Finding: projectiles could expire when they reached the enemy's old target point before collision damage was applied.
  - Fixed by letting projectiles track their target enemy and only marking a hit after collision/damage.

- [ ] Decide what other QA tests we can add.
  - Candidate areas: path following, end-line life loss, tower targeting, blast radius damage, movement patterns, map switching, and stage transitions.
  - Added regression coverage for projectile target-point expiry, moving-enemy tracking, tower/enemy damage combinations, and blast-radius damage.

## Gameplay Systems

- [x] Allow the player to place towers at the beginning.
  - Implement stages: placement stage and play stage.
  - During placement, enemies should not spawn yet.
  - During play, tower placement remains available on empty slots when the
    player has enough earned gold.
  - Added `GameStage.placement` and `GameStage.play`.
  - Maps now define 7 tower placeholders each.
  - The player selects a tower type, taps a placeholder to place it, then starts
    play and can expand the defense during combat.

## Frameworkization

- [x] Separate immutable content definitions from runtime tower/enemy state and
      use unified tower and enemy catalogs across gameplay and marketplace UI.
- [x] Replace tower-specific projectile fields with composable attack and
      status-effect definitions, including generic periodic damage and stat
      modifiers with explicit stacking policies.
- [x] Model maps as collections of named routes and let wave groups select a
      route explicitly or use deterministic weighted route distribution.
- [ ] Split `GameEngine` into focused wave, movement, targeting, combat,
      economy, placement, and victory systems.
- [ ] Add enemy stat-resolution layers for map, wave, difficulty, and affix
      modifiers instead of repeating resolved values in every wave group.
- [ ] Add tower mastery tiers, upgrade trees, modules, and a resolved-stat
      pipeline for persistent player progression.
- [x] Add versioned campaign progress and a persistence boundary backed by
      shared preferences, with an in-memory implementation for tests.
- [ ] Move map/tower/enemy content behind loadable repositories with schema
      validation and future JSON support.
- [ ] Separate simulation/world coordinates from Flutter screen coordinates.
- [ ] Split rendering, HUD, input, and inspectors out of `GameScreen`.

## Campaign Experience

- [x] Add a validated `GameContentIndex` for maps, encounters, rulesets,
      stages, campaigns, towers, and enemies.
- [x] Extract reusable encounters from map geometry.
- [x] Define a five-stage campaign split across two chapters.
- [x] Resolve stage references into a complete game-session configuration.
- [x] Add campaign selection, stage briefing, active battle, results, rewards,
      unlock progression, and next-stage navigation.
- [ ] Add story and reward-only stage presentation for non-battle stage kinds.
- [ ] Add multiple campaigns and campaign selection before the chapter map.
