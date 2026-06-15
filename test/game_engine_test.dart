import 'package:flutter_test/flutter_test.dart';
import 'package:towerdef/game/game_engine.dart';
import 'package:flutter/material.dart';

void main() {
  test('GameEngine upgrade and coin logic', () {
    final engine = GameEngine(screenSize: const Size(400, 800));
    expect(engine.coins, 500);
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
}
