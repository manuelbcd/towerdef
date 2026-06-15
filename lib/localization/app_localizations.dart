import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'TowerDef',
      'start_tagline': 'Build, upgrade and survive the idle siege',
      'marketplace': 'Marketplace',
      'play': 'Play',
      'settings': 'Settings',
      'music_volume': 'Music Volume',
      'sound_volume': 'Sound Volume',
      'language': 'Language',
      'buy': 'Buy',
      'owned': 'Owned',
      'upgrade': 'Upgrade',
      'difficulty': 'Difficulty',
      'low': 'Low',
      'medium': 'Medium',
      'hard': 'Hard',
      'past_stage': 'Past Stage',
      'current_stage': 'Current Stage',
      'next_stage': 'Next Stage',
      'tower_arrow': 'Arrow Tower',
      'tower_arrow_desc': 'Fast firing with long range.',
      'tower_archer': 'Archer Tower',
      'tower_archer_desc': 'Fast shooting, longer range, ideal for thinning waves quickly.',
      'tower_magic': 'Magic Tower',
      'tower_magic_desc': 'Deals area slow damage.',
      'tower_cannon': 'Cannon Tower',
      'tower_cannon_desc': 'High burst damage per shot.',
      'upgrade_range': 'Range Upgrade',
      'upgrade_range_desc': 'Extend tower reach.',
      'upgrade_speed': 'Speed Upgrade',
      'upgrade_speed_desc': 'Fire faster and control waves.',
      'upgrade_power': 'Power Upgrade',
      'upgrade_power_desc': 'Boost tower impact.',
      'back': 'Back',
      'credits': 'Credits',
      'gold': 'Gold',
      'level_summary': 'Level summary and idle progression.',
      'level': 'Level',
      'active': 'Active',
    },
    'es': {
      'app_title': 'TowerDef',
      'start_tagline': 'Construye, mejora y sobrevive al asedio idle',
      'marketplace': 'Mercado',
      'play': 'Jugar',
      'settings': 'Ajustes',
      'music_volume': 'Volumen música',
      'sound_volume': 'Volumen efectos',
      'language': 'Idioma',
      'buy': 'Comprar',
      'owned': 'Comprado',
      'upgrade': 'Mejora',
      'difficulty': 'Dificultad',
      'low': 'Baja',
      'medium': 'Media',
      'hard': 'Alta',
      'past_stage': 'Etapa previa',
      'current_stage': 'Etapa actual',
      'next_stage': 'Siguiente etapa',
      'tower_arrow': 'Torre Flecha',
      'tower_arrow_desc': 'Disparo rápido con largo alcance.',
      'tower_archer': 'Torre Arquera',
      'tower_archer_desc': 'Disparo rápido y mayor alcance, ideal para reducir oleadas.',
      'tower_magic': 'Torre Mágica',
      'tower_magic_desc': 'Daño en área con ralentización.',
      'tower_cannon': 'Torre Cañón',
      'tower_cannon_desc': 'Alto daño por impacto.',
      'upgrade_range': 'Mejora de alcance',
      'upgrade_range_desc': 'Extiende el alcance de la torre.',
      'upgrade_speed': 'Mejora de velocidad',
      'upgrade_speed_desc': 'Dispara más rápido y controla oleadas.',
      'upgrade_power': 'Mejora de poder',
      'upgrade_power_desc': 'Aumenta el impacto de la torre.',
      'back': 'Atrás',
      'credits': 'Créditos',
      'gold': 'Oro',
      'level_summary': 'Resumen de nivel y progresión idle.',
      'active': 'Activo',
      'level': 'Nivel',
    },
  };

  String translate(String key) {
    final localeMap = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return localeMap[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension TranslateX on BuildContext {
  String t(String key) => AppLocalizations.of(this).translate(key);
}
