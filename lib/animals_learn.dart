import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'sign_video_player.dart';
import 'quest_status.dart';

class AnimalsLearnScreen extends StatefulWidget {
  const AnimalsLearnScreen({super.key});

  @override
  State<AnimalsLearnScreen> createState() => _AnimalsLearnScreenState();
}

class _AnimalsLearnScreenState extends State<AnimalsLearnScreen> {
  // Edit/expand this list as you add assets
  final List<Map<String, String>> _all = [
    {"label": "Termite", "video": "assets/videos/animals/anai.mp4"},
    {"label": "Goose", "video": "assets/videos/animals/angsa.mp4"},
    {"label": "Dog", "video": "assets/videos/animals/anjing.mp4"},
    {"label": "Rabbit", "video": "assets/videos/animals/arnab.mp4"},
    {"label": "Chicken", "video": "assets/videos/animals/ayam.mp4"},
    {"label": "Pig", "video": "assets/videos/animals/babi.mp4"},
    {"label": "Rhinoceros", "video": "assets/videos/animals/badaksumbu.mp4"},
    {"label": "Grasshopper", "video": "assets/videos/animals/belalang.mp4"},
    {"label": "Bear", "video": "assets/videos/animals/beruang.mp4"},
    {"label": "Monitor Lizard", "video": "assets/videos/animals/biawak.mp4"},
    {"label": "Sheep", "video": "assets/videos/animals/biri.mp4"},
    {"label": "Crocodile", "video": "assets/videos/animals/buaya.mp4"},
    {"label": "Bird", "video": "assets/videos/animals/burung.mp4"},
    {"label": "Lizard", "video": "assets/videos/animals/cicak.mp4"},
    {"label": "Elephant", "video": "assets/videos/animals/gajah.mp4"},
    {"label": "Gorilla", "video": "assets/videos/animals/gorila.mp4"},
    {"label": "Tiger", "video": "assets/videos/animals/harimau.mp4"},
    {"label": "Eagle", "video": "assets/videos/animals/helang.mp4"},
    {"label": "Fish", "video": "assets/videos/animals/ikan.mp4"},
    {"label": "Duck", "video": "assets/videos/animals/itik.mp4"},
    {"label": "Scorpion", "video": "assets/videos/animals/jengking.mp4"},
    {"label": "Goat", "video": "assets/videos/animals/kambing.mp4"},
    {"label": "Mouse Deer", "video": "assets/videos/animals/kancil.mp4"},
    {"label": "Spider", "video": "assets/videos/animals/labah.mp4"},
    {"label": "Butterfly", "video": "assets/videos/animals/rama-rama.mp4"},
    {"label": "Lion", "video": "assets/videos/animals/singa.mp4"},
    {"label": "Giraffe", "video": "assets/videos/animals/zirafah.mp4"},
  ];

  String _query = "";
  int _columns = 3;

  List<Map<String, String>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toLowerCase();
    return _all.where((m) => m["label"]!.toLowerCase().contains(q)).toList();
  }

  Future<void> _openVideo(Map<String, String> item) async {
    final initialIndex = _all.indexWhere((m) => m['label'] == item['label']);
    
    final result = await Navigator.push<dynamic>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignVideoPlayer(
              title: item['label']!,
              videoPath: item['video']!,
              allItems: _all,
              initialIndex: initialIndex,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var fadeTween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var scaleTween = Tween(
            begin: 0.85,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (!mounted) return;

    Set<String> newlyWatched = {};
    if (result is bool && result == true) {
      newlyWatched.add(item['label']!);
    } else if (result is Set<String>) {
      newlyWatched = result;
    }

    if (newlyWatched.isNotEmpty) {
      setState(() => QuestStatus.watchedAnimals.addAll(newlyWatched));

      // Save progress to database
      await QuestStatus.autoSaveProgress();

      if (newlyWatched.length == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked ${newlyWatched.first} as watched ✅'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked ${newlyWatched.length} videos as watched ✅'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedCount = QuestStatus.watchedAnimals.length;
    final progress = watchedCount / _all.length;

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: themeManager.isDarkMode
              ? const Color(0xFF1C1C1E)
              : const Color(0xFFCFFFF7), // Light mint background
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeManager.isDarkMode
                      ? [const Color(0xFFD23232), const Color(0xFF8B1F1F)]
                      : [const Color(0xFF0891B2), const Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              "Learn Animal Signs",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                tooltip: _columns == 3 ? "Bigger cards" : "More per row",
                onPressed: () =>
                    setState(() => _columns = _columns == 3 ? 2 : 3),
                icon: Icon(
                  _columns == 3
                      ? Icons.grid_view_rounded
                      : Icons.view_comfy_alt,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeManager.isDarkMode
                        ? [const Color(0xFFD23232), const Color(0xFF8B1F1F)]
                        : [const Color(0xFF0891B2), const Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeManager.isDarkMode
                          ? const Color(0xFFD23232).withOpacity(0.3)
                          : const Color(0xFF0891B2).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Progress",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$watchedCount / ${_all.length} Animals",
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFFFFEB99),
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${(progress * 100).toInt()}%",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFEB99),
                                      Color(0xFFFCD34D),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFEB99,
                                      ).withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.montserrat(
                    color: themeManager.isDarkMode
                        ? const Color(0xFFE8E8E8)
                        : Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeManager.isDarkMode
                          ? const Color(0xFFD23232)
                          : const Color(0xFF0891B2),
                    ),
                    hintText: "Search animals",
                    hintStyle: GoogleFonts.montserrat(
                      color: themeManager.isDarkMode
                          ? const Color(0xFF8E8E93)
                          : Colors.grey.shade500,
                    ),
                    filled: true,
                    fillColor: themeManager.isDarkMode
                        ? const Color(0xFF2C2C2E)
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: themeManager.isDarkMode
                            ? const Color(0xFF636366)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: themeManager.isDarkMode
                            ? const Color(0xFFD23232)
                            : const Color(0xFF0891B2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _columns,
                    childAspectRatio: _columns == 3 ? 0.85 : 0.95,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    final label = item['label']!;
                    final watched = QuestStatus.watchedAnimals.contains(label);

                    return _AnimalCard(
                      label: label,
                      watched: watched,
                      onTap: () => _openVideo(item),
                      themeManager: themeManager,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimalCard extends StatefulWidget {
  final String label;
  final bool watched;
  final VoidCallback onTap;
  final ThemeManager themeManager;

  const _AnimalCard({
    required this.label,
    required this.watched,
    required this.onTap,
    required this.themeManager,
  });

  @override
  State<_AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<_AnimalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _down(_) => _ctrl.forward();
  void _up(_) => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapCancel: () => _ctrl.reverse(),
      onTapUp: (d) => _up(d),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.themeManager.isDarkMode
                ? (widget.watched
                      ? const LinearGradient(
                          colors: [Color(0xFF3C3C3E), Color(0xFF2C2C2E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ))
                : (widget.watched
                      ? const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.watched
                  ? (widget.themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2))
                  : (widget.themeManager.isDarkMode
                        ? const Color(0xFF636366)
                        : Colors.grey.shade200),
              width: widget.watched ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.watched
                    ? (widget.themeManager.isDarkMode
                          ? const Color(0xFFD23232).withOpacity(0.25)
                          : const Color(0xFF0891B2).withOpacity(0.25))
                    : (widget.themeManager.isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.08)),
                blurRadius: widget.watched ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Accent gradient overlay
              if (widget.watched)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF06B6D4).withOpacity(0.1),
                          const Color(0xFF0891B2).withOpacity(0.05),
                          Colors.transparent,
                        ],
                        center: Alignment.topRight,
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
              // Animal name
              Center(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: widget.watched
                        ? (widget.themeManager.isDarkMode
                              ? const Color(0xFFD23232)
                              : const Color(0xFF0891B2))
                        : (widget.themeManager.isDarkMode
                              ? const Color(0xFFE8E8E8)
                              : const Color(0xFF2D5263)),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Status badge
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: widget.watched
                        ? LinearGradient(
                            colors: widget.themeManager.isDarkMode
                                ? [
                                    const Color(0xFFD23232),
                                    const Color(0xFF8B1F1F),
                                  ]
                                : [
                                    const Color(0xFF0891B2),
                                    const Color(0xFF06B6D4),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: widget.themeManager.isDarkMode
                                ? [
                                    const Color(0xFF636366),
                                    const Color(0xFF3C3C3E),
                                  ]
                                : [Colors.grey.shade100, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: widget.watched
                        ? [
                            BoxShadow(
                              color: widget.themeManager.isDarkMode
                                  ? const Color(0xFFD23232).withOpacity(0.3)
                                  : const Color(0xFF0891B2).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.watched
                            ? Icons.check_circle
                            : Icons.play_circle_outline,
                        size: 16,
                        color: widget.watched
                            ? Colors.white
                            : (widget.themeManager.isDarkMode
                                  ? const Color(0xFF8E8E93)
                                  : Colors.grey.shade600),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.watched ? "Done" : "Learn",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.watched
                              ? Colors.white
                              : (widget.themeManager.isDarkMode
                                    ? const Color(0xFF8E8E93)
                                    : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Checkmark icon for completed
              if (widget.watched)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
