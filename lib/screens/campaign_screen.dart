import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/campaign.dart';
import '../models/game_content_index.dart';
import '../progress/campaign_progress.dart';

class CampaignScreen extends StatelessWidget {
  final GameContentIndex content;
  final CampaignProgress progress;
  final ValueChanged<CampaignStageDefinition> onStageSelected;

  const CampaignScreen({
    super.key,
    required this.content,
    required this.progress,
    required this.onStageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final campaign = content.campaigns.values.first;
    return Scaffold(
      backgroundColor: const Color(0xFF10183F),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(campaign.titleKey),
                      key: const Key('campaign-title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t(campaign.descriptionKey),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    Chip(
                      avatar: const Icon(Icons.savings, color: Colors.amber),
                      label: Text('${progress.totalGold} campaign gold'),
                    ),
                  ],
                ),
              ),
            ),
            for (final chapter in campaign.chapters) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.t(chapter.titleKey),
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: chapter.stageIds.length,
                  itemBuilder: (context, index) {
                    final stage = content.stages[chapter.stageIds[index]]!;
                    return _StageTile(
                      stage: stage,
                      mapName: content.maps[stage.mapId]!.name,
                      unlocked: progress.isUnlocked(stage.id),
                      completed: progress.isCompleted(stage.id),
                      stars: progress.starsFor(stage.id),
                      onTap: () => onStageSelected(stage),
                    );
                  },
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  final CampaignStageDefinition stage;
  final String mapName;
  final bool unlocked;
  final bool completed;
  final int stars;
  final VoidCallback onTap;

  const _StageTile({
    required this.stage,
    required this.mapName,
    required this.unlocked,
    required this.completed,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('stage-${stage.id}'),
      color: unlocked ? const Color(0xFF26366E) : const Color(0xFF202542),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        enabled: unlocked,
        onTap: unlocked ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: completed ? Colors.green : Colors.indigo,
          child: Icon(
            unlocked
                ? completed
                    ? Icons.check
                    : Icons.flag
                : Icons.lock,
            color: Colors.white,
          ),
        ),
        title: Text(
          context.t(stage.titleKey),
          style: TextStyle(color: unlocked ? Colors.white : Colors.white38),
        ),
        subtitle: Text(
          mapName,
          style: TextStyle(color: unlocked ? Colors.white60 : Colors.white24),
        ),
        trailing: completed
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  stars,
                  (_) => const Icon(Icons.star, color: Colors.amber, size: 17),
                ),
              )
            : null,
      ),
    );
  }
}
