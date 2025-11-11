// lib/badges/badges_widgets.dart
import 'package:flutter/material.dart' hide Badge;
import 'badges.dart';

class BadgeTile extends StatelessWidget {
  final Badge badge;
  final VoidCallback? onTap;
  const BadgeTile({super.key, required this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = badge.state == BadgeState.locked;
    final inProgress = badge.state == BadgeState.inProgress;
    final unlocked = badge.state == BadgeState.unlocked;

    final Color border = unlocked
        ? Colors.amber
        : (inProgress ? theme.colorScheme.primary : theme.disabledColor);
    final Color fg = unlocked
        ? theme.colorScheme.onPrimaryContainer
        : (inProgress ? theme.colorScheme.onSurface : theme.disabledColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.2),
          color: unlocked
              ? theme.colorScheme.primaryContainer.withOpacity(0.25)
              : (inProgress
              ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : theme.cardColor),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(badge.icon, size: 30, color: fg),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: fg),
            ),
            const SizedBox(height: 6),
            _ProgressPill(badge: badge),
          ],
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final Badge badge;
  const _ProgressPill({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = (badge.progress / badge.target).clamp(0.0, 1.0);
    final label = badge.state == BadgeState.unlocked
        ? 'Done'
        : '${badge.progress}/${badge.target}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: p,
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class BadgeDetailSheet extends StatelessWidget {
  final Badge badge;
  const BadgeDetailSheet({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = badge.state == BadgeState.unlocked;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24), topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44, height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(badge.icon, size: 36, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  badge.title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _RarityChip(rarity: badge.rarity),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              badge.description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (badge.progress / badge.target).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                unlocked ? 'Done' : '${badge.progress}/${badge.target}',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ]),
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final BadgeRarity rarity;
  const _RarityChip({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final txt = switch (rarity) {
      BadgeRarity.common => 'Common',
      BadgeRarity.rare => 'Rare',
      BadgeRarity.epic => 'Epic',
      BadgeRarity.legendary => 'Legendary',
    };
    return Chip(label: Text(txt));
  }
}
