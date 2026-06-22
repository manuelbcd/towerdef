import 'package:flutter/material.dart';
import 'game_config.dart';

class Tower {
  final String id;
  final TowerType type;
  final Offset position;

  double fireRate; // shots per second
  double damage;
  double range;
  double blastRadius;
  int upgrades;

  double timeSinceLastShot = 0;

  Tower({
    required this.id,
    required this.type,
    required this.position,
    required this.fireRate,
    required this.damage,
    required this.range,
    required this.blastRadius,
    this.upgrades = 0,
  });

  factory Tower.create({
    required String id,
    required TowerType type,
    required Offset position,
  }) {
    final config = towerConfigs[type]!;
    return Tower(
      id: id,
      type: type,
      position: position,
      fireRate: config.shotsPerSecond,
      damage: config.damage,
      range: config.range,
      blastRadius: config.blastRadius,
    );
  }

  /// Localization key for the tower display name
  String get nameKey {
    switch (type) {
      case TowerType.archer:
        return 'tower_archer';
      case TowerType.magic:
        return 'tower_magic';
      case TowerType.cannon:
        return 'tower_cannon';
      case TowerType.slowerer:
        return 'tower_slowerer';
    }
  }

  /// Localization key for the tower description / ability text
  String get descKey {
    switch (type) {
      case TowerType.archer:
        return 'tower_archer_desc';
      case TowerType.magic:
        return 'tower_magic_desc';
      case TowerType.cannon:
        return 'tower_cannon_desc';
      case TowerType.slowerer:
        return 'tower_slowerer_desc';
    }
  }

  Color get color {
    return towerConfigs[type]!.color;
  }

  double get radius => 12.0;

  bool canShoot(double deltaTime) {
    timeSinceLastShot += deltaTime;
    final shootInterval = 1.0 / fireRate;
    if (timeSinceLastShot >= shootInterval) {
      timeSinceLastShot = 0;
      return true;
    }
    return false;
  }

  void upgrade() {
    if (upgrades < 3) {
      upgrades++;
      fireRate += 0.3;
      damage += 5.0;
      range += 15.0;
      if (blastRadius > 0) {
        blastRadius += 6.0;
      }
    }
  }

  int get upgradeCost => 150 + (upgrades * 50);

  bool canUpgrade() => upgrades < 3;
}
