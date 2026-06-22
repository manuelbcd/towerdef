import 'package:flutter/material.dart';

enum TowerType { archer, magic, cannon, slowerer }

enum EnemyType { goblin, runner, brute }

enum MovementPattern { straight, stepStopStep }

enum GameStage { placement, play }

const towerRangeMultiplier = 1.25;

class TowerConfig {
  final int placementCost;
  final double shotsPerSecond;
  final double damage;
  final double range;
  final double blastRadius;
  final double slowMultiplier;
  final double slowDuration;
  final double damagePerTick;
  final int damageTickCount;
  final double damageTickInterval;
  final Color color;

  const TowerConfig({
    required this.placementCost,
    required this.shotsPerSecond,
    required this.damage,
    required this.range,
    required this.blastRadius,
    this.slowMultiplier = 1,
    this.slowDuration = 0,
    this.damagePerTick = 0,
    this.damageTickCount = 0,
    this.damageTickInterval = 1,
    required this.color,
  });
}

class EnemyConfig {
  final double speed;
  final double health;
  final MovementPattern movementPattern;

  const EnemyConfig({
    required this.speed,
    required this.health,
    required this.movementPattern,
  });
}

const towerConfigs = <TowerType, TowerConfig>{
  TowerType.archer: TowerConfig(
    placementCost: 100,
    shotsPerSecond: 1.4,
    damage: 9.0,
    range: 155.0 * towerRangeMultiplier,
    blastRadius: 0.0,
    color: Colors.green,
  ),
  TowerType.magic: TowerConfig(
    placementCost: 200,
    shotsPerSecond: 1.0,
    damage: 2.0,
    range: 135.0 * towerRangeMultiplier,
    blastRadius: 28.0,
    damagePerTick: 5.0,
    damageTickCount: 4,
    damageTickInterval: 1.0,
    color: Colors.purple,
  ),
  TowerType.cannon: TowerConfig(
    placementCost: 250,
    shotsPerSecond: 0.7,
    damage: 18.0,
    range: 125.0 * towerRangeMultiplier,
    blastRadius: 42.0,
    color: Colors.red,
  ),
  TowerType.slowerer: TowerConfig(
    placementCost: 150,
    shotsPerSecond: 0.85,
    damage: 2.0,
    range: 150.0 * towerRangeMultiplier,
    blastRadius: 0.0,
    slowMultiplier: 1 / 3,
    slowDuration: 3.0,
    color: Colors.cyan,
  ),
};

const enemyConfigs = <EnemyType, EnemyConfig>{
  EnemyType.goblin: EnemyConfig(
    speed: 58,
    health: 20,
    movementPattern: MovementPattern.straight,
  ),
  EnemyType.runner: EnemyConfig(
    speed: 86,
    health: 14,
    movementPattern: MovementPattern.stepStopStep,
  ),
  EnemyType.brute: EnemyConfig(
    speed: 38,
    health: 44,
    movementPattern: MovementPattern.straight,
  ),
};
