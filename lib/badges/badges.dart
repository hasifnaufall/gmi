// lib/badges/badges.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// How rare/valuable a badge is (drives color accents).
enum BadgeRarity { common, rare, epic, legendary }

/// Locked -> no progress, InProgress -> some progress, Unlocked -> reached target.
enum BadgeState { locked, inProgress, unlocked }

class Badge {
  final String id;
  final String title;
  final String description;

  /// Leading icon for lists/sheets.
  final IconData icon;

  /// Cosmetic rarity for UI accents.
  final BadgeRarity rarity;

  /// XP/points granted when unlocked (used by UI tiles).
  final int points;

  /// Goal threshold (e.g., 10 quizzes).
  final int target;

  /// Current progress (0..target). **Computed at runtime** and not persisted
  /// if you prefer storing only counters elsewhere.
  final int progress;

  /// Seasonal/limited-time badge window.
  final bool seasonal;
  final DateTime? startAt;
  final DateTime? endAt;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.rarity = BadgeRarity.common,
    this.points = 0,
    this.target = 1,
    this.progress = 0,
    this.seasonal = false,
    this.startAt,
    this.endAt,
  });

  /// Copy with overrides (most commonly you’ll update `progress`).
  Badge copyWith({
    String? title,
    String? description,
    IconData? icon,
    BadgeRarity? rarity,
    int? points,
    int? target,
    int? progress,
    bool? seasonal,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return Badge(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      points: points ?? this.points,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      seasonal: seasonal ?? this.seasonal,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }

  /// Derived state used by UI.
  BadgeState get state {
    if (progress >= target) return BadgeState.unlocked;
    if (progress > 0) return BadgeState.inProgress;
    return BadgeState.locked;
  }

  /// 0.0–1.0 progress (clamped).
  double get pct => (target <= 0 ? 0 : progress / target).clamp(0, 1).toDouble();

  /// Whether the badge is inside its seasonal active window (or not seasonal).
  bool get isActiveNow {
    if (!seasonal) return true;
    final now = DateTime.now();
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  /// Convenience: color accent for rarity (used by chips/borders).
  Color get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return const Color(0xFF9E9E9E);
      case BadgeRarity.rare:
        return const Color(0xFF2196F3);
      case BadgeRarity.epic:
        return const Color(0xFF9C27B0);
      case BadgeRarity.legendary:
        return const Color(0xFFFF9800);
    }
  }

  /// Optional gradient if you want fancier fills.
  LinearGradient get rarityGradient {
    final base = rarityColor;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        base.withOpacity(0.85),
        base,
      ],
    );
  }

  // ------------ (Optional) Serialization helpers ----------------
  // You don’t have to use these now, but they’re handy if/when
  // you store badge definitions/documents in Firestore/JSON.

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'iconCodePoint': icon.codePoint,
    'iconFontFamily': icon.fontFamily ?? 'MaterialIcons',
    'rarity': rarity.name,
    'points': points,
    'target': target,
    'progress': progress,
    'seasonal': seasonal,
    'startAt': startAt?.millisecondsSinceEpoch,
    'endAt': endAt?.millisecondsSinceEpoch,
  };

  static Badge fromMap(Map<String, dynamic> map) {
    final rarityStr = (map['rarity'] as String?) ?? BadgeRarity.common.name;
    final rarity = BadgeRarity.values.firstWhere(
          (r) => r.name == rarityStr,
      orElse: () => BadgeRarity.common,
    );

    final iconCode = (map['iconCodePoint'] as int?) ?? Icons.emoji_events.codePoint;
    final iconFamily = (map['iconFontFamily'] as String?) ?? 'MaterialIcons';

    return Badge(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      icon: IconData(iconCode, fontFamily: iconFamily),
      rarity: rarity,
      points: (map['points'] as num?)?.toInt() ?? 0,
      target: (map['target'] as num?)?.toInt() ?? 1,
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      seasonal: (map['seasonal'] as bool?) ?? false,
      startAt: map['startAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startAt'] as int)
          : null,
      endAt: map['endAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endAt'] as int)
          : null,
    );
  }

  // -------------------- Equatability / debug --------------------

  @override
  String toString() =>
      'Badge($id, $title, state=${state.name}, progress=$progress/$target, points=$points, rarity=${rarity.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Badge &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Optional text style helper (matches your GoogleFonts use)
TextStyle badgeCaption(BuildContext ctx) => GoogleFonts.montserrat(
  fontSize: 10,
  color: Theme.of(ctx).brightness == Brightness.dark
      ? const Color(0xFF8E8E93)
      : Colors.grey.shade600,
);
