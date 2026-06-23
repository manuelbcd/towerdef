import 'game_config.dart';

class EncounterDefinition {
  final String id;
  final String nameKey;
  final List<WaveConfig> waves;

  const EncounterDefinition({
    required this.id,
    required this.nameKey,
    required this.waves,
  });
}

class WaveConfig {
  final double spawnInterval;
  final List<WaveEnemyGroup> enemyGroups;

  const WaveConfig({
    required this.spawnInterval,
    required this.enemyGroups,
  });

  int get totalEnemies {
    return enemyGroups.fold(0, (total, group) => total + group.count);
  }
}

class WaveEnemyGroup {
  final EnemyType type;
  final int count;
  final double health;
  final double speed;
  final MovementPattern movementPattern;
  final String? routeId;

  const WaveEnemyGroup({
    required this.type,
    required this.count,
    required this.health,
    required this.speed,
    required this.movementPattern,
    this.routeId,
  });
}

const introEncounter = EncounterDefinition(
  id: 'border_patrol',
  nameKey: 'encounter_border_patrol',
  waves: [
    WaveConfig(
      spawnInterval: 1,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.goblin,
          count: 3,
          health: 22,
          speed: 58,
          movementPattern: MovementPattern.straight,
        ),
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 2,
          health: 14,
          speed: 84,
          movementPattern: MovementPattern.stepStopStep,
        ),
      ],
    ),
    WaveConfig(
      spawnInterval: 0.85,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.goblin,
          count: 4,
          health: 28,
          speed: 62,
          movementPattern: MovementPattern.straight,
        ),
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 3,
          health: 18,
          speed: 92,
          movementPattern: MovementPattern.stepStopStep,
        ),
      ],
    ),
    WaveConfig(
      spawnInterval: 0.75,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.goblin,
          count: 4,
          health: 34,
          speed: 64,
          movementPattern: MovementPattern.straight,
        ),
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 3,
          health: 22,
          speed: 96,
          movementPattern: MovementPattern.stepStopStep,
        ),
        WaveEnemyGroup(
          type: EnemyType.brute,
          count: 2,
          health: 58,
          speed: 40,
          movementPattern: MovementPattern.straight,
        ),
      ],
    ),
  ],
);

const assaultEncounter = EncounterDefinition(
  id: 'mixed_assault',
  nameKey: 'encounter_mixed_assault',
  waves: [
    WaveConfig(
      spawnInterval: 0.85,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 4,
          health: 20,
          speed: 94,
          movementPattern: MovementPattern.stepStopStep,
        ),
        WaveEnemyGroup(
          type: EnemyType.goblin,
          count: 4,
          health: 32,
          speed: 64,
          movementPattern: MovementPattern.straight,
        ),
      ],
    ),
    WaveConfig(
      spawnInterval: 0.72,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.goblin,
          count: 5,
          health: 38,
          speed: 67,
          movementPattern: MovementPattern.straight,
        ),
        WaveEnemyGroup(
          type: EnemyType.brute,
          count: 2,
          health: 68,
          speed: 42,
          movementPattern: MovementPattern.straight,
        ),
      ],
    ),
    WaveConfig(
      spawnInterval: 0.62,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 5,
          health: 26,
          speed: 102,
          movementPattern: MovementPattern.stepStopStep,
        ),
        WaveEnemyGroup(
          type: EnemyType.brute,
          count: 3,
          health: 76,
          speed: 44,
          movementPattern: MovementPattern.straight,
        ),
      ],
    ),
  ],
);

const siegeEncounter = EncounterDefinition(
  id: 'heavy_siege',
  nameKey: 'encounter_heavy_siege',
  waves: [
    WaveConfig(
      spawnInterval: 0.75,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.brute,
          count: 3,
          health: 82,
          speed: 42,
          movementPattern: MovementPattern.straight,
        ),
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 4,
          health: 28,
          speed: 104,
          movementPattern: MovementPattern.stepStopStep,
        ),
      ],
    ),
    WaveConfig(
      spawnInterval: 0.62,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.goblin,
          count: 7,
          health: 46,
          speed: 70,
          movementPattern: MovementPattern.straight,
        ),
        WaveEnemyGroup(
          type: EnemyType.brute,
          count: 3,
          health: 92,
          speed: 44,
          movementPattern: MovementPattern.straight,
        ),
      ],
    ),
    WaveConfig(
      spawnInterval: 0.5,
      enemyGroups: [
        WaveEnemyGroup(
          type: EnemyType.runner,
          count: 7,
          health: 34,
          speed: 110,
          movementPattern: MovementPattern.stepStopStep,
        ),
        WaveEnemyGroup(
          type: EnemyType.brute,
          count: 4,
          health: 110,
          speed: 46,
          movementPattern: MovementPattern.straight,
        ),
      ],
    ),
  ],
);

const encounterCatalog = <String, EncounterDefinition>{
  'border_patrol': introEncounter,
  'mixed_assault': assaultEncounter,
  'heavy_siege': siegeEncounter,
};
