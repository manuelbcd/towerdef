import 'package:flutter/material.dart';

enum Difficulty { low, medium, hard }

class TowerItem {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final int cost;
  final IconData icon;

  const TowerItem({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.cost,
    required this.icon,
  });
}

const availableTowers = <TowerItem>[
  TowerItem(
    id: 'arrow',
    nameKey: 'tower_arrow',
    descriptionKey: 'tower_arrow_desc',
    cost: 100,
    icon: Icons.arrow_upward,
  ),
  TowerItem(
    id: 'magic',
    nameKey: 'tower_magic',
    descriptionKey: 'tower_magic_desc',
    cost: 200,
    icon: Icons.auto_fix_high,
  ),
  TowerItem(
    id: 'cannon',
    nameKey: 'tower_cannon',
    descriptionKey: 'tower_cannon_desc',
    cost: 250,
    icon: Icons.whatshot,
  ),
  TowerItem(
    id: 'slowerer',
    nameKey: 'tower_slowerer',
    descriptionKey: 'tower_slowerer_desc',
    cost: 150,
    icon: Icons.ac_unit,
  ),
];

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
