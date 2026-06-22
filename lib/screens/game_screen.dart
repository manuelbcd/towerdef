import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../localization/app_localizations.dart';
import '../game/game_engine.dart';
import '../models/tower.dart';
import '../audio/audio_manager.dart';
import '../widgets/volume_controls.dart';
import '../models/enemy.dart';
import '../models/game_config.dart';
import '../models/projectile.dart';
import '../models/game_map.dart';
import '../models/blast_effect.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  GameEngine? engine;
  Ticker? ticker;
  Duration? lastElapsed;
  Tower? selectedTower;
  Enemy? selectedEnemy;
  TowerType selectedPlacementTowerType = TowerType.archer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      engine = GameEngine(screenSize: Size(size.width, size.height * 0.7));
      _startGameLoop();
      AudioManager().init();
      setState(() {});
    });
  }

  void _startGameLoop() {
    ticker?.dispose();
    lastElapsed = null;
    ticker = createTicker((elapsed) {
      final delta = lastElapsed == null
          ? 0.0
          : (elapsed - lastElapsed!).inMicroseconds / 1e6;
      lastElapsed = elapsed;
      if (engine == null) return;
      engine!.update(delta);
      if (selectedEnemy != null && !engine!.enemies.contains(selectedEnemy)) {
        selectedEnemy = null;
      }
      setState(() {});
    });
    ticker?.start();
  }

  void _upgradeTower() {
    if (selectedTower != null && engine != null) {
      final success = engine!.upgradeTower(selectedTower!);
      if (success) {
        setState(() {});
      }
    }
  }

  void _removeSelectedTower() {
    final currentEngine = engine;
    final tower = selectedTower;
    if (currentEngine == null || tower == null) return;

    setState(() {
      if (currentEngine.removeTower(tower)) {
        selectedTower = null;
      }
    });
  }

  void _openSettingsSheet() {
    final audio = AudioManager();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.indigo.shade900,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: VolumeControls(
            musicVolume: audio.musicVolume,
            soundVolume: audio.sfxVolume,
            onMusicChanged: (v) async {
              await audio.setMusicVolume(v);
              setState(() {});
            },
            onSoundChanged: (v) async {
              await audio.setSfxVolume(v);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _tapAt(Offset localPosition) {
    if (engine == null) return;
    final currentEngine = engine!;

    final slotIndex = currentEngine.slotIndexAt(localPosition);
    if (slotIndex != null &&
        !currentEngine.isGameOver &&
        !currentEngine.isVictory) {
      final existingTower = currentEngine.towerAtSlot(slotIndex);
      if (existingTower != null) {
        setState(() {
          selectedTower = existingTower;
          selectedEnemy = null;
        });
        return;
      }

      final placed = currentEngine.placeTowerAtSlot(
        slotIndex,
        selectedPlacementTowerType,
      );
      if (!placed) {
        final cost = towerConfigs[selectedPlacementTowerType]!.placementCost;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not enough gold — this tower costs $cost gold.'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        selectedTower = currentEngine.towerAtSlot(slotIndex);
        selectedEnemy = null;
      });
      return;
    }

    if (currentEngine.isPlacementStage) return;

    final tappedEnemy = currentEngine.enemyAt(localPosition);
    if (tappedEnemy != null) {
      setState(() {
        selectedEnemy = tappedEnemy;
        selectedTower = null;
      });
      return;
    }

    Tower? tappedTower;
    for (final tower in currentEngine.towers) {
      if ((tower.position - localPosition).distance <= tower.radius + 12) {
        tappedTower = tower;
        break;
      }
    }
    setState(() {
      selectedTower = tappedTower;
      selectedEnemy = null;
    });
  }

  void _resetGame() {
    final currentEngine = engine;
    if (currentEngine == null) return;

    setState(() {
      engine = GameEngine(
        screenSize: currentEngine.screenSize,
        mapIndex: currentEngine.mapIndex,
      );
      selectedTower = null;
      selectedEnemy = null;
    });
    _startGameLoop();
  }

  void _startPlayStage() {
    final currentEngine = engine;
    if (currentEngine == null || currentEngine.towers.isEmpty) return;

    setState(() {
      currentEngine.startPlay();
      selectedTower = null;
      selectedEnemy = null;
    });
  }

  void _nextMap() {
    final currentEngine = engine;
    if (currentEngine == null) return;

    setState(() {
      engine = GameEngine(
        screenSize: currentEngine.screenSize,
        mapIndex: currentEngine.nextMapIndex,
      );
      selectedTower = null;
      selectedEnemy = null;
    });
    _startGameLoop();
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAreaHeight = MediaQuery.of(context).size.height * 0.7;

    final currentEngine = engine;
    if (currentEngine == null) {
      return const Scaffold(
        backgroundColor: Colors.indigo,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF11194A),
      body: SafeArea(
        child: Column(
          children: [
            // Game area
            GestureDetector(
              onTapDown: (details) => _tapAt(details.localPosition),
              child: Container(
                height: gameAreaHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  color: Colors.black54,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GamePainter(
                          engine: currentEngine,
                          selectedTower: selectedTower,
                          selectedEnemy: selectedEnemy,
                          selectedPlacementTowerType:
                              selectedPlacementTowerType,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: IgnorePointer(
                        child: _WaveBadge(
                          wave: currentEngine.wave,
                          totalWaves: currentEngine.totalWaves,
                        ),
                      ),
                    ),
                    if (currentEngine.isPlacementStage && selectedTower != null)
                      Positioned(
                        left: selectedTower!.position.dx - 52,
                        top: selectedTower!.position.dy - 22,
                        child: _TowerRemoveButton(
                          onPressed: _removeSelectedTower,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // UI Area
            Expanded(
              child: Container(
                color: Colors.indigo.shade900,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text('Gold ${currentEngine.coins}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text(
                                  'Life ${currentEngine.playerLifePoints}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text(
                                  'Wave ${currentEngine.wave}/${currentEngine.totalWaves}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Kills ${currentEngine.kills}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold))),
                          Text(currentEngine.map.name,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                          const SizedBox(width: 8),
                          Text(
                              currentEngine.isPlacementStage
                                  ? 'Placement'
                                  : 'Play',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          ElevatedButton(
                              onPressed: _nextMap, child: const Text('Map')),
                          const SizedBox(width: 8),
                          ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700),
                              child: const Text('Restart')),
                          IconButton(
                            onPressed: _openSettingsSheet,
                            icon:
                                const Icon(Icons.settings, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tower purchase controls stay available during combat.
                      _PlacementPanel(
                        selectedType: selectedPlacementTowerType,
                        towersPlaced: currentEngine.towers.length,
                        totalSlots: currentEngine.towerSlots.length,
                        availableGold: currentEngine.coins,
                        isPlacementStage: currentEngine.isPlacementStage,
                        onTypeSelected: (type) {
                          setState(() {
                            selectedPlacementTowerType = type;
                          });
                        },
                        onStart: currentEngine.towers.isEmpty
                            ? null
                            : _startPlayStage,
                      ),
                      if (currentEngine.isPlayStage &&
                          selectedEnemy != null) ...[
                        const SizedBox(height: 12),
                        _EnemyCharacterSheet(
                          enemy: selectedEnemy!,
                          onClose: () {
                            setState(() {
                              selectedEnemy = null;
                            });
                          },
                        ),
                      ] else if (currentEngine.isPlayStage &&
                          selectedTower != null) ...[
                        const SizedBox(height: 12),
                        _TowerControlPanel(
                          tower: selectedTower!,
                          onUpgrade: _upgradeTower,
                        ),
                      ] else if (currentEngine.isPlayStage)
                        Text(
                          'Tap a tower to select',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      const SizedBox(height: 12),
                      if (currentEngine.isVictory) ...[
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(context.t('victory'),
                                  style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(
                                  '${context.t('map_defended')}: ${currentEngine.map.name}',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white70)),
                              Text('Total kills: ${currentEngine.kills}',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white70)),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: _nextMap,
                                  child: Text(context.t('next_map'))),
                            ],
                          ),
                        ),
                      ] else if (currentEngine.isGameOver) ...[
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Game Over!',
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text('Wave reached: ${currentEngine.wave}',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white70)),
                              Text('Total kills: ${currentEngine.kills}',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white70)),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: _resetGame,
                                  child: const Text('Play Again')),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveBadge extends StatelessWidget {
  final int wave;
  final int totalWaves;

  const _WaveBadge({required this.wave, required this.totalWaves});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xDD11194A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.75)),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.t('wave').toUpperCase(),
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$wave',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 0.9,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            ' / $totalWaves',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TowerRemoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _TowerRemoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade700,
      shape: const CircleBorder(),
      elevation: 6,
      child: IconButton(
        tooltip: 'Remove tower',
        onPressed: onPressed,
        icon: const Icon(Icons.remove, color: Colors.white),
        iconSize: 21,
        constraints: const BoxConstraints.tightFor(width: 42, height: 42),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final Tower? selectedTower;
  final Enemy? selectedEnemy;
  final TowerType selectedPlacementTowerType;

  GamePainter({
    required this.engine,
    required this.selectedTower,
    required this.selectedEnemy,
    required this.selectedPlacementTowerType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final palette = engine.map.landscapePalette;

    // Map-specific background gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.topColor,
            Color.lerp(palette.topColor, palette.bottomColor, 0.48)!,
            palette.bottomColor,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    _drawScenery(canvas, size);

    // Draw grid
    _drawGrid(canvas, size);

    _drawMapPath(canvas);

    if (!engine.isGameOver && !engine.isVictory) {
      _drawTowerPlaceholders(
        canvas,
        showRangePreviews: engine.isPlacementStage,
      );
    }

    // Draw towers
    for (final tower in engine.towers) {
      _drawTower(canvas, tower, isSelected: selectedTower?.id == tower.id);
    }

    // Draw enemies
    for (final enemy in engine.enemies) {
      _drawEnemy(canvas, enemy, isSelected: selectedEnemy?.id == enemy.id);
    }

    // Draw projectiles
    for (final projectile in engine.projectiles) {
      _drawProjectile(canvas, projectile);
    }

    for (final effect in engine.blastEffects) {
      _drawBlastEffect(canvas, effect);
    }

    // During play, show range only for the selected tower. Placement-stage
    // previews are drawn with the configurable tower slots above.
    if (engine.isPlayStage && selectedTower != null) {
      final tower = selectedTower!;
      canvas.drawCircle(
        tower.position,
        tower.range,
        Paint()
          ..color = tower.color.withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        tower.position,
        tower.range,
        Paint()
          ..color = tower.color.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawScenery(Canvas canvas, Size size) {
    for (final item in engine.map.scenery) {
      canvas.save();
      canvas.translate(
        item.position.dx * size.width,
        item.position.dy * size.height,
      );
      canvas.rotate(item.rotation);

      switch (item.type) {
        case SceneryType.tree:
          _drawTree(canvas, item.scale);
          break;
        case SceneryType.rock:
          _drawRock(canvas, item.scale);
          break;
        case SceneryType.mountain:
          _drawMountain(canvas, item.scale);
          break;
        case SceneryType.sand:
          _drawSand(canvas, item.scale);
          break;
        case SceneryType.lake:
          _drawLake(canvas, item.scale);
          break;
      }
      canvas.restore();
    }
  }

  void _drawTree(Canvas canvas, double scale) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(4 * scale, 18 * scale),
        width: 54 * scale,
        height: 18 * scale,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * scale),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 8 * scale),
          width: 9 * scale,
          height: 34 * scale,
        ),
        Radius.circular(4 * scale),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8B5A3C), Color(0xFF4E342E)],
        ).createShader(
            Rect.fromLTWH(-6 * scale, -10 * scale, 12 * scale, 36 * scale)),
    );

    final crownRect = Rect.fromCenter(
      center: Offset(0, -15 * scale),
      width: 58 * scale,
      height: 50 * scale,
    );
    final crownPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.45),
        colors: [Color(0xFF8BCB72), Color(0xFF2E7D4D), Color(0xFF174A38)],
      ).createShader(crownRect);
    canvas.drawCircle(Offset(-15 * scale, -10 * scale), 17 * scale, crownPaint);
    canvas.drawCircle(Offset(14 * scale, -11 * scale), 19 * scale, crownPaint);
    canvas.drawCircle(Offset(0, -25 * scale), 22 * scale, crownPaint);
  }

  void _drawRock(Canvas canvas, double scale) {
    final rockPath = Path()
      ..moveTo(-27 * scale, 13 * scale)
      ..quadraticBezierTo(-31 * scale, -5 * scale, -15 * scale, -18 * scale)
      ..quadraticBezierTo(8 * scale, -29 * scale, 25 * scale, -8 * scale)
      ..quadraticBezierTo(31 * scale, 8 * scale, 18 * scale, 17 * scale)
      ..close();
    final bounds = rockPath.getBounds();
    canvas.drawPath(
      rockPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB0B7BA), Color(0xFF68747A), Color(0xFF37474F)],
        ).createShader(bounds),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-14 * scale, -12 * scale)
        ..quadraticBezierTo(0, -23 * scale, 12 * scale, -14 * scale)
        ..quadraticBezierTo(1 * scale, -8 * scale, -14 * scale, -12 * scale),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawMountain(Canvas canvas, double scale) {
    final mountainPath = Path()
      ..moveTo(-48 * scale, 24 * scale)
      ..lineTo(-10 * scale, -42 * scale)
      ..lineTo(5 * scale, -20 * scale)
      ..lineTo(20 * scale, -38 * scale)
      ..lineTo(52 * scale, 24 * scale)
      ..close();
    canvas.drawPath(
      mountainPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA8B0B5), Color(0xFF59656B), Color(0xFF303A40)],
        ).createShader(mountainPath.getBounds()),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-10 * scale, -42 * scale)
        ..lineTo(-21 * scale, -22 * scale)
        ..lineTo(-7 * scale, -27 * scale)
        ..lineTo(0, -17 * scale)
        ..lineTo(5 * scale, -20 * scale)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );
  }

  void _drawSand(Canvas canvas, double scale) {
    final oval = Rect.fromCenter(
      center: Offset.zero,
      width: 95 * scale,
      height: 48 * scale,
    );
    canvas.drawOval(
      oval,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFE8C982), Color(0xFFB78348)],
        ).createShader(oval),
    );
    for (var i = -1; i <= 1; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(i * 18 * scale, 2 * scale),
          width: 30 * scale,
          height: 12 * scale,
        ),
        3.35,
        2.5,
        false,
        Paint()
          ..color = const Color(0xFF8D6238).withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * scale,
      );
    }
  }

  void _drawLake(Canvas canvas, double scale) {
    final lakeRect = Rect.fromCenter(
      center: Offset.zero,
      width: 105 * scale,
      height: 58 * scale,
    );
    canvas.drawOval(
      lakeRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          colors: [Color(0xFF8DE5E7), Color(0xFF348FA8), Color(0xFF1F607D)],
        ).createShader(lakeRect),
    );
    canvas.drawArc(
      lakeRect.deflate(7 * scale),
      3.4,
      2.25,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTowerPlaceholders(
    Canvas canvas, {
    required bool showRangePreviews,
  }) {
    final selectedConfig = towerConfigs[selectedPlacementTowerType]!;
    for (var i = 0; i < engine.towerSlots.length; i++) {
      final slot = engine.towerSlots[i];
      final tower = engine.towerAtSlot(i);
      final occupied = tower != null;
      if (!showRangePreviews && occupied) continue;
      final range = tower?.range ?? selectedConfig.range;
      final color = tower?.color ?? selectedConfig.color;

      if (showRangePreviews) {
        canvas.drawCircle(
          slot,
          range,
          Paint()
            ..color = color.withValues(alpha: 0.08)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          slot,
          range,
          Paint()
            ..color = color.withValues(alpha: 0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
      canvas.drawCircle(
        slot,
        18,
        Paint()
          ..color = occupied
              ? Colors.amber.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        slot,
        20,
        Paint()
          ..color = occupied ? Colors.amberAccent : Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      if (!occupied) {
        canvas.drawLine(
          slot + const Offset(-7, 0),
          slot + const Offset(7, 0),
          Paint()
            ..color = Colors.white70
            ..strokeWidth = 2,
        );
        canvas.drawLine(
          slot + const Offset(0, -7),
          slot + const Offset(0, 7),
          Paint()
            ..color = Colors.white70
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _drawMapPath(Canvas canvas) {
    final path = Path()..moveTo(engine.path.first.dx, engine.path.first.dy);
    for (final point in engine.path.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2C2435)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 48,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 36,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFBCAAA4)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2,
    );

    for (final line in engine.map.scaledStartLines(engine.screenSize)) {
      _drawLineMarker(
          canvas, line.from, line.to, Colors.lightGreenAccent, 'START');
    }
    for (final line in engine.map.scaledEndLines(engine.screenSize)) {
      _drawLineMarker(canvas, line.from, line.to, Colors.redAccent, 'END');
    }
  }

  void _drawLineMarker(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
    String label,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final midpoint = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    textPainter.paint(canvas, midpoint + const Offset(6, -6));
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridSize = 50.0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawTower(Canvas canvas, Tower tower, {bool isSelected = false}) {
    final base = tower.position;
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawOval(
        Rect.fromCenter(
            center: base + const Offset(0, 12), width: 30, height: 9),
        shadow);
    _drawPixelRect(canvas, base + const Offset(-11, 2), const Size(22, 14),
        const Color(0xFF5D4037));

    switch (tower.type) {
      case TowerType.archer:
        _drawPixelRect(canvas, base + const Offset(-7, -18), const Size(14, 22),
            const Color(0xFF2E7D32));
        _drawPixelRect(canvas, base + const Offset(-3, -24), const Size(6, 8),
            const Color(0xFFFFCC80));
        _drawPixelRect(canvas, base + const Offset(6, -15), const Size(14, 3),
            Colors.white70);
        break;
      case TowerType.magic:
        _drawPixelRect(canvas, base + const Offset(-8, -19), const Size(16, 23),
            const Color(0xFF6A1B9A));
        canvas.drawCircle(
            base + const Offset(0, -24), 6, Paint()..color = Colors.cyanAccent);
        canvas.drawCircle(base + const Offset(0, -24), 10,
            Paint()..color = Colors.cyanAccent.withValues(alpha: 0.18));
        break;
      case TowerType.cannon:
        _drawPixelRect(canvas, base + const Offset(-12, -10),
            const Size(24, 14), const Color(0xFF8B1A1A));
        _drawPixelRect(canvas, base + const Offset(3, -17), const Size(18, 8),
            const Color(0xFF37474F));
        _drawPixelRect(canvas, base + const Offset(-8, 6), const Size(16, 6),
            const Color(0xFF263238));
        break;
      case TowerType.slowerer:
        _drawPixelRect(canvas, base + const Offset(-8, -17), const Size(16, 21),
            const Color(0xFF087F8C));
        _drawPixelRect(canvas, base + const Offset(-3, -27), const Size(6, 13),
            const Color(0xFFB2EBF2));
        canvas.drawCircle(
          base + const Offset(0, -28),
          7,
          Paint()..color = Colors.cyanAccent.withValues(alpha: 0.85),
        );
        canvas.drawCircle(
          base + const Offset(0, -28),
          12,
          Paint()
            ..color = Colors.cyanAccent.withValues(alpha: 0.24)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        break;
    }

    // Selected tower ring
    if (isSelected) {
      canvas.drawCircle(
        tower.position,
        tower.radius + 10,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Upgrade indicator
    if (tower.upgrades > 0) {
      canvas.drawCircle(
        tower.position,
        tower.radius + 6,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawEnemy(Canvas canvas, Enemy enemy, {bool isSelected = false}) {
    final base = enemy.position;
    if (enemy.isUnderMagicEffect) {
      _drawMagicCloud(canvas, enemy);
    }
    if (enemy.isSlowed) {
      canvas.drawCircle(
        base,
        enemy.radius + 6,
        Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.16)
          ..style = PaintingStyle.fill,
      );
      canvas.drawArc(
        Rect.fromCircle(center: base, radius: enemy.radius + 7),
        -0.3,
        4.7,
        false,
        Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (isSelected) {
      canvas.drawCircle(
        base,
        enemy.radius + 9,
        Paint()
          ..color = Colors.cyanAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
          center: base + const Offset(0, 10),
          width: enemy.radius * 2.2,
          height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    switch (enemy.type) {
      case EnemyType.goblin:
        _drawGoblin(canvas, base, enemy.color);
        break;
      case EnemyType.runner:
        _drawRunner(canvas, base, enemy.color);
        break;
      case EnemyType.brute:
        _drawBrute(canvas, base, enemy.color);
        break;
    }

    // Health bar
    final healthPercent = enemy.health / enemy.maxHealth;
    canvas.drawRect(
      Rect.fromLTWH(
        enemy.position.dx - enemy.radius,
        enemy.position.dy - enemy.radius - 8,
        enemy.radius * 2 * healthPercent,
        3,
      ),
      Paint()..color = Colors.green,
    );

    // Health bar background
    canvas.drawRect(
      Rect.fromLTWH(
        enemy.position.dx - enemy.radius,
        enemy.position.dy - enemy.radius - 8,
        enemy.radius * 2,
        3,
      ),
      Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawMagicCloud(Canvas canvas, Enemy enemy) {
    final pulse = (math.sin(enemy.movementClock * 6) + 1) / 2;
    final center = enemy.position + const Offset(0, -3);

    canvas.drawCircle(
      center,
      enemy.radius + 13 + (pulse * 3),
      Paint()
        ..color = Colors.deepPurpleAccent.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    const cloudOffsets = [
      Offset(-12, -4),
      Offset(-5, -11),
      Offset(5, -9),
      Offset(13, -2),
      Offset(2, 2),
    ];
    for (var i = 0; i < cloudOffsets.length; i++) {
      final drift = math.sin((enemy.movementClock * 4) + i) * 2.5;
      final cloudCenter = center + cloudOffsets[i] + Offset(0, drift);
      final radius = (7.0 + (i.isEven ? 2 : 0)) + (pulse * 1.5);
      canvas.drawCircle(
        cloudCenter,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.purpleAccent.withValues(alpha: 0.54),
              Colors.deepPurple.withValues(alpha: 0.08),
            ],
          ).createShader(Rect.fromCircle(center: cloudCenter, radius: radius)),
      );
    }

    for (var i = 0; i < 3; i++) {
      final angle = enemy.movementClock * 2.4 + (i * 2.094);
      final sparkle = center +
          Offset(
            math.cos(angle) * (enemy.radius + 12),
            math.sin(angle) * 8 - 5,
          );
      canvas.drawCircle(
        sparkle,
        1.8 + pulse,
        Paint()..color = Colors.purpleAccent.withValues(alpha: 0.9),
      );
    }
  }

  void _drawGoblin(Canvas canvas, Offset base, Color color) {
    _drawPixelRect(
        canvas, base + const Offset(-7, -8), const Size(14, 14), color);
    _drawPixelRect(canvas, base + const Offset(-11, -5), const Size(4, 4),
        Colors.green.shade200);
    _drawPixelRect(canvas, base + const Offset(7, -5), const Size(4, 4),
        Colors.green.shade200);
    _drawPixelRect(
        canvas, base + const Offset(-4, -4), const Size(3, 3), Colors.black);
    _drawPixelRect(
        canvas, base + const Offset(2, -4), const Size(3, 3), Colors.black);
    _drawPixelRect(canvas, base + const Offset(-5, 6), const Size(4, 6),
        const Color(0xFF4E342E));
    _drawPixelRect(canvas, base + const Offset(2, 6), const Size(4, 6),
        const Color(0xFF4E342E));
  }

  void _drawRunner(Canvas canvas, Offset base, Color color) {
    _drawPixelRect(
        canvas, base + const Offset(-6, -7), const Size(12, 12), color);
    _drawPixelRect(canvas, base + const Offset(-2, -14), const Size(4, 6),
        Colors.lime.shade100);
    _drawPixelRect(canvas, base + const Offset(-9, 4), const Size(5, 8),
        const Color(0xFF33691E));
    _drawPixelRect(canvas, base + const Offset(4, 4), const Size(5, 8),
        const Color(0xFF33691E));
    _drawPixelRect(
        canvas, base + const Offset(-3, -3), const Size(2, 2), Colors.black);
    _drawPixelRect(
        canvas, base + const Offset(2, -3), const Size(2, 2), Colors.black);
  }

  void _drawBrute(Canvas canvas, Offset base, Color color) {
    _drawPixelRect(
        canvas, base + const Offset(-11, -11), const Size(22, 19), color);
    _drawPixelRect(canvas, base + const Offset(-14, -7), const Size(5, 6),
        const Color(0xFFFFE0B2));
    _drawPixelRect(canvas, base + const Offset(9, -7), const Size(5, 6),
        const Color(0xFFFFE0B2));
    _drawPixelRect(
        canvas, base + const Offset(-5, -4), const Size(3, 3), Colors.black);
    _drawPixelRect(
        canvas, base + const Offset(3, -4), const Size(3, 3), Colors.black);
    _drawPixelRect(canvas, base + const Offset(-7, 8), const Size(5, 7),
        const Color(0xFF3E2723));
    _drawPixelRect(canvas, base + const Offset(2, 8), const Size(5, 7),
        const Color(0xFF3E2723));
  }

  void _drawPixelRect(Canvas canvas, Offset topLeft, Size size, Color color) {
    canvas.drawRect(topLeft & size, Paint()..color = color);
  }

  void _drawProjectile(Canvas canvas, Projectile projectile) {
    if (projectile.sourceTowerType == TowerType.slowerer) {
      canvas.drawLine(
        projectile.source,
        projectile.position,
        Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.18)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawLine(
        projectile.source,
        projectile.position,
        Paint()
          ..color = Colors.lightBlueAccent.withValues(alpha: 0.82)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Projectile glow
    canvas.drawCircle(
      projectile.position,
      projectile.radius + 2,
      Paint()
        ..color = projectile.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Projectile body
    canvas.drawCircle(
      projectile.position,
      projectile.radius,
      Paint()..color = projectile.color,
    );
  }

  void _drawBlastEffect(Canvas canvas, BlastEffect effect) {
    final progress = effect.progress;
    final fade = 1 - progress;
    final radius =
        effect.radius * (0.3 + (0.7 * Curves.easeOut.transform(progress)));

    canvas.drawCircle(
      effect.position,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.50 * fade),
            Colors.amberAccent.withValues(alpha: 0.42 * fade),
            Colors.deepOrange.withValues(alpha: 0.22 * fade),
            Colors.transparent,
          ],
          stops: const [0, 0.24, 0.62, 1],
        ).createShader(
            Rect.fromCircle(center: effect.position, radius: radius)),
    );
    canvas.drawCircle(
      effect.position,
      radius,
      Paint()
        ..color = Colors.orangeAccent.withValues(alpha: 0.72 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * fade.clamp(0.25, 1.0),
    );

    for (var i = 0; i < 8; i++) {
      final angle = (i * 0.785398) + 0.2;
      final sparkDistance = radius * (0.55 + (i.isEven ? 0.18 : 0.05));
      final spark = effect.position +
          Offset(
            math.cos(angle) * sparkDistance,
            math.sin(angle) * sparkDistance,
          );
      canvas.drawCircle(
        spark,
        (2.6 - progress).clamp(1.0, 2.6),
        Paint()..color = Colors.yellowAccent.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}

class _PlacementPanel extends StatelessWidget {
  final TowerType selectedType;
  final int towersPlaced;
  final int totalSlots;
  final int availableGold;
  final bool isPlacementStage;
  final ValueChanged<TowerType> onTypeSelected;
  final VoidCallback? onStart;

  const _PlacementPanel({
    Key? key,
    required this.selectedType,
    required this.towersPlaced,
    required this.totalSlots,
    required this.availableGold,
    required this.isPlacementStage,
    required this.onTypeSelected,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Place towers: $towersPlaced/$totalSlots',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (isPlacementStage)
                ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700),
                  child: const Text('Start Play'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: TowerType.values.map((type) {
              final selected = type == selectedType;
              final config = towerConfigs[type]!;
              final affordable = availableGold >= config.placementCost;
              return ChoiceChip(
                avatar: Icon(
                  _towerTypeIcon(type),
                  size: 17,
                  color: selected
                      ? Colors.white
                      : affordable
                          ? const Color(0xFF11194A)
                          : Colors.grey,
                ),
                label: Text(
                  '${_towerTypeLabel(type)}  ${config.placementCost}₡',
                ),
                selected: selected,
                onSelected: affordable ? (_) => onTypeSelected(type) : null,
                showCheckmark: false,
                selectedColor: config.color.withValues(alpha: 0.8),
                backgroundColor: const Color(0xFFE8ECFF),
                side: BorderSide(
                    color: selected
                        ? config.color
                        : Colors.white.withValues(alpha: 0.35)),
                labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : affordable
                            ? const Color(0xFF11194A)
                            : Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            isPlacementStage
                ? 'Tap an empty slot to place. Tap a tower to select it, then use the red minus button beside it to remove it.'
                : 'Empty slots stay open during combat. Earn gold, choose a tower, and tap a slot to expand your defense.',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _towerTypeLabel(TowerType type) {
    switch (type) {
      case TowerType.archer:
        return 'Archer';
      case TowerType.magic:
        return 'Magic';
      case TowerType.cannon:
        return 'Cannon';
      case TowerType.slowerer:
        return 'Slowerer';
    }
  }

  IconData _towerTypeIcon(TowerType type) {
    switch (type) {
      case TowerType.archer:
        return Icons.gps_fixed;
      case TowerType.magic:
        return Icons.auto_fix_high;
      case TowerType.cannon:
        return Icons.whatshot;
      case TowerType.slowerer:
        return Icons.ac_unit;
    }
  }
}

class _EnemyCharacterSheet extends StatelessWidget {
  final Enemy enemy;
  final VoidCallback onClose;

  const _EnemyCharacterSheet({
    Key? key,
    required this.enemy,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(enemy.type);
    final currentHealth = enemy.health.clamp(0.0, enemy.maxHealth);
    final healthPercent = currentHealth / enemy.maxHealth;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent),
                ),
                child: Icon(_enemyIcon(enemy.type), color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('enemy_sheet_title').toUpperCase(),
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t(_nameKey(enemy.type)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.t(_storyKey(enemy.type)),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: healthPercent,
              minHeight: 6,
              color:
                  healthPercent > 0.35 ? Colors.greenAccent : Colors.redAccent,
              backgroundColor: Colors.black26,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                label: context.t('enemy_vitality'),
                value:
                    '${currentHealth.toStringAsFixed(0)}/${enemy.maxHealth.toStringAsFixed(0)}',
              ),
              _StatChip(
                label: context.t('enemy_speed'),
                value: '${enemy.speed.toStringAsFixed(0)} px/s',
              ),
              _StatChip(
                label: context.t('enemy_movement'),
                value: context.t(_movementKey(enemy.movementPattern)),
              ),
              _StatChip(
                label: context.t('enemy_size'),
                value: context.t(_sizeKey(enemy.type)),
              ),
              _StatChip(
                label: context.t('enemy_threat'),
                value: context.t(_threatKey(enemy.type)),
              ),
              _StatChip(
                label: context.t('enemy_bounty'),
                value: '25 gold',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nameKey(EnemyType type) => 'enemy_${type.name}_name';

  String _storyKey(EnemyType type) => 'enemy_${type.name}_story';

  String _movementKey(MovementPattern pattern) {
    switch (pattern) {
      case MovementPattern.straight:
        return 'movement_straight';
      case MovementPattern.stepStopStep:
        return 'movement_step_stop_step';
    }
  }

  String _sizeKey(EnemyType type) {
    switch (type) {
      case EnemyType.runner:
        return 'size_small';
      case EnemyType.goblin:
        return 'size_medium';
      case EnemyType.brute:
        return 'size_large';
    }
  }

  String _threatKey(EnemyType type) {
    switch (type) {
      case EnemyType.goblin:
        return 'threat_low';
      case EnemyType.runner:
        return 'threat_medium';
      case EnemyType.brute:
        return 'threat_high';
    }
  }

  Color _accentColor(EnemyType type) {
    switch (type) {
      case EnemyType.goblin:
        return Colors.greenAccent;
      case EnemyType.runner:
        return Colors.limeAccent;
      case EnemyType.brute:
        return Colors.orangeAccent;
    }
  }

  IconData _enemyIcon(EnemyType type) {
    switch (type) {
      case EnemyType.goblin:
        return Icons.grass;
      case EnemyType.runner:
        return Icons.directions_run;
      case EnemyType.brute:
        return Icons.shield;
    }
  }
}

class _TowerControlPanel extends StatelessWidget {
  final Tower tower;
  final VoidCallback onUpgrade;

  const _TowerControlPanel({
    Key? key,
    required this.tower,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canUpgrade = tower.canUpgrade();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tower.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tower.color.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t(tower.nameKey),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              if (canUpgrade)
                ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: Text('Upgrade\n${tower.upgradeCost}₡',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12)),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Max level',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.t(tower.descKey),
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _StatChip(
                  label: context.t('upgrade_power'),
                  value: tower.damage.toStringAsFixed(0)),
              _StatChip(
                  label: context.t('upgrade_range'),
                  value: tower.range.toInt().toString()),
              _StatChip(
                  label: 'Blast',
                  value: tower.blastRadius <= 0
                      ? 'Direct'
                      : tower.blastRadius.toInt().toString()),
              _StatChip(
                  label: context.t('upgrade_speed'),
                  value: tower.fireRate.toStringAsFixed(1)),
              _StatChip(
                  label: context.t('level_summary'),
                  value: '${tower.upgrades}/3'),
              if (tower.type == TowerType.magic)
                _StatChip(
                  label: 'Purple curse',
                  value:
                      '${towerConfigs[tower.type]!.damagePerTick.toStringAsFixed(0)} × ${towerConfigs[tower.type]!.damageTickCount}s',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text('$label: $value',
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}
