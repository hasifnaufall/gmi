// lib/speech_learn.dart
// Modern cyan/mint theme matching alphabet_learn.dart style

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'sign_video_player.dart';
import 'quest_status.dart';

class SpeechLearnScreen extends StatefulWidget {
  const SpeechLearnScreen({super.key});

  @override
  State<SpeechLearnScreen> createState() => _SpeechLearnScreenState();
}

class _SpeechLearnScreenState extends State<SpeechLearnScreen> {
  // Local watched set (since QuestStatus.watchedSpeech doesn't exist yet)
  final Set<String> _watchedSpeech = <String>{};

  // Build speech phrases with video paths
  final List<Map<String, String>> _all = [
    {'label': 'How are you', 'video': 'assets/videos/speech/hay.mp4'},
    {'label': 'Peace Be Upon You', 'video': 'assets/videos/speech/pbay.mp4'},
    {'label': 'Hello', 'video': 'assets/videos/speech/hello.mp4'},
    {'label': 'Excuse', 'video': 'assets/videos/speech/excuse.mp4'},
    {'label': 'Sorry', 'video': 'assets/videos/speech/sorry.mp4'},
    {'label': 'Salam', 'video': 'assets/videos/speech/salam.mp4'},
    {'label': 'Regards', 'video': 'assets/videos/speech/regards.mp4'},
    {'label': 'You are Welcome', 'video': 'assets/videos/speech/yaw.mp4'},
    {'label': 'Well', 'video': 'assets/videos/speech/well.mp4'},
    {'label': 'Welcome', 'video': 'assets/videos/speech/welcome.mp4'},
    {'label': 'Happy Birthday', 'video': 'assets/videos/speech/birthday.mp4'},
    {'label': 'Goodbye', 'video': 'assets/videos/speech/goodbye.mp4'},
    {'label': 'Good Night', 'video': 'assets/videos/speech/goodnight.mp4'},
    {'label': 'Good Morning', 'video': 'assets/videos/speech/goodmorning.mp4'},
    {'label': 'Good Evening', 'video': 'assets/videos/speech/goodevening.mp4'},
    {'label': 'Good Afternoon', 'video': 'assets/videos/speech/afternoon.mp4'},
    {'label': 'Congratulations', 'video': 'assets/videos/speech/congrats.mp4'},
    {'label': 'Thank you', 'video': 'assets/videos/speech/thankyou.mp4'},
    {'label': 'PLease', 'video': 'assets/videos/speech/please.mp4'},
    {'label': 'And unto you peace', 'video': 'assets/videos/speech/auyp.mp4'},
  ];

  String _query = "";
  int _columns = 2; // default 2 columns for longer phrases

  List<Map<String, String>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toUpperCase();
    return _all.where((m) => m["label"]!.toUpperCase().contains(q)).toList();
  }

  Future<void> _openVideo(Map<String, String> item) async {
    final watched = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignVideoPlayer(title: item['label']!, videoPath: item['video']!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOut;
          return FadeTransition(
            opacity: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
            ),
            child: ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.85, end: 1.0).chain(CurveTween(curve: curve)),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (watched == true) {
      setState(() => _watchedSpeech.add(item['label']!));
      await QuestStatus.autoSaveProgress();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked ${item['label']} as watched ✅'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      if (_watchedSpeech.length == _all.length && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All Speech phrases learned! Great job! 🎤'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedCount = _watchedSpeech.length;
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
              "Learn Speech Phrases",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                tooltip: _columns == 2 ? "More per row" : "Bigger cards",
                onPressed: () =>
                    setState(() => _columns = _columns == 2 ? 3 : 2),
                icon: Icon(
                  _columns == 2
                      ? Icons.view_comfy_alt
                      : Icons.grid_view_rounded,
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
                                "$watchedCount / ${_all.length} Phrases",
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
                              widthFactor: progress.clamp(0.0, 1.0),
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
                    hintText: "Search phrases...",
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
                    childAspectRatio: _columns == 2 ? 1.4 : 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    final label = item['label']!;
                    final watched = _watchedSpeech.contains(label);

                    return _SpeechCard(
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

class _SpeechCard extends StatefulWidget {
  final String label;
  final bool watched;
  final VoidCallback onTap;
  final ThemeManager themeManager;

  const _SpeechCard({
    required this.label,
    required this.watched,
    required this.onTap,
    required this.themeManager,
  });

  @override
  State<_SpeechCard> createState() => _SpeechCardState();
}

class _SpeechCardState extends State<_SpeechCard>
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
              color: widget.themeManager.isDarkMode
                  ? (widget.watched
                        ? const Color(0xFFD23232)
                        : const Color(0xFF636366))
                  : (widget.watched
                        ? const Color(0xFF0891B2)
                        : Colors.grey.shade200),
              width: widget.watched ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.themeManager.isDarkMode
                    ? (widget.watched
                          ? const Color(0xFFD23232).withOpacity(0.25)
                          : Colors.black.withOpacity(0.5))
                    : (widget.watched
                          ? const Color(0xFF0891B2).withOpacity(0.25)
                          : Colors.black.withOpacity(0.08)),
                blurRadius: widget.watched ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (widget.watched)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: RadialGradient(
                        colors: widget.themeManager.isDarkMode
                            ? [
                                const Color(0xFFD23232).withOpacity(0.1),
                                const Color(0xFF8B1F1F).withOpacity(0.05),
                                Colors.transparent,
                              ]
                            : [
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: widget.themeManager.isDarkMode
                          ? (widget.watched
                                ? const Color(0xFFD23232)
                                : const Color(0xFFE8E8E8))
                          : (widget.watched
                                ? const Color(0xFF0891B2)
                                : const Color(0xFF2D5263)),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: widget.themeManager.isDarkMode
                        ? (widget.watched
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD23232),
                                    Color(0xFF8B1F1F),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF2C2C2E),
                                    Color(0xFF1C1C1E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ))
                        : (widget.watched
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF0891B2),
                                    Color(0xFF06B6D4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )),
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
                        size: 14,
                        color: widget.themeManager.isDarkMode
                            ? (widget.watched
                                  ? Colors.white
                                  : const Color(0xFF8E8E93))
                            : (widget.watched
                                  ? Colors.white
                                  : Colors.grey.shade600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.watched ? "Done" : "Learn",
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.themeManager.isDarkMode
                              ? (widget.watched
                                    ? Colors.white
                                    : const Color(0xFF8E8E93))
                              : (widget.watched
                                    ? Colors.white
                                    : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.watched)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.themeManager.isDarkMode
                          ? const Color(0xFFD23232)
                          : const Color(0xFF0891B2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
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
