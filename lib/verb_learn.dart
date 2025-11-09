// lib/verb_learn.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_video_player.dart';

class VerbLearnScreen extends StatefulWidget {
  const VerbLearnScreen({super.key});

  @override
  State<VerbLearnScreen> createState() => _VerbLearnScreenState();
}

class _VerbLearnScreenState extends State<VerbLearnScreen> {
  final List<Map<String, String>> _all = [
    {"label": "Lift", "video": "assets/videos/verbs/lift.mp4"},
    {"label": "Read", "video": "assets/videos/verbs/read.mp4"},
    {"label": "Wash", "video": "assets/videos/verbs/wash.mp4"},
    {"label": "Bring", "video": "assets/videos/verbs/bring.mp4"},
    {"label": "Eat", "video": "assets/videos/verbs/eat.mp4"},
    {"label": "Drink", "video": "assets/videos/verbs/drink.mp4"},
    {"label": "Select", "video": "assets/videos/verbs/select.mp4"},
    {"label": "Borrow", "video": "assets/videos/verbs/borrow.mp4"},
    {"label": "Rest", "video": "assets/videos/verbs/rest.mp4"},
    {"label": "Sleep", "video": "assets/videos/verbs/sleep.mp4"},
    {"label": "Wait", "video": "assets/videos/verbs/wait.mp4"},
    {"label": "Ride", "video": "assets/videos/verbs/ride.mp4"},
    {"label": "Discuss", "video": "assets/videos/verbs/discuss.mp4"},
    {"label": "Chat", "video": "assets/videos/verbs/chat.mp4"},
    {"label": "Follow", "video": "assets/videos/verbs/follow.mp4"},
  ];

  final Set<String> _watched = {};
  String _query = "";
  int _columns = 3;
  bool _notifiedAllLearned = false;

  List<Map<String, String>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toLowerCase();
    return _all.where((m) => m["label"]!.toLowerCase().contains(q)).toList();
  }

  Future<void> _openVideo(Map<String, String> item) async {
    final watched = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignVideoPlayer(title: item['label']!, videoPath: item['video']!),
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
      setState(() => _watched.add(item['label']!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked ${item['label']} as watched ✅'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // If all 15 verbs learned, you can add quest logic here similar to numbers
      if (_watched.length == 15 && !_notifiedAllLearned && mounted) {
        _notifiedAllLearned = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All Verbs learned! Great job! 🎉'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedCount = _watched.length;
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
          "Learn Verb Signs",
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
                            "$watchedCount / ${_all.length} Verbs",
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
                hintText: "Search verbs",
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
                final label = item['label']!;
                final watched = _watched.contains(label);

                return _VerbCard(
                  label: label,
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

class _VerbCard extends StatefulWidget {
  final String label;
  final bool watched;
  final VoidCallback onTap;

  const _VerbCard({
    required this.label,
    required this.watched,
    required this.onTap,
  });

  @override
  State<_VerbCard> createState() => _VerbCardState();
}

class _VerbCardState extends State<_VerbCard>
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
              // Verb text
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: widget.watched
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF2D5263),
                      letterSpacing: 0.5,
                    ),
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
