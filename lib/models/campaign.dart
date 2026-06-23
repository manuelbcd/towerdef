import 'encounter.dart';
import 'game_config.dart';
import 'game_map.dart';

enum StageKind { battle, story, tutorial, reward }

class StageRewards {
  final int gold;
  final int stars;

  const StageRewards({required this.gold, required this.stars});
}

class GameRulesDefinition {
  final String id;
  final int startingGold;
  final int startingLives;
  final List<TowerType> availableTowerTypes;

  const GameRulesDefinition({
    required this.id,
    required this.startingGold,
    required this.startingLives,
    required this.availableTowerTypes,
  });
}

class CampaignStageDefinition {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final StageKind kind;
  final String mapId;
  final String encounterId;
  final String rulesetId;
  final StageRewards rewards;
  final List<String> nextStageIds;

  const CampaignStageDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.kind,
    required this.mapId,
    required this.encounterId,
    required this.rulesetId,
    required this.rewards,
    this.nextStageIds = const [],
  });
}

class CampaignChapterDefinition {
  final String id;
  final String titleKey;
  final List<String> stageIds;

  const CampaignChapterDefinition({
    required this.id,
    required this.titleKey,
    required this.stageIds,
  });
}

class CampaignDefinition {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String firstStageId;
  final List<CampaignChapterDefinition> chapters;

  const CampaignDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.firstStageId,
    required this.chapters,
  });
}

class GameSessionConfig {
  final CampaignStageDefinition stage;
  final GameMap map;
  final EncounterDefinition encounter;
  final GameRulesDefinition rules;

  const GameSessionConfig({
    required this.stage,
    required this.map,
    required this.encounter,
    required this.rules,
  });
}

class GameResult {
  final String stageId;
  final bool victory;
  final int kills;
  final int wave;

  const GameResult({
    required this.stageId,
    required this.victory,
    required this.kills,
    required this.wave,
  });
}

const standardCampaignRules = GameRulesDefinition(
  id: 'standard_campaign',
  startingGold: 500,
  startingLives: 20,
  availableTowerTypes: TowerType.values,
);

const campaignRulesCatalog = <String, GameRulesDefinition>{
  'standard_campaign': standardCampaignRules,
};

const campaignStages = <String, CampaignStageDefinition>{
  'green_pass_01': CampaignStageDefinition(
    id: 'green_pass_01',
    titleKey: 'stage_green_pass',
    descriptionKey: 'stage_green_pass_desc',
    kind: StageKind.tutorial,
    mapId: 'green_pass',
    encounterId: 'border_patrol',
    rulesetId: 'standard_campaign',
    rewards: StageRewards(gold: 100, stars: 3),
    nextStageIds: ['ember_turns_01'],
  ),
  'ember_turns_01': CampaignStageDefinition(
    id: 'ember_turns_01',
    titleKey: 'stage_ember_turns',
    descriptionKey: 'stage_ember_turns_desc',
    kind: StageKind.battle,
    mapId: 'ember_turns',
    encounterId: 'border_patrol',
    rulesetId: 'standard_campaign',
    rewards: StageRewards(gold: 125, stars: 3),
    nextStageIds: ['river_hook_01'],
  ),
  'river_hook_01': CampaignStageDefinition(
    id: 'river_hook_01',
    titleKey: 'stage_river_hook',
    descriptionKey: 'stage_river_hook_desc',
    kind: StageKind.battle,
    mapId: 'river_hook',
    encounterId: 'mixed_assault',
    rulesetId: 'standard_campaign',
    rewards: StageRewards(gold: 150, stars: 3),
    nextStageIds: ['stone_s_01'],
  ),
  'stone_s_01': CampaignStageDefinition(
    id: 'stone_s_01',
    titleKey: 'stage_stone_s',
    descriptionKey: 'stage_stone_s_desc',
    kind: StageKind.battle,
    mapId: 'stone_s',
    encounterId: 'mixed_assault',
    rulesetId: 'standard_campaign',
    rewards: StageRewards(gold: 175, stars: 3),
    nextStageIds: ['frost_loop_01'],
  ),
  'frost_loop_01': CampaignStageDefinition(
    id: 'frost_loop_01',
    titleKey: 'stage_frost_loop',
    descriptionKey: 'stage_frost_loop_desc',
    kind: StageKind.battle,
    mapId: 'frost_loop',
    encounterId: 'heavy_siege',
    rulesetId: 'standard_campaign',
    rewards: StageRewards(gold: 250, stars: 3),
  ),
};

const realmDefenseCampaign = CampaignDefinition(
  id: 'realm_defense',
  titleKey: 'campaign_realm_defense',
  descriptionKey: 'campaign_realm_defense_desc',
  firstStageId: 'green_pass_01',
  chapters: [
    CampaignChapterDefinition(
      id: 'borderlands',
      titleKey: 'chapter_borderlands',
      stageIds: ['green_pass_01', 'ember_turns_01', 'river_hook_01'],
    ),
    CampaignChapterDefinition(
      id: 'frozen_crown',
      titleKey: 'chapter_frozen_crown',
      stageIds: ['stone_s_01', 'frost_loop_01'],
    ),
  ],
);

const campaignCatalog = <String, CampaignDefinition>{
  'realm_defense': realmDefenseCampaign,
};
