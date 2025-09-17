import 'package:flutter/material.dart';
import 'sign_video_player.dart';

class AnimalsLearnScreen extends StatefulWidget {
  const AnimalsLearnScreen({super.key});

  @override
  State<AnimalsLearnScreen> createState() => _AnimalsLearnScreenState();
}

class _AnimalsLearnScreenState extends State<AnimalsLearnScreen> {
  // Edit/expand this list as you add assets
  final List<Map<String, String>> _all = [
    {"label": "Termite",      "video": "assets/videos/animals/anai.mp4"},
    {"label": "Goose",        "video": "assets/videos/animals/angsa.mp4"},
    {"label": "Dog",          "video": "assets/videos/animals/anjing.mp4"},
    {"label": "Rabbit",       "video": "assets/videos/animals/arnab.mp4"},
    {"label": "Chicken",      "video": "assets/videos/animals/ayam.mp4"},
    {"label": "Pig",          "video": "assets/videos/animals/babi.mp4"},
    {"label": "Rhinoceros",   "video": "assets/videos/animals/badak_sumbu.mp4"},
    {"label": "Grasshopper",  "video": "assets/videos/animals/belalang.mp4"},
    {"label": "Bear",         "video": "assets/videos/animals/beruang.mp4"},
    {"label": "Monitor Lizard","video": "assets/videos/animals/biawak.mp4"},
    {"label": "Sheep",        "video": "assets/videos/animals/biri.mp4"},
    {"label": "Crocodile",    "video": "assets/videos/animals/buaya.mp4"},
    {"label": "Bird",         "video": "assets/videos/animals/burung.mp4"},
    {"label": "Lizard",       "video": "assets/videos/animals/cicak.mp4"},
    {"label": "Elephant",     "video": "assets/videos/animals/gajah.mp4"},
    {"label": "Gorilla",      "video": "assets/videos/animals/gorila.mp4"},
    {"label": "Tiger",        "video": "assets/videos/animals/harimau.mp4"},
    {"label": "Eagle",        "video": "assets/videos/animals/helang.mp4"},
    {"label": "Fish",         "video": "assets/videos/animals/ikan.mp4"},
    {"label": "Duck",         "video": "assets/videos/animals/itik.mp4"},
    {"label": "Scorpion",     "video": "assets/videos/animals/jengking.mp4"},
    {"label": "Goat",         "video": "assets/videos/animals/kambing.mp4"},
    {"label": "Mouse Deer",   "video": "assets/videos/animals/kancil.mp4"},
    {"label": "Spider",       "video": "assets/videos/animals/labah.mp4"},
    {"label": "Butterfly",    "video": "assets/videos/animals/rama_rama.mp4"},
    {"label": "Lion",         "video": "assets/videos/animals/singa.mp4"},
    {"label": "Giraffe",      "video": "assets/videos/animals/zirafah.mp4"},
  ];


  final Set<String> _watched = {};
  String _query = "";
  int _columns = 3;

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
    if (!mounted) return;

    if (watched == true) {
      setState(() => _watched.add(item['label']!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked ${item['label']} as watched ✅'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedCount = _watched.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Animal Signs"),
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
                      hintText: "Search animals",
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
                    color: const Color(0xFFEEF9FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBEE3F8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF0EA5E9), size: 18),
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

                final gradients = [
                  [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
                  [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
                  [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
                  [const Color(0xFFFFDEE9), const Color(0xFFB5FFFC)],
                  [const Color(0xFFFFF1B1), const Color(0xFFFFD1FF)],
                ];
                final g = gradients[index % gradients.length];

                return _AnimalCard(
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

class _AnimalCard extends StatefulWidget {
  final String label;
  final List<Color> gradient;
  final bool watched;
  final VoidCallback onTap;

  const _AnimalCard({
    required this.label,
    required this.gradient,
    required this.watched,
    required this.onTap,
  });

  @override
  State<_AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<_AnimalCard> with SingleTickerProviderStateMixin {
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
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
