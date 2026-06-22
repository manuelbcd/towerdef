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
  - During play, tower placement should be locked or limited by explicit rules.
  - Added `GameStage.placement` and `GameStage.play`.
  - Maps now define 5 tower placeholders each.
  - The player selects a tower type, taps a placeholder to place/replace it, then starts play.
