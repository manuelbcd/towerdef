import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class VolumeControls extends StatelessWidget {
  final double musicVolume;
  final double soundVolume;
  final ValueChanged<double> onMusicChanged;
  final ValueChanged<double> onSoundChanged;

  const VolumeControls({
    Key? key,
    required this.musicVolume,
    required this.soundVolume,
    required this.onMusicChanged,
    required this.onSoundChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t('music_volume'),
            style: context.theme.textTheme.titleMedium),
        Slider(
          value: musicVolume,
          min: 0,
          max: 1,
          divisions: 10,
          label: '${(musicVolume * 100).round()}%',
          onChanged: onMusicChanged,
        ),
        const SizedBox(height: 12),
        Text(context.t('sound_volume'),
            style: context.theme.textTheme.titleMedium),
        Slider(
          value: soundVolume,
          min: 0,
          max: 1,
          divisions: 10,
          label: '${(soundVolume * 100).round()}%',
          onChanged: onSoundChanged,
        ),
      ],
    );
  }
}
