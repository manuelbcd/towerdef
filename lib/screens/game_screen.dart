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

    if (currentEngine.isPlacementStage) {
      final slotIndex = currentEngine.slotIndexAt(localPosition);
      if (slotIndex == null) return;

      setState(() {
        currentEngine.placeTowerAtSlot(slotIndex, selectedPlacementTowerType);
        selectedTower = currentEngine.towerAtSlot(slotIndex);
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
    });
    _startGameLoop();
  }

  void _startPlayStage() {
    final currentEngine = engine;
    if (currentEngine == null || currentEngine.towers.isEmpty) return;

    setState(() {
      currentEngine.startPlay();
      selectedTower = null;
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
                child: CustomPaint(
                  painter: GamePainter(
                    engine: currentEngine,
                    selectedTower: selectedTower,
                    selectedPlacementTowerType: selectedPlacementTowerType,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
            // UI Area
            Expanded(
              child: Container(
                color: Colors.indigo.shade900,
                padding: const EdgeInsets.all(16),
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
                          icon: const Icon(Icons.settings, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tower controls
                    if (currentEngine.isPlacementStage) ...[
                      _PlacementPanel(
                        selectedType: selectedPlacementTowerType,
                        towersPlaced: currentEngine.towers.length,
                        onTypeSelected: (type) {
                          setState(() {
                            selectedPlacementTowerType = type;
                          });
                        },
                        onStart: currentEngine.towers.isEmpty
                            ? null
                            : _startPlayStage,
                      ),
                    ] else if (selectedTower != null) ...[
                      _TowerControlPanel(
                        tower: selectedTower!,
                        onUpgrade: _upgradeTower,
                      ),
                    ] else
                      Text(
                        'Tap a tower to select',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    const SizedBox(height: 12),
                    // Game over
                    if (currentEngine.isGameOver) ...[
                      Expanded(
                        child: Center(
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
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final Tower? selectedTower;
  final TowerType selectedPlacementTowerType;

  GamePainter({
    required this.engine,
    required this.selectedTower,
    required this.selectedPlacementTowerType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900,
            Colors.black87,
            Colors.deepPurple.shade900
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw grid
    _drawGrid(canvas, size);

    _drawMapPath(canvas);

    if (engine.isPlacementStage) {
      _drawTowerPlaceholders(canvas);
    }

    // Draw towers
    for (final tower in engine.towers) {
      _drawTower(canvas, tower, isSelected: selectedTower?.id == tower.id);
    }

    // Draw enemies
    for (final enemy in engine.enemies) {
      _drawEnemy(canvas, enemy);
    }

    // Draw projectiles
    for (final projectile in engine.projectiles) {
      _drawProjectile(canvas, projectile);
    }

    // Draw tower ranges
    for (final tower in engine.towers) {
      canvas.drawCircle(
        tower.position,
        tower.range,
        Paint()
          ..color = tower.color.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawTowerPlaceholders(Canvas canvas) {
    final selectedConfig = towerConfigs[selectedPlacementTowerType]!;
    for (var i = 0; i < engine.towerSlots.length; i++) {
      final slot = engine.towerSlots[i];
      final tower = engine.towerAtSlot(i);
      final occupied = tower != null;
      final range = tower?.range ?? selectedConfig.range;
      final color = tower?.color ?? selectedConfig.color;

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

  void _drawEnemy(Canvas canvas, Enemy enemy) {
    final base = enemy.position;
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

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}

class _PlacementPanel extends StatelessWidget {
  final TowerType selectedType;
  final int towersPlaced;
  final ValueChanged<TowerType> onTypeSelected;
  final VoidCallback? onStart;

  const _PlacementPanel({
    Key? key,
    required this.selectedType,
    required this.towersPlaced,
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
                  'Place towers: $towersPlaced/5',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
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
              return ChoiceChip(
                label: Text(_towerTypeLabel(type)),
                selected: selected,
                onSelected: (_) => onTypeSelected(type),
                showCheckmark: false,
                selectedColor: towerConfigs[type]!.color.withValues(alpha: 0.8),
                backgroundColor: const Color(0xFFE8ECFF),
                side: BorderSide(
                    color: selected
                        ? towerConfigs[type]!.color
                        : Colors.white.withValues(alpha: 0.35)),
                labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF11194A),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap a highlighted slot on the map to place or replace a tower.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
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
