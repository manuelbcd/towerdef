import 'dart:math' as math;

import 'package:flutter/material.dart';
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
  double slowMultiplier = 1;
  double slowTimeRemaining = 0;
  double magicDamagePerTick = 0;
  int magicTicksRemaining = 0;
  double magicTickInterval = 1;
  double magicTickClock = 0;
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
  }) {
    final config = enemyConfigs[type]!;
    return Enemy(
      id: id,
      type: type,
      path: path,
      position: path.first,
      speed: speed ?? config.speed,
      movementPattern: movementPattern ?? config.movementPattern,
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

  bool get isSlowed => slowTimeRemaining > 0;

  double get effectiveSpeed => speed * (isSlowed ? slowMultiplier : 1);

  void applySlow({required double multiplier, required double duration}) {
    slowMultiplier = isSlowed
        ? math.min(slowMultiplier, multiplier.clamp(0.05, 1.0))
        : multiplier.clamp(0.05, 1.0);
    slowTimeRemaining = math.max(slowTimeRemaining, duration);
  }

  bool get isUnderMagicEffect => magicTicksRemaining > 0;

  void applyMagicDamage({
    required double damagePerTick,
    required int tickCount,
    required double tickInterval,
  }) {
    if (damagePerTick <= 0 || tickCount <= 0 || tickInterval <= 0) return;

    final wasActive = isUnderMagicEffect;
    magicDamagePerTick =
        wasActive ? math.max(magicDamagePerTick, damagePerTick) : damagePerTick;
    magicTicksRemaining = math.max(magicTicksRemaining, tickCount);
    magicTickInterval =
        wasActive ? math.min(magicTickInterval, tickInterval) : tickInterval;
  }

  double consumeMagicDamage(double deltaTime) {
    if (!isUnderMagicEffect) return 0;

    magicTickClock += deltaTime;
    var ticks = 0;
    while (magicTickClock >= magicTickInterval && magicTicksRemaining > 0) {
      magicTickClock -= magicTickInterval;
      magicTicksRemaining--;
      ticks++;
    }

    final damage = ticks * magicDamagePerTick;
    if (!isUnderMagicEffect) {
      magicTickClock = 0;
      magicDamagePerTick = 0;
      magicTickInterval = 1;
    }
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

    slowTimeRemaining = math.max(0, slowTimeRemaining - deltaTime);
    if (!isSlowed) slowMultiplier = 1;
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
