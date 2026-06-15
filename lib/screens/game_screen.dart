import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../game/game_engine.dart';
import '../models/tower.dart';
import '../audio/audio_manager.dart';
import '../widgets/volume_controls.dart';
import '../models/enemy.dart';
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
      final delta = lastElapsed == null ? 0.0 : (elapsed - lastElapsed!).inMicroseconds / 1e6;
      lastElapsed = elapsed;
      if (engine == null) return;
      engine!.update(delta);
      setState(() {});
    });
    ticker?.start();
  }

  void _selectTower(Tower tower) {
    setState(() {
      selectedTower = selectedTower?.id == tower.id ? null : tower;
    });
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
    Tower? tappedTower;
    for (final tower in engine!.towers) {
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
    setState(() {
      engine = GameEngine(screenSize: engine.screenSize);
      selectedTower = null;
    });
    _startGameLoop();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAreaHeight = MediaQuery.of(context).size.height * 0.7;

    if (engine == null) {
      return const Scaffold(
        backgroundColor: Colors.indigo,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.indigo.shade950,
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
                  painter: GamePainter(engine: engine!, selectedTower: selectedTower),
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
                        Expanded(child: Text('💰 ${engine!.coins}', style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontWeight: FontWeight.bold))),
                        Expanded(child: Text('❤️ ${engine!.health}', style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Wave ${engine!.wave}', style: const TextStyle(fontSize: 16, color: Colors.cyan, fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Kills ${engine!.kills}', style: const TextStyle(fontSize: 16, color: Colors.greenAccent, fontWeight: FontWeight.bold))),
                        ElevatedButton(onPressed: _resetGame, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700), child: const Text('Restart')),
                        IconButton(
                          onPressed: _openSettingsSheet,
                          icon: const Icon(Icons.settings, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tower controls
                    if (selectedTower != null) ...[
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
                    if (engine.isGameOver) ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Game Over!', style: TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text('Wave reached: ${engine.wave}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
                              Text('Total kills: ${engine.kills}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
                              const SizedBox(height: 20),
                              ElevatedButton(onPressed: _resetGame, child: const Text('Play Again')),
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

  GamePainter({required this.engine, this.selectedTower});

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade900, Colors.black87, Colors.deepPurple.shade900],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw grid
    _drawGrid(canvas, size);

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
          ..color = tower.color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridSize = 50.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawTower(Canvas canvas, Tower tower, {bool isSelected = false}) {
    // Tower body
    canvas.drawCircle(
      tower.position,
      tower.radius,
      Paint()..color = tower.color,
    );

    // Tower outline
    canvas.drawCircle(
      tower.position,
      tower.radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Selected tower ring
    if (isSelected) {
      canvas.drawCircle(
        tower.position,
        tower.radius + 10,
        Paint()
          ..color = Colors.white.withOpacity(0.35)
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
          ..color = Colors.yellow.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawEnemy(Canvas canvas, Enemy enemy) {
    // Enemy body
    canvas.drawCircle(
      enemy.position,
      enemy.radius,
      Paint()..color = enemy.color,
    );

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
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawProjectile(Canvas canvas, Projectile projectile) {
    // Projectile glow
    canvas.drawCircle(
      projectile.position,
      projectile.radius + 2,
      Paint()
        ..color = projectile.color.withOpacity(0.3)
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
        color: tower.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tower.color.withOpacity(0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t(tower.nameKey), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              if (canUpgrade)
                ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text('Upgrade\n${tower.upgradeCost}₡', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Max level', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.t(tower.descKey), style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _StatChip(label: context.t('upgrade_power'), value: tower.damage.toStringAsFixed(0)),
              _StatChip(label: context.t('upgrade_range'), value: tower.range.toInt().toString()),
              _StatChip(label: context.t('upgrade_speed'), value: tower.fireRate.toStringAsFixed(1)),
              _StatChip(label: context.t('level_summary'), value: '${tower.upgrades}/3'),
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

  const _StatChip({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text('$label: $value', style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}
