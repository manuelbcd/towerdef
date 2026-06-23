import 'package:flutter/material.dart';
import '../models/tower.dart';
import '../models/enemy.dart';
import '../models/game_config.dart';
import '../models/projectile.dart';
import '../models/game_map.dart';
import '../models/blast_effect.dart';
import '../models/combat.dart';
import '../models/campaign.dart';
import '../models/encounter.dart';

class GameEngine {
  final Size screenSize;
  final int mapIndex;
  final GameSessionConfig? session;
  late final GameMap map;
  late final EncounterDefinition encounter;
  late final List<Offset> path;
  late final Map<String, List<Offset>> pathsByRouteId;
  late final List<Offset> towerSlots;
  GameStage stage = GameStage.placement;

  List<Tower> towers = [];
  List<Enemy> enemies = [];
  List<Projectile> projectiles = [];
  List<BlastEffect> blastEffects = [];

  late int coins;
  int kills = 0;
  int wave = 1;
  int enemiesSpawned = 0;
  double waveTimer = 0;
  double timeSinceLastSpawn = 0;
  final List<WaveEnemyGroup> _spawnQueue = [];

  bool isGameOver = false;
  bool isVictory = false;
  late int playerLifePoints;

  GameEngine({
    required this.screenSize,
    this.mapIndex = 0,
    this.session,
  }) {
    map = session?.map ?? gameMaps[mapIndex % gameMaps.length];
    encounter = session?.encounter ?? introEncounter;
    coins = session?.rules.startingGold ?? 500;
    playerLifePoints = session?.rules.startingLives ?? 20;
    pathsByRouteId = map.scaledPaths(screenSize);
    path = pathsByRouteId.values.first;
    towerSlots = map.scaledTowerSlots(screenSize);
  }

  int get health => playerLifePoints;
  int get nextMapIndex => (mapIndex + 1) % gameMaps.length;
  int get totalWaves => encounter.waves.length;
  WaveConfig get currentWaveConfig => encounter.waves[wave - 1];
  int get enemiesInWave => currentWaveConfig.totalEnemies;
  double get spawnInterval => currentWaveConfig.spawnInterval;

  bool get isPlacementStage => stage == GameStage.placement;
  bool get isPlayStage => stage == GameStage.play;

  List<TowerType> get availableTowerTypes =>
      session?.rules.availableTowerTypes ?? TowerType.values;

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
    if (!availableTowerTypes.contains(type)) return false;

    final slotPosition = towerSlots[slotIndex];
    if (towerAtSlot(slotIndex) != null) return false;

    final cost = towerCatalog[type]!.placementCost;
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
      coins += towerCatalog[tower.type]!.placementCost;
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
      final statusDamage = enemy.updateStatusEffects(deltaTime);
      if (statusDamage > 0) {
        _damageEnemy(enemy, statusDamage);
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
    final route = map.routeForSpawn(
      enemiesSpawned,
      routeId: group.routeId,
    );
    enemies.add(Enemy.spawn(
      id: 'enemy_${DateTime.now().millisecondsSinceEpoch}',
      type: group.type,
      path: pathsByRouteId[route.id]!,
      routeId: route.id,
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
    final definition = towerCatalog[tower.type]!;
    projectiles.add(Projectile(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      targetEnemyId: target.id,
      source: tower.position,
      position: tower.position,
      targetPosition: target.position,
      attack: definition.attack.resolve(
        directDamage: tower.damage,
        areaRadius: tower.blastRadius,
      ),
    ));
  }

  void _applyProjectileDamage(Projectile projectile, Enemy directHit) {
    if (projectile.attack.impactVisualId == 'cannon_explosion') {
      blastEffects.add(BlastEffect(
        position: directHit.position,
        radius: projectile.attack.areaRadius,
      ));
    }

    final targets = projectile.attack.areaRadius <= 0
        ? <Enemy>[directHit]
        : enemies.where((enemy) {
            if (enemy.isDead) return false;
            final distance = (enemy.position - directHit.position).distance;
            return distance <= projectile.attack.areaRadius + enemy.radius;
          });

    for (final enemy in targets) {
      for (final effect in projectile.attack.effects) {
        if (effect is DirectDamageEffectDefinition) {
          _damageEnemy(enemy, effect.damage);
        } else if (effect is StatusEffectDefinition) {
          enemy.applyStatus(effect);
        }
      }
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
