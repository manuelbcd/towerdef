import 'package:flutter/material.dart';
import '../models/tower.dart';
import '../models/enemy.dart';
import '../models/game_config.dart';
import '../models/projectile.dart';
import '../models/game_map.dart';
import '../models/blast_effect.dart';

class GameEngine {
  final Size screenSize;
  final int mapIndex;
  late final GameMap map;
  late final List<Offset> path;
  late final List<Offset> towerSlots;
  GameStage stage = GameStage.placement;

  List<Tower> towers = [];
  List<Enemy> enemies = [];
  List<Projectile> projectiles = [];
  List<BlastEffect> blastEffects = [];

  int coins = 500;
  int kills = 0;
  int wave = 1;
  int enemiesSpawned = 0;
  double waveTimer = 0;
  double timeSinceLastSpawn = 0;
  final List<WaveEnemyGroup> _spawnQueue = [];

  bool isGameOver = false;
  bool isVictory = false;
  int playerLifePoints = 20;

  GameEngine({required this.screenSize, this.mapIndex = 0}) {
    map = gameMaps[mapIndex % gameMaps.length];
    path = map.scaledPath(screenSize);
    towerSlots = map.scaledTowerSlots(screenSize);
  }

  int get health => playerLifePoints;
  int get nextMapIndex => (mapIndex + 1) % gameMaps.length;
  int get totalWaves => map.waves.length;
  WaveConfig get currentWaveConfig => map.waves[wave - 1];
  int get enemiesInWave => currentWaveConfig.totalEnemies;
  double get spawnInterval => currentWaveConfig.spawnInterval;

  bool get isPlacementStage => stage == GameStage.placement;
  bool get isPlayStage => stage == GameStage.play;

  void startPlay() {
    stage = GameStage.play;
    _prepareWaveSpawnQueue();
  }

  bool placeTowerAtSlot(int slotIndex, TowerType type) {
    if (isGameOver ||
        isVictory ||
        slotIndex < 0 ||
        slotIndex >= towerSlots.length) {
      return false;
    }

    final slotPosition = towerSlots[slotIndex];
    if (towerAtSlot(slotIndex) != null) return false;

    final cost = towerConfigs[type]!.placementCost;
    if (coins < cost) return false;

    coins -= cost;
    towers.add(Tower.create(
      id: '${type.name}_slot_$slotIndex',
      type: type,
      position: slotPosition,
    ));
    return true;
  }

  int? slotIndexAt(Offset position, {double radius = 24}) {
    for (var i = 0; i < towerSlots.length; i++) {
      if ((towerSlots[i] - position).distance <= radius) {
        return i;
      }
    }
    return null;
  }

  Tower? towerAtSlot(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= towerSlots.length) return null;
    final slotPosition = towerSlots[slotIndex];
    for (final tower in towers) {
      if (tower.position == slotPosition) return tower;
    }
    return null;
  }

  bool removeTower(Tower tower) {
    if (!isPlacementStage) return false;
    final removed = towers.remove(tower);
    if (removed) {
      coins += towerConfigs[tower.type]!.placementCost;
    }
    return removed;
  }

  Enemy? enemyAt(Offset position, {double tapPadding = 12}) {
    if (!isPlayStage) return null;

    for (final enemy in enemies.reversed) {
      if (!enemy.isDead &&
          (enemy.position - position).distance <= enemy.radius + tapPadding) {
        return enemy;
      }
    }
    return null;
  }

  void update(double deltaTime) {
    for (final effect in blastEffects) {
      effect.update(deltaTime);
    }
    blastEffects.removeWhere((effect) => effect.isFinished);

    if (isGameOver || isVictory) return;
    if (!isPlayStage) return;

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
      final trackedEnemy = _enemyById(projectile.targetEnemyId);
      if (trackedEnemy != null && !trackedEnemy.isDead) {
        projectile.targetPosition = trackedEnemy.position;
      }

      projectile.update(deltaTime);

      // Check hit
      var didApplyDamage = false;
      for (final enemy in enemies) {
        if (!enemy.isDead) {
          final dist = (projectile.position - enemy.position).distance;
          if (dist < projectile.radius + enemy.radius) {
            _applyProjectileDamage(projectile, enemy);
            projectile.hasHit = true;
            didApplyDamage = true;
            break;
          }
        }
      }

      if (!didApplyDamage && projectile.reachedTargetPosition) {
        projectile.hasHit = true;
      }
    }

    // Update enemies
    for (final enemy in enemies) {
      final magicDamage = enemy.consumeMagicDamage(deltaTime);
      if (magicDamage > 0) {
        _damageEnemy(enemy, magicDamage);
      }
      if (enemy.isDead) continue;

      enemy.update(deltaTime);

      if (enemy.reachedEndLine) {
        playerLifePoints--;
        if (playerLifePoints <= 0) {
          isGameOver = true;
        }
      }
    }

    enemies.removeWhere((e) => e.isDead);

    // Next wave
    if (enemiesSpawned >= enemiesInWave && enemies.isEmpty) {
      if (wave >= totalWaves) {
        isVictory = true;
        return;
      }
      wave++;
      enemiesSpawned = 0;
      timeSinceLastSpawn = 0;
      _prepareWaveSpawnQueue();
    }
  }

  void _spawnEnemy() {
    if (_spawnQueue.isEmpty) return;
    final group = _spawnQueue.removeAt(0);
    enemies.add(Enemy.spawn(
      id: 'enemy_${DateTime.now().millisecondsSinceEpoch}',
      type: group.type,
      path: path,
      health: group.health,
      speed: group.speed,
      movementPattern: group.movementPattern,
    ));

    enemiesSpawned++;
  }

  void _prepareWaveSpawnQueue() {
    _spawnQueue
      ..clear()
      ..addAll(_expandWave(currentWaveConfig));
  }

  List<WaveEnemyGroup> _expandWave(WaveConfig waveConfig) {
    final expanded = <WaveEnemyGroup>[];
    for (final group in waveConfig.enemyGroups) {
      for (var i = 0; i < group.count; i++) {
        expanded.add(group);
      }
    }
    return expanded;
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

  Enemy? _enemyById(String id) {
    for (final enemy in enemies) {
      if (enemy.id == id) return enemy;
    }
    return null;
  }

  void _shootAt(Tower tower, Enemy target) {
    final config = towerConfigs[tower.type]!;
    projectiles.add(Projectile(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      targetEnemyId: target.id,
      source: tower.position,
      position: tower.position,
      targetPosition: target.position,
      speed: tower.type == TowerType.slowerer ? 520 : 200,
      damage: tower.damage,
      blastRadius: tower.blastRadius,
      sourceTowerType: tower.type,
      slowMultiplier: config.slowMultiplier,
      slowDuration: config.slowDuration,
      damagePerTick: config.damagePerTick,
      damageTickCount: config.damageTickCount,
      damageTickInterval: config.damageTickInterval,
    ));
  }

  void _applyProjectileDamage(Projectile projectile, Enemy directHit) {
    if (projectile.blastRadius <= 0) {
      _applyProjectileStatus(projectile, directHit);
      _damageEnemy(directHit, projectile.damage);
      return;
    }

    if (projectile.sourceTowerType == TowerType.cannon) {
      blastEffects.add(BlastEffect(
        position: directHit.position,
        radius: projectile.blastRadius,
      ));
    }

    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final distance = (enemy.position - directHit.position).distance;
      if (distance <= projectile.blastRadius + enemy.radius) {
        _applyProjectileStatus(projectile, enemy);
        _damageEnemy(enemy, projectile.damage);
      }
    }
  }

  void _applyProjectileStatus(Projectile projectile, Enemy enemy) {
    if (projectile.slowMultiplier < 1 && projectile.slowDuration > 0) {
      enemy.applySlow(
        multiplier: projectile.slowMultiplier,
        duration: projectile.slowDuration,
      );
    }
    if (projectile.damagePerTick > 0 && projectile.damageTickCount > 0) {
      enemy.applyMagicDamage(
        damagePerTick: projectile.damagePerTick,
        tickCount: projectile.damageTickCount,
        tickInterval: projectile.damageTickInterval,
      );
    }
  }

  void _damageEnemy(Enemy enemy, double damage) {
    final wasAlive = !enemy.isDead;
    enemy.takeDamage(damage);
    if (wasAlive && enemy.isDead) {
      kills++;
      coins += 25;
    }
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
