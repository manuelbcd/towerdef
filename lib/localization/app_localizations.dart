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
      'tower_archer_desc':
          'Fast shooting, longer range, ideal for thinning waves quickly.',
      'tower_magic': 'Magic Tower',
      'tower_magic_desc':
          'Curses nearby enemies with progressive purple magic damage.',
      'tower_cannon': 'Cannon Tower',
      'tower_cannon_desc': 'High burst damage per shot.',
      'tower_slowerer': 'Slowerer Tower',
      'tower_slowerer_desc':
          'Fires chilling rays that reduce enemy speed to one third.',
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
      'enemy_sheet_title': 'Enemy dossier',
      'enemy_goblin_name': 'Nib Wickwhistle',
      'enemy_goblin_story':
          'Once the lantern-keeper of a mossy border village, Nib traded every flame for a map to the kingdom\'s vaults. He now marches by moonlight, convinced the last gold coin will buy his way home.',
      'enemy_runner_name': 'Vexa Quickstep',
      'enemy_runner_story':
          'Vexa outran a thunderstorm and has been trying to beat its echo ever since. She darts forward in sudden bursts, pausing only long enough to hear whether the sky is catching up.',
      'enemy_brute_name': 'Gromm Stoneback',
      'enemy_brute_story':
          'Gromm carries a shard of his fallen mountain beneath his armor. Every heavy step is a promise to rebuild it, though unfortunately he has decided your fortress contains the perfect stones.',
      'enemy_speed': 'Speed',
      'enemy_movement': 'Movement',
      'enemy_vitality': 'Vitality',
      'enemy_size': 'Size',
      'enemy_bounty': 'Bounty',
      'enemy_threat': 'Threat',
      'movement_straight': 'Steady march',
      'movement_step_stop_step': 'Burst and pause',
      'size_small': 'Small',
      'size_medium': 'Medium',
      'size_large': 'Large',
      'threat_low': 'Low',
      'threat_medium': 'Medium',
      'threat_high': 'High',
      'wave': 'Wave',
      'victory': 'Victory!',
      'map_defended': 'Map defended',
      'next_map': 'Next map',
      'view_results': 'View results',
      'campaign_realm_defense': 'Realm Defense',
      'campaign_realm_defense_desc':
          'Defend the borderlands and push back the siege across five maps.',
      'chapter_borderlands': 'Chapter I · The Borderlands',
      'chapter_frozen_crown': 'Chapter II · The Frozen Crown',
      'stage_green_pass': 'Two Roads at Green Pass',
      'stage_green_pass_desc':
          'Learn to defend two routes while building your first field force.',
      'stage_ember_turns': 'Ember Turns',
      'stage_ember_turns_desc':
          'Hold the winding road before the raiders reach the southern gate.',
      'stage_river_hook': 'River Hook Crossing',
      'stage_river_hook_desc':
          'A faster mixed assault follows the river toward the settlement.',
      'stage_stone_s': 'Siege of Stone S',
      'stage_stone_s_desc':
          'Use the long bends to contain tougher enemies and heavy brutes.',
      'stage_frost_loop': 'The Frozen Crown',
      'stage_frost_loop_desc':
          'Survive the strongest siege and secure the northern passage.',
      'encounter_border_patrol': 'Border Patrol',
      'encounter_mixed_assault': 'Mixed Assault',
      'encounter_heavy_siege': 'Heavy Siege',
      'starting_resources': 'Starting resources',
      'stage_rewards': 'Stage rewards',
      'start_stage': 'Start stage',
      'stage_complete': 'Stage complete!',
      'stage_failed': 'Defense broken',
      'continue_campaign': 'Continue campaign',
      'campaign_map': 'Campaign map',
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
      'tower_archer_desc':
          'Disparo rápido y mayor alcance, ideal para reducir oleadas.',
      'tower_magic': 'Torre Mágica',
      'tower_magic_desc':
          'Maldice a enemigos cercanos con daño mágico progresivo.',
      'tower_cannon': 'Torre Cañón',
      'tower_cannon_desc': 'Alto daño por impacto.',
      'tower_slowerer': 'Torre Ralentizadora',
      'tower_slowerer_desc':
          'Dispara rayos gélidos que reducen la velocidad a un tercio.',
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
      'enemy_sheet_title': 'Expediente enemigo',
      'enemy_goblin_name': 'Nib Silbamechas',
      'enemy_goblin_story':
          'Antiguo farolero de una aldea cubierta de musgo, Nib cambió cada llama por un mapa de las bóvedas del reino. Ahora marcha a la luz de la luna, convencido de que la última moneda de oro le permitirá volver a casa.',
      'enemy_runner_name': 'Vexa Piesveloces',
      'enemy_runner_story':
          'Vexa dejó atrás a una tormenta y desde entonces intenta vencer a su eco. Avanza en ráfagas repentinas y solo se detiene para escuchar si el cielo está a punto de alcanzarla.',
      'enemy_brute_name': 'Gromm Lomo de Piedra',
      'enemy_brute_story':
          'Gromm lleva bajo la armadura un fragmento de su montaña caída. Cada paso es una promesa de reconstruirla, aunque ha decidido que tu fortaleza contiene las piedras perfectas.',
      'enemy_speed': 'Velocidad',
      'enemy_movement': 'Movimiento',
      'enemy_vitality': 'Vitalidad',
      'enemy_size': 'Tamaño',
      'enemy_bounty': 'Recompensa',
      'enemy_threat': 'Amenaza',
      'movement_straight': 'Marcha constante',
      'movement_step_stop_step': 'Ráfaga y pausa',
      'size_small': 'Pequeño',
      'size_medium': 'Mediano',
      'size_large': 'Grande',
      'threat_low': 'Baja',
      'threat_medium': 'Media',
      'threat_high': 'Alta',
      'wave': 'Oleada',
      'victory': '¡Victoria!',
      'map_defended': 'Mapa defendido',
      'next_map': 'Siguiente mapa',
      'view_results': 'Ver resultados',
      'campaign_realm_defense': 'Defensa del Reino',
      'campaign_realm_defense_desc':
          'Defiende las fronteras y rechaza el asedio a través de cinco mapas.',
      'chapter_borderlands': 'Capítulo I · Las Fronteras',
      'chapter_frozen_crown': 'Capítulo II · La Corona Helada',
      'stage_green_pass': 'Dos caminos en Paso Verde',
      'stage_green_pass_desc':
          'Aprende a defender dos rutas mientras construyes tu primera fuerza.',
      'stage_ember_turns': 'Curvas de Brasa',
      'stage_ember_turns_desc':
          'Protege el camino sinuoso antes de que alcancen la puerta sur.',
      'stage_river_hook': 'Cruce del Gancho del Río',
      'stage_river_hook_desc':
          'Un asalto mixto y veloz sigue el río hacia el asentamiento.',
      'stage_stone_s': 'Asedio de la S de Piedra',
      'stage_stone_s_desc':
          'Usa las curvas largas para contener enemigos y brutos resistentes.',
      'stage_frost_loop': 'La Corona Helada',
      'stage_frost_loop_desc':
          'Sobrevive al asedio más fuerte y asegura el paso del norte.',
      'encounter_border_patrol': 'Patrulla Fronteriza',
      'encounter_mixed_assault': 'Asalto Mixto',
      'encounter_heavy_siege': 'Asedio Pesado',
      'starting_resources': 'Recursos iniciales',
      'stage_rewards': 'Recompensas de etapa',
      'start_stage': 'Iniciar etapa',
      'stage_complete': '¡Etapa completada!',
      'stage_failed': 'Defensa rota',
      'continue_campaign': 'Continuar campaña',
      'campaign_map': 'Mapa de campaña',
    },
  };

  String translate(String key) {
    final localeMap =
        _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
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
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension TranslateX on BuildContext {
  String t(String key) => AppLocalizations.of(this).translate(key);
}
