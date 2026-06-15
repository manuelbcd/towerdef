import 'package:flutter/material.dart';

class Projectile {
  final String id;
  final Offset source;
  Offset position;
  final Offset targetPosition;
  final double speed;
  final double damage;
  bool hasHit = false;

  Projectile({
    required this.id,
    required this.source,
    required this.position,
    required this.targetPosition,
    required this.speed,
    required this.damage,
  });

  double get radius => 4.0;

  Color get color => Colors.amber;

  void update(double deltaTime) {
    final direction = (targetPosition - position);
    final distance = direction.distance;

    if (distance < speed * deltaTime) {
      hasHit = true;
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
