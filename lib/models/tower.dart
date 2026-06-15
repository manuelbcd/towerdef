import 'package:flutter/material.dart';

enum TowerType { archer, magic, cannon }

class Tower {
  final String id;
  final TowerType type;
  final Offset position;

  double fireRate; // shots per second
  double damage;
  double range;
  int upgrades;

  double timeSinceLastShot = 0;

  Tower({
    required this.id,
    required this.type,
    required this.position,
    required this.fireRate,
    required this.damage,
    required this.range,
    this.upgrades = 0,
  });

  factory Tower.create({
    required String id,
    required TowerType type,
    required Offset position,
  }) {
    switch (type) {
      case TowerType.archer:
        return Tower(
          id: id,
          type: type,
          position: position,
          fireRate: 1.4,
          damage: 9.0,
          range: 120.0,
        );
      case TowerType.magic:
        return Tower(
          id: id,
          type: type,
          position: position,
          fireRate: 1.0,
          damage: 12.0,
          range: 100.0,
        );
      case TowerType.cannon:
        return Tower(
          id: id,
          type: type,
          position: position,
          fireRate: 0.7,
          damage: 18.0,
          range: 90.0,
        );
    }
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
    }
  }

  Color get color {
    switch (type) {
      case TowerType.archer:
        return Colors.green;
      case TowerType.magic:
        return Colors.purple;
      case TowerType.cannon:
        return Colors.red;
    }
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
    }
  }

  int get upgradeCost => 150 + (upgrades * 50);

  bool canUpgrade() => upgrades < 3;
}
