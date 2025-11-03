// lib/verb_learn.dart
import 'package:flutter/material.dart';
import 'sign_video_player.dart';
import 'quest_status.dart';

class VerbLearnScreen extends StatefulWidget {
  const VerbLearnScreen({super.key});

  @override
  State<VerbLearnScreen> createState() => _VerbLearnScreenState();
}

class _VerbLearnScreenState extends State<VerbLearnScreen> {
  final List<Map<String, String>> _all = [
    {"label": "Lift", "video": "assets/videos/verbs/V1.mp4"},
    {"label": "Read", "video": "assets/videos/verbs/V2.mp4"},
    {"label": "Wash", "video": "assets/videos/verbs/V3.mp4"},
    {"label": "Bring", "video": "assets/videos/verbs/V4.mp4"},
    {"label": "Eat", "video": "assets/videos/verbs/V5.mp4"},
    {"label": "Drink", "video": "assets/videos/verbs/V6.mp4"},
    {"label": "Select", "video": "assets/videos/verbs/V7.mp4"},
    {"label": "Borrow", "video": "assets/videos/verbs/V8.mp4"},
    {"label": "Rest", "video": "assets/videos/verbs/V9.mp4"},
    {"label": "Sleep", "video": "assets/videos/verbs/V10.mp4"},
    {"label": "Wait", "video": "assets/videos/verbs/V11.mp4"},
    {"label": "Ride", "video": "assets/videos/verbs/V12.mp4"},
    {"label": "Discuss", "video": "assets/videos/verbs/V13.mp4"},
    {"label": "Chat", "video": "assets/videos/verbs/V14.mp4"},
    {"label": "Follow", "video": "assets/videos/verbs/V15.mp4"},
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
      MaterialPageRoute(
        builder: (_) => SignVideoPlayer(
          title: item['label']!,
          videoPath: item['video']!,
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Verb Signs"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B9D), Color(0xFFC06C84)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: _columns == 3 ? "Bigger cards" : "More per row",
            onPressed: () => setState(() => _columns = _columns == 3 ? 2 : 3),
            icon: Icon(_columns == 3 ? Icons.grid_view_rounded : Icons.view_comfy_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search verbs",
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB3C6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFF6B9D), size: 18),
                      const SizedBox(width: 6),
                      Text("$watchedCount / ${_all.length}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columns,
                childAspectRatio: _columns == 3 ? 0.9 : 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final label = item['label']!;
                final watched = _watched.contains(label);

                // Colorful gradients
                final gradients = [
                  [const Color(0xFFFF6B9D), const Color(0xFFFFC3A0)],
                  [const Color(0xFFB06AB3), const Color(0xFF4568DC)],
                  [const Color(0xFFFF9A8B), const Color(0xFFFF6A88)],
                  [const Color(0xFFFEAC5E), const Color(0xFFC779D0)],
                  [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                ];
                final g = gradients[index % gradients.length];

                return _VerbCard(
                  label: label,
                  gradient: g,
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
  final List<Color> gradient;
  final bool watched;
  final VoidCallback onTap;

  const _VerbCard({
    required this.label,
    required this.gradient,
    required this.watched,
    required this.onTap,
  });

  @override
  State<_VerbCard> createState() => _VerbCardState();
}

class _VerbCardState extends State<_VerbCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scale =
  Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);

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
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Verb text
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Play pill
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_fill, size: 18,
                          color: widget.watched ? Colors.green : Colors.black87),
                      const SizedBox(width: 6),
                      Text(widget.watched ? "Watched" : "Learn",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: widget.watched ? Colors.green : Colors.black87,
                          )),
                    ],
                  ),
                ),
              ),
              if (widget.watched)
                const Positioned(
                  left: 10,
                  top: 10,
                  child: Icon(Icons.verified, color: Colors.white, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }
}