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

enum SceneryType { tree, rock, mountain, sand, lake }

class SceneryItem {
  final SceneryType type;
  final Offset position;
  final double scale;
  final double rotation;

  const SceneryItem({
    required this.type,
    required this.position,
    this.scale = 1,
    this.rotation = 0,
  });

  Offset scaledPosition(Size size) {
    return Offset(position.dx * size.width, position.dy * size.height);
  }
}

class LandscapePalette {
  final Color topColor;
  final Color bottomColor;
  final Color accentColor;

  const LandscapePalette({
    required this.topColor,
    required this.bottomColor,
    required this.accentColor,
  });
}

class GameMap {
  final String id;
  final String name;
  final List<Offset> pathWaypoints;
  final List<MapLine> startLines;
  final List<MapLine> endLines;
  final List<Offset> towerSlots;
  final List<WaveConfig> waves;
  final LandscapePalette landscapePalette;
  final List<SceneryItem> scenery;

  const GameMap({
    required this.id,
    required this.name,
    required this.pathWaypoints,
    required this.startLines,
    required this.endLines,
    required this.towerSlots,
    required this.waves,
    required this.landscapePalette,
    required this.scenery,
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
      Offset(0.42, 0.64),
      Offset(0.91, 0.42),
    ],
    landscapePalette: LandscapePalette(
      topColor: Color(0xFF173F35),
      bottomColor: Color(0xFF10283A),
      accentColor: Color(0xFF77B86A),
    ),
    scenery: [
      SceneryItem(
          type: SceneryType.tree, position: Offset(0.08, 0.48), scale: 1.15),
      SceneryItem(
          type: SceneryType.tree, position: Offset(0.91, 0.24), scale: 0.9),
      SceneryItem(
          type: SceneryType.tree, position: Offset(0.55, 0.68), scale: 1.25),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.36, 0.72), scale: 0.9),
      SceneryItem(
          type: SceneryType.lake,
          position: Offset(0.86, 0.84),
          scale: 1.35,
          rotation: -0.12),
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
      Offset(0.82, 0.18),
      Offset(0.12, 0.88),
    ],
    landscapePalette: LandscapePalette(
      topColor: Color(0xFF4A281E),
      bottomColor: Color(0xFF251A2A),
      accentColor: Color(0xFFE08A4E),
    ),
    scenery: [
      SceneryItem(
          type: SceneryType.sand,
          position: Offset(0.78, 0.18),
          scale: 1.7,
          rotation: 0.25),
      SceneryItem(
          type: SceneryType.mountain,
          position: Offset(0.82, 0.72),
          scale: 1.25),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.08, 0.72), scale: 1.1),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.44, 0.10), scale: 0.75),
      SceneryItem(
          type: SceneryType.sand,
          position: Offset(0.18, 0.88),
          scale: 1.25,
          rotation: -0.2),
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
      Offset(0.92, 0.68),
      Offset(0.54, 0.22),
    ],
    landscapePalette: LandscapePalette(
      topColor: Color(0xFF17394A),
      bottomColor: Color(0xFF182D3A),
      accentColor: Color(0xFF58A6B8),
    ),
    scenery: [
      SceneryItem(
          type: SceneryType.lake,
          position: Offset(0.48, 0.18),
          scale: 1.55,
          rotation: 0.08),
      SceneryItem(
          type: SceneryType.lake,
          position: Offset(0.72, 0.82),
          scale: 1.25,
          rotation: -0.22),
      SceneryItem(
          type: SceneryType.tree, position: Offset(0.10, 0.24), scale: 1.0),
      SceneryItem(
          type: SceneryType.tree, position: Offset(0.88, 0.58), scale: 1.2),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.12, 0.90), scale: 0.9),
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
      Offset(0.08, 0.28),
      Offset(0.92, 0.88),
    ],
    landscapePalette: LandscapePalette(
      topColor: Color(0xFF3B4148),
      bottomColor: Color(0xFF1E2833),
      accentColor: Color(0xFF8C989F),
    ),
    scenery: [
      SceneryItem(
          type: SceneryType.mountain,
          position: Offset(0.10, 0.16),
          scale: 1.35),
      SceneryItem(
          type: SceneryType.mountain, position: Offset(0.88, 0.16), scale: 1.0),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.10, 0.84), scale: 1.0),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.72, 0.62), scale: 0.8),
      SceneryItem(
          type: SceneryType.sand, position: Offset(0.38, 0.56), scale: 1.2),
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
      Offset(0.12, 0.88),
      Offset(0.88, 0.58),
    ],
    landscapePalette: LandscapePalette(
      topColor: Color(0xFF244B61),
      bottomColor: Color(0xFF17263D),
      accentColor: Color(0xFFB7E4EF),
    ),
    scenery: [
      SceneryItem(
          type: SceneryType.lake,
          position: Offset(0.80, 0.78),
          scale: 1.4,
          rotation: 0.16),
      SceneryItem(
          type: SceneryType.mountain,
          position: Offset(0.10, 0.20),
          scale: 1.15),
      SceneryItem(
          type: SceneryType.mountain,
          position: Offset(0.86, 0.08),
          scale: 0.85),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.14, 0.58), scale: 0.85),
      SceneryItem(
          type: SceneryType.rock, position: Offset(0.72, 0.92), scale: 1.0),
    ],
    waves: standardMapWaves,
  ),
];
