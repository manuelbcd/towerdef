import 'package:flutter_test/flutter_test.dart';
import 'package:towerdef/game/game_engine.dart';
import 'package:flutter/material.dart';
import 'package:towerdef/models/enemy.dart';
import 'package:towerdef/models/game_config.dart';
import 'package:towerdef/models/game_map.dart';
import 'package:towerdef/models/projectile.dart';
import 'package:towerdef/models/tower.dart';

void main() {
  test('GameEngine upgrade and coin logic', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    expect(engine.coins, 500);
    expect(engine.placeTowerAtSlot(0, TowerType.archer), true);
    expect(engine.coins, 400);
    final tower = engine.towers.first;

    final cost = tower.upgradeCost;
    final success = engine.upgradeTower(tower);
    if (cost <= 400) {
      // Should have succeeded
      expect(success, true);
      expect(engine.coins, 400 - cost);
      expect(tower.upgrades, 1);
    }
  });

  test('Game starts in placement stage and does not spawn enemies', () {
    final engine = GameEngine(screenSize: const Size(400, 800));

    expect(engine.stage, GameStage.placement);
    expect(engine.towers, isEmpty);
    expect(engine.towerSlots.length, 7);

    engine.update(2);

    expect(engine.enemies, isEmpty);
    expect(engine.enemiesSpawned, 0);
  });

  test('Player can place towers before and during active play', () {
    final engine = GameEngine(screenSize: const Size(400, 800));

    expect(engine.placeTowerAtSlot(0, TowerType.archer), true);
    expect(engine.placeTowerAtSlot(4, TowerType.cannon), true);

    expect(engine.towers.length, 2);
    expect(engine.coins, 150);
    expect(engine.towerAtSlot(0)?.type, TowerType.archer);
    expect(engine.towerAtSlot(4)?.type, TowerType.cannon);

    engine.startPlay();

    expect(engine.stage, GameStage.play);
    expect(engine.placeTowerAtSlot(1, TowerType.magic), false);

    engine.coins += 50;
    expect(engine.placeTowerAtSlot(1, TowerType.magic), true);
    expect(engine.towerAtSlot(1)?.type, TowerType.magic);
    expect(engine.coins, 0);
  });

  test('Player can remove a selected tower only during placement', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.placeTowerAtSlot(0, TowerType.archer);
    final tower = engine.towers.single;

    expect(engine.removeTower(tower), true);
    expect(engine.towers, isEmpty);
    expect(engine.coins, 500);

    engine.placeTowerAtSlot(1, TowerType.cannon);
    final lockedTower = engine.towers.single;
    engine.startPlay();

    expect(engine.removeTower(lockedTower), false);
    expect(engine.towers, contains(lockedTower));
    expect(engine.coins, 250);
  });

  test('Placement costs enforce the 500 gold starting build budget', () {
    final engine = GameEngine(screenSize: const Size(400, 800));

    expect(towerConfigs[TowerType.archer]!.placementCost, 100);
    expect(towerConfigs[TowerType.cannon]!.placementCost, 250);
    expect(towerConfigs[TowerType.magic]!.placementCost, 200);
    expect(towerConfigs[TowerType.slowerer]!.placementCost, 150);

    expect(engine.placeTowerAtSlot(0, TowerType.cannon), true);
    expect(engine.placeTowerAtSlot(1, TowerType.slowerer), true);
    expect(engine.placeTowerAtSlot(2, TowerType.archer), true);
    expect(engine.coins, 0);
    expect(engine.placeTowerAtSlot(3, TowerType.magic), false);
    expect(engine.towers, hasLength(3));

    expect(engine.removeTower(engine.towerAtSlot(1)!), true);
    expect(engine.coins, 150);
    expect(engine.placeTowerAtSlot(3, TowerType.archer), true);
    expect(engine.coins, 50);
  });

  test('Tower stats come from tower configuration', () {
    final tower = Tower.create(
      id: 'cannon_test',
      type: TowerType.cannon,
      position: Offset.zero,
    );
    final config = towerConfigs[TowerType.cannon]!;

    expect(tower.fireRate, config.shotsPerSecond);
    expect(tower.damage, config.damage);
    expect(tower.range, config.range);
    expect(tower.blastRadius, config.blastRadius);
  });

  test('Every tower receives the configured 25 percent range boost', () {
    final originalRanges = <TowerType, double>{
      TowerType.archer: 155,
      TowerType.magic: 135,
      TowerType.cannon: 125,
      TowerType.slowerer: 150,
    };

    for (final entry in originalRanges.entries) {
      expect(
        towerConfigs[entry.key]!.range,
        entry.value * 1.25,
        reason: '${entry.key.name} should receive the range boost',
      );
    }
  });

  test('Enemy stats and movement pattern come from enemy configuration', () {
    final path = [Offset.zero, const Offset(200, 0)];
    final enemy = Enemy.spawn(
      id: 'runner_test',
      type: EnemyType.runner,
      path: path,
    );
    final config = enemyConfigs[EnemyType.runner]!;

    expect(enemy.speed, config.speed);
    expect(enemy.movementPattern, MovementPattern.stepStopStep);

    enemy.update(0.5);
    final positionAfterStep = enemy.position.dx;
    enemy.update(0.1);

    expect(enemy.position.dx, positionAfterStep);
  });

  test('Each configured map has explicit wave definitions', () {
    for (final map in gameMaps) {
      expect(map.waves.length, 3,
          reason: '${map.name} should be won after three waves');
      for (final wave in map.waves) {
        expect(wave.totalEnemies, greaterThan(0));
        expect(wave.spawnInterval, greaterThan(0));
        for (final group in wave.enemyGroups) {
          expect(group.count, greaterThan(0));
          expect(group.health, greaterThan(0));
          expect(group.speed, greaterThan(0));
        }
      }
    }
  });

  test('Each map has valid configurable landscape scenery', () {
    for (final map in gameMaps) {
      expect(map.towerSlots, hasLength(7));
      expect(map.scenery, isNotEmpty, reason: '${map.name} needs scenery');
      for (final item in map.scenery) {
        expect(item.position.dx, inInclusiveRange(0, 1));
        expect(item.position.dy, inInclusiveRange(0, 1));
        expect(item.scale, greaterThan(0));
      }
    }
  });

  test('Wave number advances and the final cleared wave wins the map', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.startPlay();

    expect(engine.wave, 1);
    expect(engine.totalWaves, 3);
    expect(engine.isVictory, false);

    _spawnAndClearCurrentWave(engine);
    expect(engine.wave, 2);
    expect(engine.isVictory, false);

    _spawnAndClearCurrentWave(engine);
    expect(engine.wave, 3);
    expect(engine.isVictory, false);

    _spawnAndClearCurrentWave(engine);
    expect(engine.wave, 3);
    expect(engine.isVictory, true);
    expect(engine.isGameOver, false);
  });

  test('Engine spawns enemies from configured wave groups', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    final firstGroup = engine.map.waves.first.enemyGroups.first;

    engine.startPlay();
    engine.update(engine.spawnInterval);

    expect(engine.enemies.length, 1);
    expect(engine.enemiesSpawned, 1);
    expect(engine.enemiesInWave, engine.map.waves.first.totalEnemies);
    expect(engine.enemies.first.type, firstGroup.type);
    expect(engine.enemies.first.health, firstGroup.health);
    expect(engine.enemies.first.speed, firstGroup.speed);
    expect(engine.enemies.first.movementPattern, firstGroup.movementPattern);
  });

  test('Enemy hit testing is available only during play', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    final enemy = _enemyAt(
      id: 'selectable_enemy',
      position: const Offset(120, 160),
    );
    engine.enemies.add(enemy);

    expect(engine.enemyAt(enemy.position), isNull);

    engine.startPlay();

    expect(engine.enemyAt(enemy.position), same(enemy));
    expect(engine.enemyAt(const Offset(220, 260)), isNull);

    enemy.isDead = true;
    expect(engine.enemyAt(enemy.position), isNull);
  });

  test('Projectile reaching target point waits for collision damage decision',
      () {
    final projectile = Projectile(
      id: 'projectile_test',
      targetEnemyId: 'enemy_test',
      source: Offset.zero,
      position: Offset.zero,
      targetPosition: const Offset(10, 0),
      speed: 20,
      damage: 5,
    );

    projectile.update(1);

    expect(projectile.position, const Offset(10, 0));
    expect(projectile.reachedTargetPosition, true);
    expect(projectile.hasHit, false);
  });

  test('Engine projectiles track moving enemies before applying damage', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.startPlay();
    final enemy = Enemy(
      id: 'moving_enemy',
      type: EnemyType.goblin,
      path: [const Offset(150, 100), const Offset(300, 100)],
      position: const Offset(150, 100),
      speed: 40,
      movementPattern: MovementPattern.straight,
      health: 30,
    );
    engine.enemies.add(enemy);
    engine.projectiles.add(Projectile(
      id: 'tracking_projectile',
      targetEnemyId: enemy.id,
      source: const Offset(100, 100),
      position: const Offset(100, 100),
      targetPosition: enemy.position,
      speed: 300,
      damage: 10,
    ));

    engine.update(0.2);

    expect(enemy.health, lessThan(enemy.maxHealth));
  });

  test('Every configured tower can damage every configured enemy type', () {
    for (final towerEntry in towerConfigs.entries) {
      for (final enemyType in EnemyType.values) {
        final engine = GameEngine(screenSize: const Size(400, 800));
        engine.startPlay();
        engine.towers.clear();
        engine.enemiesSpawned = engine.enemiesInWave;

        final enemy = Enemy(
          id: '${towerEntry.key.name}_${enemyType.name}',
          type: enemyType,
          path: [const Offset(160, 100), const Offset(160, 100)],
          position: const Offset(160, 100),
          speed: 0,
          movementPattern: MovementPattern.straight,
          health: 100,
        );
        engine.enemies.add(enemy);
        engine.projectiles.add(Projectile(
          id: 'projectile_${towerEntry.key.name}_${enemyType.name}',
          targetEnemyId: enemy.id,
          source: const Offset(120, 100),
          position: enemy.position,
          targetPosition: enemy.position,
          speed: 1,
          damage: towerEntry.value.damage,
          blastRadius: towerEntry.value.blastRadius,
        ));

        engine.update(0.01);

        expect(
          enemy.health,
          100 - towerEntry.value.damage,
          reason:
              '${towerEntry.key.name} should damage ${enemyType.name} on hit',
        );
      }
    }
  });

  test('Configured blast radius damages nearby enemies only', () {
    for (final towerEntry
        in towerConfigs.entries.where((entry) => entry.value.blastRadius > 0)) {
      final engine = GameEngine(screenSize: const Size(400, 800));
      engine.startPlay();
      engine.towers.clear();
      engine.enemiesSpawned = engine.enemiesInWave;

      final direct = _enemyAt(
        id: 'direct_${towerEntry.key.name}',
        position: const Offset(160, 100),
      );
      final nearby = _enemyAt(
        id: 'nearby_${towerEntry.key.name}',
        position: Offset(160 + towerEntry.value.blastRadius - 1, 100),
      );
      final far = _enemyAt(
        id: 'far_${towerEntry.key.name}',
        position: Offset(160 + towerEntry.value.blastRadius + 60, 100),
      );

      engine.enemies.addAll([direct, nearby, far]);
      engine.projectiles.add(Projectile(
        id: 'blast_${towerEntry.key.name}',
        targetEnemyId: direct.id,
        source: const Offset(120, 100),
        position: direct.position,
        targetPosition: direct.position,
        speed: 1,
        damage: towerEntry.value.damage,
        blastRadius: towerEntry.value.blastRadius,
      ));

      engine.update(0.01);

      expect(direct.health, 100 - towerEntry.value.damage);
      expect(nearby.health, 100 - towerEntry.value.damage);
      expect(far.health, 100);
    }
  });

  test('Cannon hits create a short-lived blast-radius effect', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.startPlay();
    engine.enemiesSpawned = engine.enemiesInWave;
    final enemy = _enemyAt(
      id: 'cannon_effect_target',
      position: const Offset(160, 100),
    );
    engine.enemies.add(enemy);
    engine.projectiles.add(Projectile(
      id: 'cannon_effect_projectile',
      targetEnemyId: enemy.id,
      source: const Offset(120, 100),
      position: enemy.position,
      targetPosition: enemy.position,
      speed: 1,
      damage: towerConfigs[TowerType.cannon]!.damage,
      blastRadius: towerConfigs[TowerType.cannon]!.blastRadius,
      sourceTowerType: TowerType.cannon,
    ));

    engine.update(0.01);

    expect(engine.blastEffects, hasLength(1));
    expect(engine.blastEffects.single.position, enemy.position);
    expect(
      engine.blastEffects.single.radius,
      towerConfigs[TowerType.cannon]!.blastRadius,
    );

    engine.update(1);
    expect(engine.blastEffects, isEmpty);
  });

  test('Slowerer rays reduce enemy movement speed to one third temporarily',
      () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.startPlay();
    engine.enemiesSpawned = engine.enemiesInWave;
    final enemy = Enemy(
      id: 'slow_target',
      type: EnemyType.goblin,
      path: [const Offset(100, 100), const Offset(500, 100)],
      position: const Offset(100, 100),
      speed: 90,
      movementPattern: MovementPattern.straight,
      health: 100,
    );
    final config = towerConfigs[TowerType.slowerer]!;
    engine.enemies.add(enemy);
    engine.projectiles.add(Projectile(
      id: 'slow_ray',
      targetEnemyId: enemy.id,
      source: const Offset(50, 100),
      position: enemy.position,
      targetPosition: enemy.position,
      speed: 520,
      damage: config.damage,
      sourceTowerType: TowerType.slowerer,
      slowMultiplier: config.slowMultiplier,
      slowDuration: config.slowDuration,
    ));

    engine.update(0.01);

    expect(enemy.isSlowed, true);
    expect(enemy.effectiveSpeed, closeTo(30, 0.001));
    final slowedStart = enemy.position.dx;
    enemy.update(1);
    expect(enemy.position.dx - slowedStart, closeTo(30, 0.001));

    enemy.update(3);
    expect(enemy.isSlowed, false);
    expect(enemy.effectiveSpeed, 90);
  });

  test('Magic projectiles apply configurable progressive purple damage', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.startPlay();
    engine.enemiesSpawned = engine.enemiesInWave;
    final enemy = _enemyAt(
      id: 'magic_curse_target',
      position: const Offset(160, 100),
    );
    final config = towerConfigs[TowerType.magic]!;
    engine.enemies.add(enemy);
    engine.projectiles.add(Projectile(
      id: 'magic_curse_projectile',
      targetEnemyId: enemy.id,
      source: const Offset(120, 100),
      position: enemy.position,
      targetPosition: enemy.position,
      speed: 200,
      damage: config.damage,
      blastRadius: config.blastRadius,
      sourceTowerType: TowerType.magic,
      damagePerTick: config.damagePerTick,
      damageTickCount: config.damageTickCount,
      damageTickInterval: config.damageTickInterval,
    ));

    engine.update(0.01);

    expect(enemy.health, 100 - config.damage);
    expect(enemy.isUnderMagicEffect, true);

    for (var tick = 1; tick <= config.damageTickCount; tick++) {
      engine.update(config.damageTickInterval);
      expect(
        enemy.health,
        100 - config.damage - (config.damagePerTick * tick),
      );
    }
    expect(enemy.isUnderMagicEffect, false);
  });

  test('Progressive magic kills award gold', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    engine.startPlay();
    engine.enemiesSpawned = engine.enemiesInWave;
    final enemy = Enemy(
      id: 'magic_reward_target',
      type: EnemyType.goblin,
      path: [const Offset(160, 100), const Offset(160, 100)],
      position: const Offset(160, 100),
      speed: 0,
      movementPattern: MovementPattern.straight,
      health: 6,
    );
    enemy.applyMagicDamage(
      damagePerTick: 10,
      tickCount: 1,
      tickInterval: 1,
    );
    engine.enemies.add(enemy);

    engine.update(1);

    expect(engine.kills, 1);
    expect(engine.coins, 525);
    expect(engine.enemies, isEmpty);
  });
}

Enemy _enemyAt({required String id, required Offset position}) {
  return Enemy(
    id: id,
    type: EnemyType.goblin,
    path: [position, position],
    position: position,
    speed: 0,
    movementPattern: MovementPattern.straight,
    health: 100,
  );
}

void _spawnAndClearCurrentWave(GameEngine engine) {
  final enemyCount = engine.enemiesInWave;
  for (var i = 0; i < enemyCount; i++) {
    engine.update(engine.spawnInterval);
  }
  engine.enemies.clear();
  engine.update(0);
}
