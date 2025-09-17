import 'package:flutter/material.dart';
import 'sign_video_player.dart';

class ColourLearnScreen extends StatefulWidget {
  const ColourLearnScreen({super.key});

  @override
  State<ColourLearnScreen> createState() => _ColourLearnScreenState();
}

class _ColourLearnScreenState extends State<ColourLearnScreen> {
  // ───────── Data: colour name → video path + swatch ─────────
  final List<_ColourItem> _all = <_ColourItem>[
    _ColourItem('Red',    'assets/videos/colours/red.mp4',    const Color(0xFFE53935)),
    _ColourItem('Blue',   'assets/videos/colours/blue.mp4',   const Color(0xFF1E88E5)),
    _ColourItem('Green',  'assets/videos/colours/green.mp4',  const Color(0xFF43A047)),
    _ColourItem('Yellow', 'assets/videos/colours/yellow.mp4', const Color(0xFFFDD835)),
    _ColourItem('Orange', 'assets/videos/colours/orange.mp4', const Color(0xFFFB8C00)),
    _ColourItem('Purple', 'assets/videos/colours/purple.mp4', const Color(0xFF8E24AA)),
    _ColourItem('Pink',   'assets/videos/colours/pink.mp4',   const Color(0xFFF06292)),
    _ColourItem('Brown',  'assets/videos/colours/brown.mp4',  const Color(0xFF8D6E63)),
    _ColourItem('Gray',  'assets/videos/colours/gray.mp4',  const Color(0xFF808080)),
    _ColourItem('Black',  'assets/videos/colours/black.mp4',  const Color(0xFF263238)),
    _ColourItem('White',  'assets/videos/colours/white.mp4',  const Color(0xFFECEFF1)),
  ];

  // UI state (same pattern as AlphabetLearnScreen)
  final Set<String> _watched = {}; // session-only
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
      MaterialPageRoute(
        builder: (_) => SignVideoPlayer(
          title: item.name,
          videoPath: item.videoPath,
        ),
      ),
    );

    if (watched == true) {
      setState(() => _watched.add(item.name));
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
    final watchedCount = _watched.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Colour Signs"),
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
          // grid size toggle (same as Alphabet)
          IconButton(
            tooltip: _columns == 3 ? "Bigger cards" : "More per row",
            onPressed: () => setState(() => _columns = _columns == 3 ? 2 : 3),
            icon: Icon(_columns == 3 ? Icons.grid_view_rounded : Icons.view_comfy_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Progress row (same)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search colours",
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

          // Grid (styled like Alphabet)
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
                final watched = _watched.contains(item.name);

                // same playful gradients
                final gradients = [
                  [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
                  [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
                  [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
                  [const Color(0xFFFFDEE9), const Color(0xFFB5FFFC)],
                  [const Color(0xFFFFF1B1), const Color(0xFFFFD1FF)],
                ];
                final g = gradients[index % gradients.length];

                return _ColourCard(
                  item: item,
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

// ───────── Card (same structure/animations as Alphabet) ─────────
class _ColourCard extends StatefulWidget {
  final _ColourItem item;
  final List<Color> gradient;
  final bool watched;
  final VoidCallback onTap;

  const _ColourCard({
    required this.item,
    required this.gradient,
    required this.watched,
    required this.onTap,
  });

  @override
  State<_ColourCard> createState() => _ColourCardState();
}

class _ColourCardState extends State<_ColourCard> with SingleTickerProviderStateMixin {
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
              // Big colour swatch + name (mirrors big letter design)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: widget.item.swatch,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(.8), width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Learn / Watched pill
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
                      Icon(
                        Icons.play_circle_fill,
                        size: 18,
                        color: widget.watched ? Colors.green : Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.watched ? "Watched" : "Learn",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: widget.watched ? Colors.green : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Watched badge
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

// ───────── Model ─────────
class _ColourItem {
  final String name;
  final String videoPath;
  final Color swatch;
  _ColourItem(this.name, this.videoPath, this.swatch);
}
