import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_config.dart';

class MapLine {
  final Offset from;
  final Offset to;

  const MapLine({required this.from, required this.to});

  MapLine scale(Size size) {
    return MapLine(
      from: Offset(from.dx * size.width, from.dy * size.height),
      to: Offset(to.dx * size.width, to.dy * size.height),
    );
  }
}

class GameMap {
  final String id;
  final String name;
  final List<Offset> pathWaypoints;
  final List<MapLine> startLines;
  final List<MapLine> endLines;
  final List<Offset> towerSlots;
  final List<WaveConfig> waves;

  const GameMap({
    required this.id,
    required this.name,
    required this.pathWaypoints,
    required this.startLines,
    required this.endLines,
    required this.towerSlots,
    required this.waves,
  });

  List<Offset> scaledPath(Size size) {
    final points = pathWaypoints
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();
    return _sampleCatmullRom(points, samplesPerSegment: 18);
  }

  List<MapLine> scaledStartLines(Size size) {
    return startLines.map((line) => line.scale(size)).toList();
  }

  List<MapLine> scaledEndLines(Size size) {
    return endLines.map((line) => line.scale(size)).toList();
  }

  List<Offset> scaledTowerSlots(Size size) {
    return towerSlots
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();
  }
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

  const WaveEnemyGroup({
    required this.type,
    required this.count,
    required this.health,
    required this.speed,
    required this.movementPattern,
  });
}

const standardMapWaves = <WaveConfig>[
  WaveConfig(
    spawnInterval: 1.0,
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
];

List<Offset> _sampleCatmullRom(
  List<Offset> points, {
  required int samplesPerSegment,
}) {
  if (points.length < 2) return points;

  final sampled = <Offset>[];
  for (var i = 0; i < points.length - 1; i++) {
    final p0 = points[math.max(0, i - 1)];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = points[math.min(points.length - 1, i + 2)];

    for (var step = 0; step < samplesPerSegment; step++) {
      final t = step / samplesPerSegment;
      sampled.add(_catmullRomPoint(p0, p1, p2, p3, t));
    }
  }
  sampled.add(points.last);
  return sampled;
}

Offset _catmullRomPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
  final t2 = t * t;
  final t3 = t2 * t;
  return Offset(
    0.5 *
        ((2 * p1.dx) +
            (-p0.dx + p2.dx) * t +
            (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
            (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3),
    0.5 *
        ((2 * p1.dy) +
            (-p0.dy + p2.dy) * t +
            (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
            (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3),
  );
}

const gameMaps = <GameMap>[
  GameMap(
    id: 'green_pass',
    name: 'Green Pass',
    pathWaypoints: [
      Offset(-0.08, 0.18),
      Offset(0.18, 0.20),
      Offset(0.38, 0.42),
      Offset(0.64, 0.34),
      Offset(0.82, 0.62),
      Offset(1.08, 0.62),
    ],
    startLines: [MapLine(from: Offset(0.02, 0.10), to: Offset(0.02, 0.28))],
    endLines: [MapLine(from: Offset(0.98, 0.54), to: Offset(0.98, 0.72))],
    towerSlots: [
      Offset(0.16, 0.38),
      Offset(0.24, 0.36),
      Offset(0.48, 0.25),
      Offset(0.67, 0.52),
      Offset(0.78, 0.42),
    ],
    waves: standardMapWaves,
  ),
  GameMap(
    id: 'ember_turns',
    name: 'Ember Turns',
    pathWaypoints: [
      Offset(0.22, -0.08),
      Offset(0.22, 0.22),
      Offset(0.52, 0.24),
      Offset(0.58, 0.55),
      Offset(0.32, 0.70),
      Offset(0.66, 0.88),
      Offset(0.66, 1.08),
    ],
    startLines: [MapLine(from: Offset(0.14, 0.02), to: Offset(0.30, 0.02))],
    endLines: [MapLine(from: Offset(0.58, 0.98), to: Offset(0.74, 0.98))],
    towerSlots: [
      Offset(0.18, 0.38),
      Offset(0.38, 0.38),
      Offset(0.72, 0.42),
      Offset(0.26, 0.56),
      Offset(0.50, 0.74),
    ],
    waves: standardMapWaves,
  ),
  GameMap(
    id: 'river_hook',
    name: 'River Hook',
    pathWaypoints: [
      Offset(1.08, 0.16),
      Offset(0.78, 0.20),
      Offset(0.74, 0.46),
      Offset(0.44, 0.50),
      Offset(0.30, 0.74),
      Offset(-0.08, 0.76),
    ],
    startLines: [MapLine(from: Offset(0.98, 0.08), to: Offset(0.98, 0.26))],
    endLines: [MapLine(from: Offset(0.02, 0.68), to: Offset(0.02, 0.84))],
    towerSlots: [
      Offset(0.80, 0.36),
      Offset(0.64, 0.34),
      Offset(0.50, 0.66),
      Offset(0.22, 0.48),
      Offset(0.34, 0.28),
    ],
    waves: standardMapWaves,
  ),
  GameMap(
    id: 'stone_s',
    name: 'Stone S',
    pathWaypoints: [
      Offset(-0.08, 0.50),
      Offset(0.18, 0.50),
      Offset(0.30, 0.20),
      Offset(0.56, 0.20),
      Offset(0.68, 0.50),
      Offset(0.48, 0.78),
      Offset(0.84, 0.78),
      Offset(1.08, 0.52),
    ],
    startLines: [MapLine(from: Offset(0.02, 0.42), to: Offset(0.02, 0.58))],
    endLines: [MapLine(from: Offset(0.98, 0.44), to: Offset(0.98, 0.60))],
    towerSlots: [
      Offset(0.18, 0.68),
      Offset(0.38, 0.38),
      Offset(0.76, 0.34),
      Offset(0.58, 0.66),
      Offset(0.86, 0.66),
    ],
    waves: standardMapWaves,
  ),
  GameMap(
    id: 'frost_loop',
    name: 'Frost Loop',
    pathWaypoints: [
      Offset(0.50, 1.08),
      Offset(0.50, 0.82),
      Offset(0.22, 0.72),
      Offset(0.24, 0.38),
      Offset(0.54, 0.32),
      Offset(0.78, 0.46),
      Offset(0.76, 0.16),
      Offset(0.50, -0.08),
    ],
    startLines: [MapLine(from: Offset(0.42, 0.98), to: Offset(0.58, 0.98))],
    endLines: [MapLine(from: Offset(0.42, 0.02), to: Offset(0.58, 0.02))],
    towerSlots: [
      Offset(0.34, 0.84),
      Offset(0.38, 0.56),
      Offset(0.62, 0.60),
      Offset(0.60, 0.22),
      Offset(0.82, 0.30),
    ],
    waves: standardMapWaves,
  ),
];
