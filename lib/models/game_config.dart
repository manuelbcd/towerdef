import 'package:flutter/material.dart';
import 'combat.dart';

enum TowerType { archer, magic, cannon, slowerer }

enum EnemyType { goblin, runner, brute }

enum MovementPattern { straight, stepStopStep }

enum GameStage { placement, play }

const towerRangeMultiplier = 1.25;

class TowerDefinition {
  final TowerType type;
  final String id;
  final String nameKey;
  final String descriptionKey;
  final IconData icon;
  final int placementCost;
  final double shotsPerSecond;
  final double range;
  final Color color;
  final AttackDefinition attack;

  const TowerDefinition({
    required this.type,
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.placementCost,
    required this.shotsPerSecond,
    required this.range,
    required this.color,
    required this.attack,
  });

  double get damage {
    return attack.effects
        .whereType<DirectDamageEffectDefinition>()
        .first
        .damage;
  }

  double get blastRadius => attack.areaRadius;

  PeriodicDamageEffectDefinition? get periodicDamage {
    for (final effect in attack.effects) {
      if (effect is PeriodicDamageEffectDefinition) return effect;
    }
    return null;
  }
}

class EnemyDefinition {
  final EnemyType type;
  final String id;
  final String nameKey;
  final String storyKey;
  final double speed;
  final double health;
  final MovementPattern movementPattern;

  const EnemyDefinition({
    required this.type,
    required this.id,
    required this.nameKey,
    required this.storyKey,
    required this.speed,
    required this.health,
    required this.movementPattern,
  });
}

const towerCatalog = <TowerType, TowerDefinition>{
  TowerType.archer: TowerDefinition(
    type: TowerType.archer,
    id: 'archer',
    nameKey: 'tower_archer',
    descriptionKey: 'tower_archer_desc',
    icon: Icons.gps_fixed,
    placementCost: 100,
    shotsPerSecond: 1.4,
    range: 155.0 * towerRangeMultiplier,
    color: Colors.green,
    attack: AttackDefinition(
      id: 'arrow_shot',
      delivery: AttackDelivery.projectile,
      projectileSpeed: 200,
      visualId: 'arrow',
      effects: [
        DirectDamageEffectDefinition(id: 'arrow_damage', damage: 9),
      ],
    ),
  ),
  TowerType.magic: TowerDefinition(
    type: TowerType.magic,
    id: 'magic',
    nameKey: 'tower_magic',
    descriptionKey: 'tower_magic_desc',
    icon: Icons.auto_fix_high,
    placementCost: 200,
    shotsPerSecond: 1.0,
    range: 135.0 * towerRangeMultiplier,
    color: Colors.purple,
    attack: AttackDefinition(
      id: 'purple_curse',
      delivery: AttackDelivery.projectile,
      projectileSpeed: 200,
      areaRadius: 28,
      visualId: 'magic_orb',
      effects: [
        DirectDamageEffectDefinition(id: 'magic_impact', damage: 2),
        PeriodicDamageEffectDefinition(
          id: 'purple_curse',
          damagePerTick: 5,
          tickCount: 4,
          tickInterval: 1,
        ),
      ],
    ),
  ),
  TowerType.cannon: TowerDefinition(
    type: TowerType.cannon,
    id: 'cannon',
    nameKey: 'tower_cannon',
    descriptionKey: 'tower_cannon_desc',
    icon: Icons.whatshot,
    placementCost: 250,
    shotsPerSecond: 0.7,
    range: 125.0 * towerRangeMultiplier,
    color: Colors.red,
    attack: AttackDefinition(
      id: 'cannon_shell',
      delivery: AttackDelivery.projectile,
      projectileSpeed: 200,
      areaRadius: 42,
      visualId: 'cannon_shell',
      impactVisualId: 'cannon_explosion',
      effects: [
        DirectDamageEffectDefinition(id: 'cannon_damage', damage: 18),
      ],
    ),
  ),
  TowerType.slowerer: TowerDefinition(
    type: TowerType.slowerer,
    id: 'slowerer',
    nameKey: 'tower_slowerer',
    descriptionKey: 'tower_slowerer_desc',
    icon: Icons.ac_unit,
    placementCost: 150,
    shotsPerSecond: 0.85,
    range: 150.0 * towerRangeMultiplier,
    color: Colors.cyan,
    attack: AttackDefinition(
      id: 'slowing_ray',
      delivery: AttackDelivery.beam,
      projectileSpeed: 520,
      visualId: 'slowing_ray',
      effects: [
        DirectDamageEffectDefinition(id: 'ray_damage', damage: 2),
        StatModifierEffectDefinition(
          id: 'slowed',
          duration: 3,
          speedMultiplier: 1 / 3,
          stackingPolicy: StatusStackingPolicy.strongest,
        ),
      ],
    ),
  ),
};

const enemyCatalog = <EnemyType, EnemyDefinition>{
  EnemyType.goblin: EnemyDefinition(
    type: EnemyType.goblin,
    id: 'goblin',
    nameKey: 'enemy_goblin_name',
    storyKey: 'enemy_goblin_story',
    speed: 58,
    health: 20,
    movementPattern: MovementPattern.straight,
  ),
  EnemyType.runner: EnemyDefinition(
    type: EnemyType.runner,
    id: 'runner',
    nameKey: 'enemy_runner_name',
    storyKey: 'enemy_runner_story',
    speed: 86,
    health: 14,
    movementPattern: MovementPattern.stepStopStep,
  ),
  EnemyType.brute: EnemyDefinition(
    type: EnemyType.brute,
    id: 'brute',
    nameKey: 'enemy_brute_name',
    storyKey: 'enemy_brute_story',
    speed: 38,
    health: 44,
    movementPattern: MovementPattern.straight,
  ),
};
