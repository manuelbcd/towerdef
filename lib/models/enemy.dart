import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'combat.dart';
import 'game_config.dart';

class Enemy {
  final String id;
  final EnemyType type;
  final List<Offset> path;
  Offset position;
  double health;
  double maxHealth;
  double speed;
  MovementPattern movementPattern;
  double movementClock = 0;
  final List<ActiveStatusEffect> statusEffects = [];
  final String routeId;
  int pathIndex;
  bool isDead = false;
  bool reachedEndLine = false;

  Enemy({
    required this.id,
    required this.type,
    required this.path,
    required this.position,
    required this.speed,
    required this.movementPattern,
    this.routeId = 'main',
    this.pathIndex = 1,
    this.health = 20.0,
  }) : maxHealth = health;

  factory Enemy.spawn({
    required String id,
    required EnemyType type,
    required List<Offset> path,
    double? health,
    double? speed,
    MovementPattern? movementPattern,
    String routeId = 'main',
  }) {
    final config = enemyCatalog[type]!;
    return Enemy(
      id: id,
      type: type,
      path: path,
      position: path.first,
      speed: speed ?? config.speed,
      movementPattern: movementPattern ?? config.movementPattern,
      routeId: routeId,
      health: health ?? config.health,
    );
  }

  double get radius {
    switch (type) {
      case EnemyType.goblin:
        return 9.0;
      case EnemyType.runner:
        return 7.5;
      case EnemyType.brute:
        return 12.0;
    }
  }

  Color get color {
    final healthPercent = health / maxHealth;
    if (healthPercent <= 0.33) return Colors.yellow.shade600;
    switch (type) {
      case EnemyType.goblin:
        return Colors.green.shade600;
      case EnemyType.runner:
        return Colors.lime.shade400;
      case EnemyType.brute:
        return Colors.brown.shade600;
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      isDead = true;
    }
  }

  bool get isSlowed => statusEffects.any(
        (effect) =>
            effect.definition is StatModifierEffectDefinition &&
            effect.speedMultiplier < 1,
      );

  double get effectiveSpeed {
    final multiplier = statusEffects.fold<double>(
      1,
      (value, effect) => math.min(value, effect.speedMultiplier),
    );
    return speed * multiplier;
  }

  bool hasStatus(String id) {
    return statusEffects.any((effect) => effect.definition.id == id);
  }

  bool get isUnderMagicEffect => hasStatus('purple_curse');

  void applyStatus(StatusEffectDefinition definition) {
    for (final active in statusEffects) {
      if (active.definition.id == definition.id) {
        active.merge(definition);
        return;
      }
    }
    statusEffects.add(ActiveStatusEffect(definition));
  }

  double updateStatusEffects(double deltaTime) {
    var damage = 0.0;
    for (final effect in statusEffects) {
      damage += effect.update(deltaTime);
    }
    statusEffects.removeWhere((effect) => effect.isFinished);
    return damage;
  }

  void update(double deltaTime) {
    movementClock += deltaTime;
    var distanceLeft = _distanceForPattern(deltaTime);
    while (distanceLeft > 0 && !isDead && !reachedEndLine) {
      if (pathIndex >= path.length) {
        reachedEndLine = true;
        isDead = true;
        return;
      }

      final target = path[pathIndex];
      final direction = target - position;
      final distance = direction.distance;

      if (distance <= distanceLeft || distance == 0) {
        position = target;
        pathIndex++;
        distanceLeft -= distance;
      } else {
        final normalized = direction / distance;
        position = position.translate(
          normalized.dx * distanceLeft,
          normalized.dy * distanceLeft,
        );
        distanceLeft = 0;
      }
    }
  }

  double _distanceForPattern(double deltaTime) {
    switch (movementPattern) {
      case MovementPattern.straight:
        return effectiveSpeed * deltaTime;
      case MovementPattern.stepStopStep:
        final cyclePosition = movementClock % 0.72;
        if (cyclePosition > 0.48) return 0;
        return effectiveSpeed * 1.18 * deltaTime;
    }
  }

  bool isOffScreen(Size screenSize) {
    return reachedEndLine ||
        position.dx < -80 ||
        position.dx > screenSize.width + 80 ||
        position.dy < -80 ||
        position.dy > screenSize.height + 80;
  }
}
