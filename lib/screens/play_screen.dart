import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../models/game_data.dart';
import '../widgets/volume_controls.dart';

class PlayScreen extends StatelessWidget {
  final Locale locale;
  final double musicVolume;
  final double soundVolume;
  final Difficulty selectedDifficulty;
  final VoidCallback onBack;
  final VoidCallback onPlay;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<double> onMusicChanged;
  final ValueChanged<double> onSoundChanged;
  final ValueChanged<Difficulty> onDifficultyChanged;

  const PlayScreen({
    Key? key,
    required this.locale,
    required this.musicVolume,
    required this.soundVolume,
    required this.selectedDifficulty,
    required this.onBack,
    required this.onPlay,
    required this.onLocaleChanged,
    required this.onMusicChanged,
    required this.onSoundChanged,
    required this.onDifficultyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900,
            Colors.deepPurple.shade800,
            Colors.black87
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 10),
                  Text(context.t('play'),
                      style: context.theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 18),
              Text(context.t('level_summary'),
                  style: context.theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white70)),
              const SizedBox(height: 22),
              Row(
                children: [
                  ...Difficulty.values.map((difficulty) {
                    final selected = difficulty == selectedDifficulty;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(context.t(difficulty.name)),
                          selected: selected,
                          onSelected: (_) => onDifficultyChanged(difficulty),
                          selectedColor: Colors.amber.shade600,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          labelStyle: TextStyle(
                              color: selected ? Colors.black87 : Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600),
                    child: const Text('START'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _StageCard(
                  title: context.t('past_stage'),
                  subtitle: 'Wave 3 - Completed',
                  color: Colors.blueGrey.shade700),
              const SizedBox(height: 14),
              _StageCard(
                  title: context.t('current_stage'),
                  subtitle: 'Wave 4 - Idle defense',
                  color: Colors.deepPurple.shade700,
                  highlight: true),
              const SizedBox(height: 14),
              _StageCard(
                  title: context.t('next_stage'),
                  subtitle: 'Wave 5 - Harder enemy mix',
                  color: Colors.indigo.shade700),
              const SizedBox(height: 24),
              _SettingsPanel(
                locale: locale,
                musicVolume: musicVolume,
                soundVolume: soundVolume,
                onLocaleChanged: onLocaleChanged,
                onMusicChanged: onMusicChanged,
                onSoundChanged: onSoundChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool highlight;

  const _StageCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.highlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: highlight ? Colors.amberAccent : Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: context.theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(context.t('active'),
                  style: context.theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final Locale locale;
  final double musicVolume;
  final double soundVolume;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<double> onMusicChanged;
  final ValueChanged<double> onSoundChanged;

  const _SettingsPanel({
    Key? key,
    required this.locale,
    required this.musicVolume,
    required this.soundVolume,
    required this.onLocaleChanged,
    required this.onMusicChanged,
    required this.onSoundChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('settings'),
              style: context.theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(context.t('language'),
                  style: context.theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70)),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Locale>(
                        value: locale,
                        dropdownColor: Colors.indigo.shade900,
                        items: const [
                          DropdownMenuItem(
                              value: Locale('en'), child: Text('English')),
                          DropdownMenuItem(
                              value: Locale('es'), child: Text('Español')),
                        ],
                        onChanged: (value) {
                          if (value != null) onLocaleChanged(value);
                        },
                        style: context.theme.textTheme.bodyLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          VolumeControls(
            musicVolume: musicVolume,
            soundVolume: soundVolume,
            onMusicChanged: onMusicChanged,
            onSoundChanged: onSoundChanged,
          ),
        ],
      ),
    );
  }
}
