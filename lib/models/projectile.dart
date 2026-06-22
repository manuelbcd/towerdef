import 'package:flutter/material.dart';
import 'game_config.dart';

class Projectile {
  final String id;
  final String targetEnemyId;
  final Offset source;
  Offset position;
  Offset targetPosition;
  final double speed;
  final double damage;
  final double blastRadius;
  final TowerType? sourceTowerType;
  final double slowMultiplier;
  final double slowDuration;
  final double damagePerTick;
  final int damageTickCount;
  final double damageTickInterval;
  bool hasHit = false;
  bool reachedTargetPosition = false;

  Projectile({
    required this.id,
    required this.targetEnemyId,
    required this.source,
    required this.position,
    required this.targetPosition,
    required this.speed,
    required this.damage,
    this.blastRadius = 0,
    this.sourceTowerType,
    this.slowMultiplier = 1,
    this.slowDuration = 0,
    this.damagePerTick = 0,
    this.damageTickCount = 0,
    this.damageTickInterval = 1,
  });

  double get radius => 4.0;

  Color get color {
    switch (sourceTowerType) {
      case TowerType.magic:
        return Colors.purpleAccent;
      case TowerType.cannon:
        return Colors.deepOrangeAccent;
      case TowerType.slowerer:
        return Colors.cyanAccent;
      case TowerType.archer:
      case null:
        return Colors.amber;
    }
  }

  void update(double deltaTime) {
    reachedTargetPosition = false;
    final direction = (targetPosition - position);
    final distance = direction.distance;

    if (distance <= speed * deltaTime || distance == 0) {
      position = targetPosition;
      reachedTargetPosition = true;
      return;
    }

    final normalized = direction / distance;
    position = position.translate(
      normalized.dx * speed * deltaTime,
      normalized.dy * speed * deltaTime,
    );
  }

  bool isOffScreen(Size screenSize) {
    return position.dx < -50 ||
        position.dx > screenSize.width + 50 ||
        position.dy < -50 ||
        position.dy > screenSize.height + 50;
  }
}
