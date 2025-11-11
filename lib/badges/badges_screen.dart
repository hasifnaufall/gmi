// lib/badges/badges_screen.dart
import 'package:flutter/material.dart' hide Badge; // avoid clash with Material Badge
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme_manager.dart';
import 'badges.dart';
import 'badges_engine.dart';
import 'badges_widgets.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor:
      themeManager.isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFCFFFF7),
      appBar: AppBar(
        backgroundColor:
        themeManager.isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: themeManager.isDarkMode
                  ? const Color(0xFFD23232)
                  : const Color(0xFF0891B2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Badges',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: themeManager.isDarkMode
                ? const Color(0xFFD23232)
                : const Color(0xFF0891B2),
          ),
        ),
      ),
      body: FutureBuilder<(List<Badge>, List<String>)>(
        future: BadgeEngine.evaluateAndSave(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: themeManager.isDarkMode
                    ? const Color(0xFFD23232)
                    : const Color(0xFF0891B2),
              ),
            );
          }

          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load badges: ${snap.error}',
                style: GoogleFonts.montserrat(
                  color: themeManager.isDarkMode
                      ? const Color(0xFF8E8E93)
                      : Colors.grey.shade700,
                ),
              ),
            );
          }

          if (!snap.hasData) {
            return const SizedBox.shrink();
          }

          // Destructure the record from evaluateAndSave
          final (badges, newlyUnlockedIds) = snap.data!;

          // Partition for small summary chips
          final unlocked = badges
              .where((b) => b.state == BadgeState.unlocked)
              .toList();
          final inProg = badges
              .where((b) => b.state == BadgeState.inProgress)
              .toList();
          final locked = badges
              .where((b) => b.state == BadgeState.locked)
              .toList();

          // Optional: sort so unlocked first, then in progress, then locked
          final sorted = [
            ...unlocked,
            ...inProg,
            ...locked,
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _summaryChip(
                      context: context,
                      label: 'Unlocked',
                      value: unlocked.length,
                      bg: (themeManager.isDarkMode
                          ? const Color(0xFFD23232).withOpacity(0.15)
                          : const Color(0xFF0891B2).withOpacity(0.15)),
                      fg: themeManager.isDarkMode
                          ? const Color(0xFFD23232)
                          : const Color(0xFF0891B2),
                    ),
                    _summaryChip(
                      context: context,
                      label: 'In progress',
                      value: inProg.length,
                      bg: themeManager.isDarkMode
                          ? const Color(0xFF636366).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.15),
                      fg: themeManager.isDarkMode
                          ? const Color(0xFFE8E8E8)
                          : const Color(0xFF2D5263),
                    ),
                    _summaryChip(
                      context: context,
                      label: 'Locked',
                      value: locked.length,
                      bg: themeManager.isDarkMode
                          ? const Color(0xFF3C3C3E)
                          : Colors.grey.shade200,
                      fg: themeManager.isDarkMode
                          ? const Color(0xFF8E8E93)
                          : Colors.grey.shade700,
                    ),
                    if (newlyUnlockedIds.isNotEmpty)
                      _summaryChip(
                        context: context,
                        label: 'New',
                        value: newlyUnlockedIds.length,
                        bg: const Color(0xFF22C55E).withOpacity(0.15),
                        fg: const Color(0xFF22C55E),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Grid of badges
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GridView.builder(
                    itemCount: sorted.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, i) {
                      final b = sorted[i];
                      return BadgeTile(
                        badge: b,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => BadgeDetailSheet(badge: b),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryChip({
    required BuildContext context,
    required String label,
    required int value,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 12,
            ),
          ),
          Text(
            '$value',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
