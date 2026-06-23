import 'package:flutter/material.dart';
import 'combat.dart';

class Projectile {
  final String id;
  final String targetEnemyId;
  final Offset source;
  Offset position;
  Offset targetPosition;
  final AttackDefinition attack;
  bool hasHit = false;
  bool reachedTargetPosition = false;

  Projectile({
    required this.id,
    required this.targetEnemyId,
    required this.source,
    required this.position,
    required this.targetPosition,
    required this.attack,
  });

  double get radius => 4.0;

  Color get color {
    switch (attack.visualId) {
      case 'magic_orb':
        return Colors.purpleAccent;
      case 'cannon_shell':
        return Colors.deepOrangeAccent;
      case 'slowing_ray':
        return Colors.cyanAccent;
      default:
        return Colors.amber;
    }
  }

  void update(double deltaTime) {
    reachedTargetPosition = false;
    final direction = (targetPosition - position);
    final distance = direction.distance;

    if (distance <= attack.projectileSpeed * deltaTime || distance == 0) {
      position = targetPosition;
      reachedTargetPosition = true;
      return;
    }

    final normalized = direction / distance;
    position = position.translate(
      normalized.dx * attack.projectileSpeed * deltaTime,
      normalized.dy * attack.projectileSpeed * deltaTime,
    );
  }

  bool isOffScreen(Size screenSize) {
    return position.dx < -50 ||
        position.dx > screenSize.width + 50 ||
        position.dy < -50 ||
        position.dy > screenSize.height + 50;
  }
}
