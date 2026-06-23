import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/campaign.dart';
import '../models/game_config.dart';

class StageBriefingScreen extends StatelessWidget {
  final GameSessionConfig session;
  final VoidCallback onBack;
  final VoidCallback onStart;

  const StageBriefingScreen({
    super.key,
    required this.session,
    required this.onBack,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final enemyTypes = session.encounter.waves
        .expand((wave) => wave.enemyGroups)
        .map((group) => group.type)
        .toSet();
    return Scaffold(
      backgroundColor: session.map.landscapePalette.bottomColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const Key('briefing-back'),
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            Text(
              context.t(session.stage.titleKey),
              key: const Key('briefing-title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t(session.stage.descriptionKey),
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 22),
            _BriefingPanel(
              title: session.map.name,
              icon: Icons.map,
              children: [
                Text('${session.map.routes.length} enemy route(s)'),
                Text('${session.map.towerSlots.length} build slots'),
              ],
            ),
            _BriefingPanel(
              title: context.t(session.encounter.nameKey),
              icon: Icons.groups,
              children: [
                Text('${session.encounter.waves.length} waves'),
                Text(
                  enemyTypes
                      .map((type) => context.t(enemyCatalog[type]!.nameKey))
                      .join(' • '),
                ),
              ],
            ),
            _BriefingPanel(
              title: context.t('starting_resources'),
              icon: Icons.inventory_2,
              children: [
                Text('${session.rules.startingGold} gold'),
                Text('${session.rules.startingLives} lives'),
                Text(
                  session.rules.availableTowerTypes
                      .map((type) => context.t(towerCatalog[type]!.nameKey))
                      .join(' • '),
                ),
              ],
            ),
            _BriefingPanel(
              title: context.t('stage_rewards'),
              icon: Icons.emoji_events,
              children: [
                Text('${session.stage.rewards.gold} campaign gold'),
                Text('${session.stage.rewards.stars} stars'),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('start-stage'),
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: Text(context.t('start_stage')),
            ),
          ],
        ),
      ),
    );
  }
}

class _BriefingPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _BriefingPanel({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.10),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.cyanAccent),
                  const SizedBox(width: 9),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
