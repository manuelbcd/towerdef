import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tower.dart';
import '../models/enemy.dart';
import '../models/projectile.dart';

class GameEngine {
  final Size screenSize;

  List<Tower> towers = [];
  List<Enemy> enemies = [];
  List<Projectile> projectiles = [];

  int coins = 500;
  int kills = 0;
  int wave = 1;
  int enemiesSpawned = 0;
  int enemiesInWave = 5;
  double waveTimer = 0;
  double spawnInterval = 1.0;
  double timeSinceLastSpawn = 0;

  bool isGameOver = false;
  int health = 20;

  GameEngine({required this.screenSize}) {
    _initializeTowers();
  }

  void _initializeTowers() {
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    towers.add(Tower.create(
      id: 'archer_1',
      type: TowerType.archer,
      position: Offset(centerX - 100, centerY),
    ));

    towers.add(Tower.create(
      id: 'magic_1',
      type: TowerType.magic,
      position: Offset(centerX, centerY),
    ));

    towers.add(Tower.create(
      id: 'cannon_1',
      type: TowerType.cannon,
      position: Offset(centerX + 100, centerY),
    ));
  }

  void update(double deltaTime) {
    if (isGameOver) return;

    // Spawn enemies
    waveTimer += deltaTime;
    timeSinceLastSpawn += deltaTime;

    if (enemiesSpawned < enemiesInWave) {
      if (timeSinceLastSpawn >= spawnInterval) {
        _spawnEnemy();
        timeSinceLastSpawn = 0;
      }
    }

    // Update towers
    for (final tower in towers) {
      if (tower.canShoot(deltaTime)) {
        final target = _findTarget(tower);
        if (target != null) {
          _shootAt(tower, target);
        }
      }
    }

    // Update projectiles
    projectiles.removeWhere((p) => p.hasHit || p.isOffScreen(screenSize));
    for (final projectile in projectiles) {
      projectile.update(deltaTime);

      // Check hit
      for (final enemy in enemies) {
        if (!enemy.isDead) {
          final dist = (projectile.position - enemy.position).distance;
          if (dist < projectile.radius + enemy.radius) {
            enemy.takeDamage(projectile.damage);
            projectile.hasHit = true;

            if (enemy.isDead) {
              kills++;
              coins += 25;
            }
            break;
          }
        }
      }
    }

    // Update enemies
    for (final enemy in enemies) {
      enemy.update(deltaTime);

      if (enemy.isOffScreen(screenSize)) {
        enemy.isDead = true;
        health--;
        if (health <= 0) {
          isGameOver = true;
        }
      }
    }

    enemies.removeWhere((e) => e.isDead);

    // Next wave
    if (enemiesSpawned >= enemiesInWave && enemies.isEmpty) {
      wave++;
      enemiesSpawned = 0;
      enemiesInWave = (5 + wave * 2).toInt();
      spawnInterval = math.max(0.3, 1.0 - (wave * 0.1));
    }
  }

  void _spawnEnemy() {
    final random = math.Random();
    final side = random.nextInt(4);

    late Offset startPos;
    late Offset velocity;

    switch (side) {
      case 0: // top
        startPos = Offset(random.nextDouble() * screenSize.width, -20);
        velocity = Offset(0, 60);
        break;
      case 1: // right
        startPos = Offset(screenSize.width + 20, random.nextDouble() * screenSize.height);
        velocity = Offset(-60, 0);
        break;
      case 2: // bottom
        startPos = Offset(random.nextDouble() * screenSize.width, screenSize.height + 20);
        velocity = Offset(0, -60);
        break;
      case 3: // left
        startPos = Offset(-20, random.nextDouble() * screenSize.height);
        velocity = Offset(60, 0);
        break;
    }

    enemies.add(Enemy(
      id: 'enemy_${DateTime.now().millisecondsSinceEpoch}',
      position: startPos,
      velocity: velocity,
      health: 20 + (wave * 3).toDouble(),
    ));

    enemiesSpawned++;
  }

  Enemy? _findTarget(Tower tower) {
    Enemy? closestEnemy;
    double closestDist = tower.range;

    for (final enemy in enemies) {
      if (!enemy.isDead) {
        final dist = (tower.position - enemy.position).distance;
        if (dist < closestDist) {
          closestDist = dist;
          closestEnemy = enemy;
        }
      }
    }

    return closestEnemy;
  }

  void _shootAt(Tower tower, Enemy target) {
    projectiles.add(Projectile(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      source: tower.position,
      position: tower.position,
      targetPosition: target.position,
      speed: 200,
      damage: tower.damage,
    ));
  }

  bool upgradeTower(Tower tower) {
    if (tower.canUpgrade() && coins >= tower.upgradeCost) {
      coins -= tower.upgradeCost;
      tower.upgrade();
      return true;
    }
    return false;
  }
}
