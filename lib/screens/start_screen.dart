import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class StartScreen extends StatelessWidget {
  final VoidCallback onOpenMarket;
  final VoidCallback onPlay;

  const StartScreen({
    Key? key,
    required this.onOpenMarket,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo.shade900,
            Colors.deepPurple.shade700,
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                context.t('app_title'),
                style: context.theme.textTheme.headline3?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(blurRadius: 18, color: Colors.blue.shade200, offset: const Offset(0, 0)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.t('start_tagline'),
                style: context.theme.textTheme.subtitle1?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: _GlassButton(
                      label: context.t('marketplace'),
                      icon: Icons.storefront,
                      onTap: onOpenMarket,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GlassButton(
                      label: context.t('play'),
                      icon: Icons.play_arrow,
                      onTap: onPlay,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _GlowPanel(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.t('credits'), style: context.theme.textTheme.bodyText1?.copyWith(color: Colors.white70)),
                    Text('₡ 5200', style: context.theme.textTheme.subtitle1?.copyWith(color: Colors.amberAccent)),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 16)],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: 0.24,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.white.withOpacity(0.18), Colors.transparent],
                      radius: 0.9,
                      center: const Alignment(-0.5, -0.6),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(label, style: context.theme.textTheme.subtitle1?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowPanel extends StatelessWidget {
  final Widget child;

  const _GlowPanel({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: child,
    );
  }
}
