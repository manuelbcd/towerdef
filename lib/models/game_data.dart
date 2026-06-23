import 'game_config.dart';

enum Difficulty { low, medium, hard }

List<TowerDefinition> get availableTowers =>
    TowerType.values.map((type) => towerCatalog[type]!).toList(growable: false);

class UpgradeItem {
  final String titleKey;
  final String subtitleKey;
  final int price;

  const UpgradeItem({
    required this.titleKey,
    required this.subtitleKey,
    required this.price,
  });
}

const availableUpgrades = <UpgradeItem>[
  UpgradeItem(
    titleKey: 'upgrade_range',
    subtitleKey: 'upgrade_range_desc',
    price: 80,
  ),
  UpgradeItem(
    titleKey: 'upgrade_speed',
    subtitleKey: 'upgrade_speed_desc',
    price: 140,
  ),
  UpgradeItem(
    titleKey: 'upgrade_power',
    subtitleKey: 'upgrade_power_desc',
    price: 200,
  ),
];
