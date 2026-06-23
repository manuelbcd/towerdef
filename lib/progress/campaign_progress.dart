class CampaignProgress {
  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final int totalGold;
  final Set<String> unlockedStageIds;
  final Set<String> completedStageIds;
  final Map<String, int> stageStars;

  const CampaignProgress({
    required this.schemaVersion,
    required this.totalGold,
    required this.unlockedStageIds,
    required this.completedStageIds,
    required this.stageStars,
  });

  factory CampaignProgress.initial(String firstStageId) {
    return CampaignProgress(
      schemaVersion: currentSchemaVersion,
      totalGold: 0,
      unlockedStageIds: {firstStageId},
      completedStageIds: const {},
      stageStars: const {},
    );
  }

  bool isUnlocked(String stageId) => unlockedStageIds.contains(stageId);

  bool isCompleted(String stageId) => completedStageIds.contains(stageId);

  int starsFor(String stageId) => stageStars[stageId] ?? 0;

  CampaignProgress recordVictory({
    required String stageId,
    required int earnedGold,
    required int earnedStars,
    required Iterable<String> unlockedNextStageIds,
  }) {
    final firstCompletion = !completedStageIds.contains(stageId);
    return CampaignProgress(
      schemaVersion: currentSchemaVersion,
      totalGold: totalGold + (firstCompletion ? earnedGold : 0),
      unlockedStageIds: {
        ...unlockedStageIds,
        ...unlockedNextStageIds,
      },
      completedStageIds: {...completedStageIds, stageId},
      stageStars: {
        ...stageStars,
        stageId:
            earnedStars > starsFor(stageId) ? earnedStars : starsFor(stageId),
      },
    );
  }

  Map<String, Object> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'totalGold': totalGold,
      'unlockedStageIds': unlockedStageIds.toList()..sort(),
      'completedStageIds': completedStageIds.toList()..sort(),
      'stageStars': stageStars,
    };
  }

  factory CampaignProgress.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int? ?? 1;
    if (schemaVersion > currentSchemaVersion) {
      throw StateError('Unsupported campaign progress version $schemaVersion');
    }
    return CampaignProgress(
      schemaVersion: currentSchemaVersion,
      totalGold: json['totalGold'] as int? ?? 0,
      unlockedStageIds:
          ((json['unlockedStageIds'] as List<dynamic>?) ?? const [])
              .cast<String>()
              .toSet(),
      completedStageIds:
          ((json['completedStageIds'] as List<dynamic>?) ?? const [])
              .cast<String>()
              .toSet(),
      stageStars: ((json['stageStars'] as Map<String, dynamic>?) ?? const {})
          .map((key, value) => MapEntry(key, value as int)),
    );
  }
}
