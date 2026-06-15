import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../models/game_data.dart';

class MarketScreen extends StatelessWidget {
  final VoidCallback onBack;

  const MarketScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade950,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(title: context.t('marketplace'), onBack: onBack),
              const SizedBox(height: 20),
              Text(context.t('gold'), style: context.theme.textTheme.subtitle1?.copyWith(color: Colors.amberAccent)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...availableTowers.map((tower) => _ShopCard(item: tower, onBuy: () {})),
                    const SizedBox(height: 18),
                    ...availableUpgrades.map((upgrade) => _UpgradeCard(item: upgrade, onBuy: () {})),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({Key? key, required this.title, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.theme.textTheme.headline5?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  final TowerItem item;
  final VoidCallback onBuy;

  const _ShopCard({Key? key, required this.item, required this.onBuy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade400.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nameKey.t(context), style: context.theme.textTheme.subtitle1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(item.descriptionKey.t(context), style: context.theme.textTheme.bodyText2?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(context.t('buy')),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final UpgradeItem item;
  final VoidCallback onBuy;

  const _UpgradeCard({Key? key, required this.item, required this.onBuy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.titleKey.t(context), style: context.theme.textTheme.subtitle1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              Text('${item.price} ₡', style: context.theme.textTheme.subtitle2?.copyWith(color: Colors.amberAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.subtitleKey.t(context), style: context.theme.textTheme.bodyText2?.copyWith(color: Colors.white70)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(context.t('upgrade')),
            ),
          ),
        ],
      ),
    );
  }
}

extension LocalizationHelper on String {
  String t(BuildContext context) => AppLocalizations.of(context).translate(this);
}
