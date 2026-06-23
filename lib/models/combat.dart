enum AttackDelivery { projectile, beam }

enum StatusStackingPolicy { refresh, strongest }

abstract class AttackEffectDefinition {
  final String id;

  const AttackEffectDefinition(this.id);
}

class DirectDamageEffectDefinition extends AttackEffectDefinition {
  final double damage;

  const DirectDamageEffectDefinition({
    required String id,
    required this.damage,
  }) : super(id);

  DirectDamageEffectDefinition copyWith({double? damage}) {
    return DirectDamageEffectDefinition(
      id: id,
      damage: damage ?? this.damage,
    );
  }
}

abstract class StatusEffectDefinition extends AttackEffectDefinition {
  final double duration;
  final StatusStackingPolicy stackingPolicy;

  const StatusEffectDefinition({
    required String id,
    required this.duration,
    this.stackingPolicy = StatusStackingPolicy.refresh,
  }) : super(id);
}

class StatModifierEffectDefinition extends StatusEffectDefinition {
  final double speedMultiplier;

  const StatModifierEffectDefinition({
    required String id,
    required double duration,
    required this.speedMultiplier,
    super.stackingPolicy,
  }) : super(id: id, duration: duration);
}

class PeriodicDamageEffectDefinition extends StatusEffectDefinition {
  final double damagePerTick;
  final int tickCount;
  final double tickInterval;

  const PeriodicDamageEffectDefinition({
    required String id,
    required this.damagePerTick,
    required this.tickCount,
    required this.tickInterval,
    super.stackingPolicy,
  }) : super(id: id, duration: tickCount * tickInterval);
}

class AttackDefinition {
  final String id;
  final AttackDelivery delivery;
  final double projectileSpeed;
  final double areaRadius;
  final String visualId;
  final String? impactVisualId;
  final List<AttackEffectDefinition> effects;

  const AttackDefinition({
    required this.id,
    required this.delivery,
    required this.projectileSpeed,
    required this.visualId,
    required this.effects,
    this.areaRadius = 0,
    this.impactVisualId,
  });

  AttackDefinition resolve({
    required double directDamage,
    required double areaRadius,
  }) {
    return AttackDefinition(
      id: id,
      delivery: delivery,
      projectileSpeed: projectileSpeed,
      areaRadius: areaRadius,
      visualId: visualId,
      impactVisualId: impactVisualId,
      effects: effects.map((effect) {
        if (effect is DirectDamageEffectDefinition) {
          return effect.copyWith(damage: directDamage);
        }
        return effect;
      }).toList(growable: false),
    );
  }
}

class ActiveStatusEffect {
  StatusEffectDefinition definition;
  double elapsed = 0;
  double tickClock = 0;
  int ticksApplied = 0;

  ActiveStatusEffect(this.definition);

  bool get isFinished {
    if (definition is PeriodicDamageEffectDefinition) {
      return ticksApplied >=
          (definition as PeriodicDamageEffectDefinition).tickCount;
    }
    return elapsed >= definition.duration;
  }

  double get speedMultiplier {
    final effect = definition;
    return effect is StatModifierEffectDefinition ? effect.speedMultiplier : 1;
  }

  void merge(StatusEffectDefinition incoming) {
    switch (incoming.stackingPolicy) {
      case StatusStackingPolicy.refresh:
        elapsed = 0;
        if (incoming is PeriodicDamageEffectDefinition) {
          ticksApplied = 0;
        }
        definition = incoming;
        break;
      case StatusStackingPolicy.strongest:
        if (_strength(incoming) >= _strength(definition)) {
          definition = incoming;
        }
        elapsed = 0;
        break;
    }
  }

  double update(double deltaTime) {
    elapsed += deltaTime;
    final effect = definition;
    if (effect is! PeriodicDamageEffectDefinition) return 0;

    tickClock += deltaTime;
    var damage = 0.0;
    while (
        tickClock >= effect.tickInterval && ticksApplied < effect.tickCount) {
      tickClock -= effect.tickInterval;
      ticksApplied++;
      damage += effect.damagePerTick;
    }
    return damage;
  }

  double _strength(StatusEffectDefinition effect) {
    if (effect is StatModifierEffectDefinition) {
      return 1 - effect.speedMultiplier;
    }
    if (effect is PeriodicDamageEffectDefinition) {
      return effect.damagePerTick * effect.tickCount;
    }
    return 0;
  }
}
