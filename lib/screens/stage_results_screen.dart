import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/campaign.dart';

class StageResultsScreen extends StatelessWidget {
  final GameResult result;
  final CampaignStageDefinition stage;
  final VoidCallback onCampaign;
  final VoidCallback? onContinue;

  const StageResultsScreen({
    super.key,
    required this.result,
    required this.stage,
    required this.onCampaign,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final color = result.victory ? Colors.greenAccent : Colors.redAccent;
    return Scaffold(
      backgroundColor: const Color(0xFF11183D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  result.victory ? Icons.emoji_events : Icons.shield_outlined,
                  color: color,
                  size: 72,
                ),
                const SizedBox(height: 14),
                Text(
                  result.victory
                      ? context.t('stage_complete')
                      : context.t('stage_failed'),
                  key: const Key('results-title'),
                  style: TextStyle(
                    color: color,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.t(stage.titleKey),
                  style: const TextStyle(color: Colors.white, fontSize: 19),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _ResultChip(label: 'Kills', value: '${result.kills}'),
                    _ResultChip(label: 'Wave', value: '${result.wave}'),
                    if (result.victory)
                      _ResultChip(
                        label: 'Reward',
                        value: '${stage.rewards.gold} gold',
                      ),
                  ],
                ),
                if (result.victory) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      stage.rewards.stars,
                      (_) => const Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (onContinue != null)
                  FilledButton(
                    key: const Key('continue-stage'),
                    onPressed: onContinue,
                    child: Text(context.t('continue_campaign')),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  key: const Key('return-campaign'),
                  onPressed: onCampaign,
                  child: Text(context.t('campaign_map')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final String value;

  const _ResultChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
