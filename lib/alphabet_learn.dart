// alphabet_learn.dart
// Modified to work WITHOUT shared_preferences (in-memory only)
// number_learn.dart - Updated to link with Quest 8
import 'package:flutter/material.dart';
import 'sign_video_player.dart';
import 'quest_status.dart';

class AlphabetLearnScreen extends StatefulWidget {
  const AlphabetLearnScreen({super.key});

  @override
  State<AlphabetLearnScreen> createState() => _AlphabetLearnScreenState();
}

class _AlphabetLearnScreenState extends State<AlphabetLearnScreen> {
  // Build A–Z with video paths
  final List<Map<String, String>> _all = List.generate(26, (i) {
    final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
    return {
      "label": letter,
      "video": "assets/videos/alphabet/$letter.mp4",
    };
  });

  // In-memory storage (resets when app restarts)
  final Set<String> _watched = {};
  String _query = "";
  int _columns = 3;
  bool _notifiedAllLearned = false;

  List<Map<String, String>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.trim().toUpperCase();
    return _all.where((m) => m["label"]!.contains(q)).toList();
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

      // one-letter toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked ${item['label']} as watched ✅'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // If all 26 are learned, mark quest flag and auto-claim Quest 2
      if (_watched.length == 26 && !QuestStatus.learnedAlphabetAll) {
        QuestStatus.markAlphabetLearnAll();

        // Auto-claim Quest 2
        if (QuestStatus.canClaimQuest2()) {
          QuestStatus.claimQuest2();
        }

        if (!_notifiedAllLearned && mounted) {
          _notifiedAllLearned = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All Alphabet learned! Quest 2 completed! +120 keys'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedCount = _watched.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Alphabet Signs"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF80D0C7), Color(0xFF0093E9)],
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
            onLongPress: () {
              setState(() => _watched.clear());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress cleared')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search A–Z",
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF9FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBEE3F8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Color(0xFF0EA5E9), size: 18),
                      const SizedBox(width: 6),
                      Text("$watchedCount / 26",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),

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

                final gradients = [
                  [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
                  [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
                  [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
                  [const Color(0xFFFFDEE9), const Color(0xFFB5FFFC)],
                  [const Color(0xFFFFF1B1), const Color(0xFFFFD1FF)],
                ];
                final g = gradients[index % gradients.length];

                return _LetterCard(
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

class _LetterCard extends StatefulWidget {
  final String label;
  final List<Color> gradient;
  final bool watched;
  final VoidCallback onTap;

  const _LetterCard({
    required this.label,
    required this.gradient,
    required this.watched,
    required this.onTap,
  });

  @override
  State<_LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<_LetterCard>
    with SingleTickerProviderStateMixin {
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
              Center(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                            fontWeight: FontWeight.w800,
                            color:
                            widget.watched ? Colors.green : Colors.black87,
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