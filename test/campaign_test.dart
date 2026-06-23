import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towerdef/game/game_engine.dart';
import 'package:towerdef/models/campaign.dart';
import 'package:towerdef/models/game_content_index.dart';
import 'package:towerdef/progress/campaign_progress.dart';
import 'package:towerdef/progress/campaign_progress_repository.dart';

void main() {
  test('Default content index validates and resolves complete sessions', () {
    expect(gameContentIndex.validate(), isEmpty);

    final green = gameContentIndex.resolveStage('green_pass_01');
    final ember = gameContentIndex.resolveStage('ember_turns_01');

    expect(green.map.id, 'green_pass');
    expect(green.encounter.id, 'border_patrol');
    expect(green.rules.startingGold, 500);
    expect(green.encounter, same(ember.encounter),
        reason: 'Encounters should be reusable across maps');
  });

  test('Content validation catches broken stage references', () {
    const broken = CampaignStageDefinition(
      id: 'broken',
      titleKey: 'broken',
      descriptionKey: 'broken',
      kind: StageKind.battle,
      mapId: 'missing_map',
      encounterId: 'missing_encounter',
      rulesetId: 'missing_rules',
      rewards: StageRewards(gold: 0, stars: 0),
      nextStageIds: ['missing_next'],
    );
    final index = GameContentIndex(
      maps: gameContentIndex.maps.values,
      encounters: gameContentIndex.encounters,
      rulesets: gameContentIndex.rulesets,
      stages: {...gameContentIndex.stages, 'broken': broken},
      campaigns: gameContentIndex.campaigns,
      towers: gameContentIndex.towers,
      enemies: gameContentIndex.enemies,
    );

    final errors = index.validate().where((error) => error.contains('broken'));
    expect(errors.length, 4);
  });

  test('Resolved campaign rules configure the game engine', () {
    final session = gameContentIndex.resolveStage('green_pass_01');
    final engine = GameEngine(
      screenSize: const Size(400, 800),
      session: session,
    );

    expect(engine.map.id, session.map.id);
    expect(engine.encounter.id, session.encounter.id);
    expect(engine.coins, session.rules.startingGold);
    expect(engine.playerLifePoints, session.rules.startingLives);
    expect(engine.availableTowerTypes, session.rules.availableTowerTypes);
  });

  test('Campaign progress serializes, unlocks, and rewards only once', () {
    final initial = CampaignProgress.initial('green_pass_01');
    final completed = initial.recordVictory(
      stageId: 'green_pass_01',
      earnedGold: 100,
      earnedStars: 3,
      unlockedNextStageIds: const ['ember_turns_01'],
    );
    final replayed = completed.recordVictory(
      stageId: 'green_pass_01',
      earnedGold: 100,
      earnedStars: 2,
      unlockedNextStageIds: const ['ember_turns_01'],
    );
    final restored = CampaignProgress.fromJson(
      jsonDecode(jsonEncode(replayed.toJson())) as Map<String, dynamic>,
    );

    expect(restored.totalGold, 100);
    expect(restored.isCompleted('green_pass_01'), true);
    expect(restored.isUnlocked('ember_turns_01'), true);
    expect(restored.starsFor('green_pass_01'), 3);
  });

  test('Progress repository persists victories and recovers corrupt data',
      () async {
    final store = InMemoryCampaignProgressStore();
    final repository = CampaignProgressRepository(
      store: store,
      content: gameContentIndex,
    );
    final initial = await repository.load();
    final updated = await repository.recordResult(
      progress: initial,
      result: const GameResult(
        stageId: 'green_pass_01',
        victory: true,
        kills: 5,
        wave: 3,
      ),
    );
    final restored = await repository.load();

    expect(updated.isUnlocked('ember_turns_01'), true);
    expect(restored.totalGold, 100);

    store.value = '{bad json';
    final recovered = await repository.load();
    expect(recovered.unlockedStageIds, {'green_pass_01'});
  });
}
