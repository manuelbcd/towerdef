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
    final tower = engine.towers.first;

    final cost = tower.upgradeCost;
    final success = engine.upgradeTower(tower);
    if (cost <= 500) {
      // Should have succeeded
      expect(success, true);
      expect(engine.coins, 500 - cost);
      expect(tower.upgrades, 1);
    }
  });

  test('Game starts in placement stage and does not spawn enemies', () {
    final engine = GameEngine(screenSize: const Size(400, 800));

    expect(engine.stage, GameStage.placement);
    expect(engine.towers, isEmpty);
    expect(engine.towerSlots.length, 5);

    engine.update(2);

    expect(engine.enemies, isEmpty);
    expect(engine.enemiesSpawned, 0);
  });

  test('Player can place towers in map slots before play starts', () {
    final engine = GameEngine(screenSize: const Size(400, 800));

    expect(engine.placeTowerAtSlot(0, TowerType.archer), true);
    expect(engine.placeTowerAtSlot(4, TowerType.cannon), true);

    expect(engine.towers.length, 2);
    expect(engine.towerAtSlot(0)?.type, TowerType.archer);
    expect(engine.towerAtSlot(4)?.type, TowerType.cannon);

    engine.startPlay();

    expect(engine.stage, GameStage.play);
    expect(engine.placeTowerAtSlot(1, TowerType.magic), false);
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
      expect(map.waves, isNotEmpty, reason: '${map.name} needs waves');
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
