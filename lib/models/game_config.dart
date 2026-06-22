import 'package:flutter/material.dart';

enum TowerType { archer, magic, cannon }

enum EnemyType { goblin, runner, brute }

enum MovementPattern { straight, stepStopStep }

enum GameStage { placement, play }

class TowerConfig {
  final double shotsPerSecond;
  final double damage;
  final double range;
  final double blastRadius;
  final Color color;

  const TowerConfig({
    required this.shotsPerSecond,
    required this.damage,
    required this.range,
    required this.blastRadius,
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
    shotsPerSecond: 1.4,
    damage: 9.0,
    range: 155.0,
    blastRadius: 0.0,
    color: Colors.green,
  ),
  TowerType.magic: TowerConfig(
    shotsPerSecond: 1.0,
    damage: 12.0,
    range: 135.0,
    blastRadius: 28.0,
    color: Colors.purple,
  ),
  TowerType.cannon: TowerConfig(
    shotsPerSecond: 0.7,
    damage: 18.0,
    range: 125.0,
    blastRadius: 42.0,
    color: Colors.red,
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
