import 'package:flutter/material.dart';

class Enemy {
  final String id;
  Offset position;
  Offset velocity;
  double health;
  double maxHealth;
  bool isDead = false;

  Enemy({
    required this.id,
    required this.position,
    required this.velocity,
    this.health = 20.0,
  }) : maxHealth = health;

  double get radius => 8.0;

  Color get color {
    final healthPercent = health / maxHealth;
    if (healthPercent > 0.66) return Colors.red;
    if (healthPercent > 0.33) return Colors.orange;
    return Colors.yellow;
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      isDead = true;
    }
  }

  void update(double deltaTime) {
    position = position.translate(
      velocity.dx * deltaTime,
      velocity.dy * deltaTime,
    );
  }

  bool isOffScreen(Size screenSize) {
    return position.dx < -50 ||
        position.dx > screenSize.width + 50 ||
        position.dy < -50 ||
        position.dy > screenSize.height + 50;
  }
}
