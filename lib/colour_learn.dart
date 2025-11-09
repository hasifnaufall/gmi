import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_video_player.dart';
import 'quest_status.dart';

class ColourLearnScreen extends StatefulWidget {
  const ColourLearnScreen({super.key});

  @override
  State<ColourLearnScreen> createState() => _ColourLearnScreenState();
}

class _ColourLearnScreenState extends State<ColourLearnScreen> {
  // ───────── Data: colour name → video path + swatch ─────────
  final List<_ColourItem> _all = <_ColourItem>[
    _ColourItem(
      'Red',
      'assets/videos/colours/red.mp4',
      const Color(0xFFE53935),
    ),
    _ColourItem(
      'Blue',
      'assets/videos/colours/blue.mp4',
      const Color(0xFF1E88E5),
    ),
    _ColourItem(
      'Green',
      'assets/videos/colours/green.mp4',
      const Color(0xFF43A047),
    ),
    _ColourItem(
      'Yellow',
      'assets/videos/colours/yellow.mp4',
      const Color(0xFFFDD835),
    ),
    _ColourItem(
      'Orange',
      'assets/videos/colours/orange.mp4',
      const Color(0xFFFB8C00),
    ),
    _ColourItem(
      'Purple',
      'assets/videos/colours/purple.mp4',
      const Color(0xFF8E24AA),
    ),
    _ColourItem(
      'Pink',
      'assets/videos/colours/pink.mp4',
      const Color(0xFFF06292),
    ),
    _ColourItem(
      'Brown',
      'assets/videos/colours/brown.mp4',
      const Color(0xFF8D6E63),
    ),
    _ColourItem(
      'Gray',
      'assets/videos/colours/gray.mp4',
      const Color(0xFF808080),
    ),
    _ColourItem(
      'Black',
      'assets/videos/colours/black.mp4',
      const Color(0xFF263238),
    ),
    _ColourItem(
      'White',
      'assets/videos/colours/white.mp4',
      const Color(0xFFECEFF1),
    ),
  ];

  // UI state (same pattern as AlphabetLearnScreen)
  String _query = "";
  int _columns = 3;

  List<_ColourItem> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toUpperCase();
    return _all.where((c) => c.name.toUpperCase().contains(q)).toList();
  }

  Future<void> _openVideo(_ColourItem item) async {
    final watched = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignVideoPlayer(title: item.name, videoPath: item.videoPath),
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

    if (watched == true) {
      setState(() => QuestStatus.watchedColours.add(item.name));

      // Save progress to database
      await QuestStatus.autoSaveProgress();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked ${item.name} as watched ✅'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedCount = QuestStatus.watchedColours.length;
    final progress = watchedCount / _all.length;

    return Scaffold(
      backgroundColor: const Color(0xFFCFFFF7), // Light mint background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Learn Colour Signs",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _columns == 3 ? "Bigger cards" : "More per row",
            onPressed: () => setState(() => _columns = _columns == 3 ? 2 : 3),
            icon: Icon(
              _columns == 3 ? Icons.grid_view_rounded : Icons.view_comfy_alt,
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
              gradient: const LinearGradient(
                colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0891B2).withOpacity(0.3),
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
                            "$watchedCount / ${_all.length} Colours",
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
                                colors: [Color(0xFFFFEB99), Color(0xFFFCD34D)],
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
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0891B2)),
                hintText: "Search colours",
                hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
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
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF0891B2),
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
                final watched = QuestStatus.watchedColours.contains(item.name);

                return _ColourCard(
                  item: item,
                  watched: watched,
                  onTap: () => _openVideo(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────── Card (same structure/animations as Alphabet) ─────────
class _ColourCard extends StatefulWidget {
  final _ColourItem item;
  final bool watched;
  final VoidCallback onTap;

  const _ColourCard({
    required this.item,
    required this.watched,
    required this.onTap,
  });

  @override
  State<_ColourCard> createState() => _ColourCardState();
}

class _ColourCardState extends State<_ColourCard>
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
            gradient: widget.watched
                ? const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.watched
                  ? const Color(0xFF0891B2)
                  : Colors.grey.shade200,
              width: widget.watched ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.watched
                    ? const Color(0xFF0891B2).withOpacity(0.25)
                    : Colors.black.withOpacity(0.08),
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
              // Color swatch + name
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: widget.item.swatch,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.watched
                              ? const Color(0xFF0891B2).withOpacity(0.5)
                              : Colors.grey.shade300,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.item.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: widget.watched
                            ? const Color(0xFF0891B2)
                            : const Color(0xFF2D5263),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
                        ? const LinearGradient(
                            colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade100, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: widget.watched
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0891B2).withOpacity(0.3),
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
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.watched ? "Done" : "Learn",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.watched
                              ? Colors.white
                              : Colors.grey.shade600,
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

// ───────── Model ─────────
class _ColourItem {
  final String name;
  final String videoPath;
  final Color swatch;
  _ColourItem(this.name, this.videoPath, this.swatch);
}
