import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/campaign.dart';
import '../models/game_content_index.dart';
import 'campaign_progress.dart';

abstract class CampaignProgressStore {
  Future<String?> read();

  Future<void> write(String value);
}

class SharedPreferencesCampaignProgressStore implements CampaignProgressStore {
  static const storageKey = 'towerdef.campaign_progress.v1';
  final SharedPreferencesAsync preferences;

  SharedPreferencesCampaignProgressStore({SharedPreferencesAsync? preferences})
      : preferences = preferences ?? SharedPreferencesAsync();

  @override
  Future<String?> read() => preferences.getString(storageKey);

  @override
  Future<void> write(String value) => preferences.setString(storageKey, value);
}

class InMemoryCampaignProgressStore implements CampaignProgressStore {
  String? value;

  InMemoryCampaignProgressStore([this.value]);

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class CampaignProgressRepository {
  final CampaignProgressStore store;
  final GameContentIndex content;

  CampaignProgressRepository({required this.store, required this.content});

  Future<CampaignProgress> load() async {
    final stored = await store.read();
    if (stored == null || stored.isEmpty) {
      return CampaignProgress.initial(
        content.campaigns.values.first.firstStageId,
      );
    }
    try {
      return CampaignProgress.fromJson(
        jsonDecode(stored) as Map<String, dynamic>,
      );
    } on Object {
      return CampaignProgress.initial(
        content.campaigns.values.first.firstStageId,
      );
    }
  }

  Future<CampaignProgress> recordResult({
    required CampaignProgress progress,
    required GameResult result,
  }) async {
    if (!result.victory) return progress;
    final stage = content.stages[result.stageId]!;
    final updated = progress.recordVictory(
      stageId: stage.id,
      earnedGold: stage.rewards.gold,
      earnedStars: stage.rewards.stars,
      unlockedNextStageIds: stage.nextStageIds,
    );
    await store.write(jsonEncode(updated.toJson()));
    return updated;
  }
}
