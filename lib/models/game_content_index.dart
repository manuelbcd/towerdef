import 'campaign.dart';
import 'encounter.dart';
import 'game_config.dart';
import 'game_map.dart';

class ContentValidationException implements Exception {
  final List<String> errors;

  const ContentValidationException(this.errors);

  @override
  String toString() => 'Invalid game content:\n${errors.join('\n')}';
}

class GameContentIndex {
  final Map<String, GameMap> maps;
  final Map<String, EncounterDefinition> encounters;
  final Map<String, GameRulesDefinition> rulesets;
  final Map<String, CampaignStageDefinition> stages;
  final Map<String, CampaignDefinition> campaigns;
  final Map<TowerType, TowerDefinition> towers;
  final Map<EnemyType, EnemyDefinition> enemies;

  GameContentIndex({
    required Iterable<GameMap> maps,
    required this.encounters,
    required this.rulesets,
    required this.stages,
    required this.campaigns,
    required this.towers,
    required this.enemies,
  }) : maps = {for (final map in maps) map.id: map};

  List<String> validate() {
    final errors = <String>[];

    for (final encounter in encounters.values) {
      if (encounter.waves.isEmpty) {
        errors.add('Encounter ${encounter.id} has no waves.');
      }
      for (final wave in encounter.waves) {
        for (final group in wave.enemyGroups) {
          if (!enemies.containsKey(group.type)) {
            errors.add('Encounter ${encounter.id} references ${group.type}.');
          }
        }
      }
    }

    for (final stage in stages.values) {
      final map = maps[stage.mapId];
      if (map == null) errors.add('Stage ${stage.id} has unknown map.');
      final encounter = encounters[stage.encounterId];
      if (encounter == null) {
        errors.add('Stage ${stage.id} has unknown encounter.');
      }
      if (!rulesets.containsKey(stage.rulesetId)) {
        errors.add('Stage ${stage.id} has unknown ruleset.');
      }
      for (final nextId in stage.nextStageIds) {
        if (!stages.containsKey(nextId)) {
          errors.add('Stage ${stage.id} has unknown next stage $nextId.');
        }
      }
      if (map != null && encounter != null) {
        final routeIds = map.routes.map((route) => route.id).toSet();
        for (final group
            in encounter.waves.expand((wave) => wave.enemyGroups)) {
          if (group.routeId != null && !routeIds.contains(group.routeId)) {
            errors.add(
              'Stage ${stage.id} encounter uses unknown route ${group.routeId}.',
            );
          }
        }
      }
    }

    for (final campaign in campaigns.values) {
      if (!stages.containsKey(campaign.firstStageId)) {
        errors.add('Campaign ${campaign.id} has unknown first stage.');
      }
      for (final chapter in campaign.chapters) {
        for (final stageId in chapter.stageIds) {
          if (!stages.containsKey(stageId)) {
            errors.add('Chapter ${chapter.id} has unknown stage $stageId.');
          }
        }
      }
    }

    for (final rules in rulesets.values) {
      for (final towerType in rules.availableTowerTypes) {
        if (!towers.containsKey(towerType)) {
          errors.add('Ruleset ${rules.id} references $towerType.');
        }
      }
    }
    return errors;
  }

  void validateOrThrow() {
    final errors = validate();
    if (errors.isNotEmpty) throw ContentValidationException(errors);
  }

  GameSessionConfig resolveStage(String stageId) {
    final stage = stages[stageId];
    if (stage == null) throw StateError('Unknown stage $stageId');
    return GameSessionConfig(
      stage: stage,
      map: maps[stage.mapId]!,
      encounter: encounters[stage.encounterId]!,
      rules: rulesets[stage.rulesetId]!,
    );
  }
}

final gameContentIndex = GameContentIndex(
  maps: gameMaps,
  encounters: encounterCatalog,
  rulesets: campaignRulesCatalog,
  stages: campaignStages,
  campaigns: campaignCatalog,
  towers: towerCatalog,
  enemies: enemyCatalog,
);
