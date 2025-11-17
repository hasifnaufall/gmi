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
    final isDarkMode = theme.brightness == Brightness.dark;
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
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                  0.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDarkMode ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeDetailSheet extends StatefulWidget {
  final Badge badge;
  const BadgeDetailSheet({super.key, required this.badge});

  @override
  State<BadgeDetailSheet> createState() => _BadgeDetailSheetState();
}

class _BadgeDetailSheetState extends State<BadgeDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final progressValue = (widget.badge.progress / widget.badge.target).clamp(
      0.0,
      1.0,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progressValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = widget.badge.state == BadgeState.unlocked;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  widget.badge.icon,
                  size: 36,
                  color: isDarkMode
                      ? const Color(0xFF0891B2)
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.badge.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : null,
                    ),
                  ),
                ),
                _RarityChip(rarity: widget.badge.rarity),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.badge.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white.withOpacity(0.8) : null,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : null,
                          ),
                        ),
                        Text(
                          unlocked
                              ? 'Completed! ✨'
                              : '${widget.badge.progress}/${widget.badge.target}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? const Color(0xFF0891B2)
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode
                                ? const Color(0xFF0891B2)
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF0891B2)
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
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
