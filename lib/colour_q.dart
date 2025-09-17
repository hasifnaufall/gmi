import 'package:flutter/material.dart';
import 'quest_status.dart';

class ColourQuizScreen extends StatefulWidget {
  const ColourQuizScreen({super.key});

  @override
  State<ColourQuizScreen> createState() => _ColourQuizScreenState();
}

class _ColourQuizScreenState extends State<ColourQuizScreen>
    with SingleTickerProviderStateMixin {
  static const int sessionSize = 5;

  late List<_Q> questions;
  int index = 0;
  bool locked = false;

  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // build 5 random questions
    final all = List<_Q>.from(_allQuestions)..shuffle();
    questions = all.take(sessionSize).toList();

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..forward();
    _slide = Tween<Offset>(begin: const Offset(0.8, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_ctrl);
  }

  void _answer(int optionIndex) async {
    if (locked) return;
    setState(() => locked = true);

    final q = questions[index];
    final isCorrect = optionIndex == q.correctIndex;

    if (isCorrect) {
      final levels = QuestStatus.addXp(20);
      _toast(
        icon: Icons.check_circle,
        title: 'Correct!',
        subtitle: '20 XP${levels > 0 ? " • Level up!" : ""}',
        color: Colors.green.shade600,
      );
    } else {
      _toast(
        icon: Icons.cancel,
        title: 'Oops!',
        subtitle: 'Answer: ${q.options[q.correctIndex].name}',
        color: Colors.red.shade600,
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (index == questions.length - 1) {
      QuestStatus.colourRoundsCompleted += 1;
      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease) {
        _toast(
          icon: Icons.local_fire_department,
          title: 'Streak +1!',
          subtitle: 'Current: ${QuestStatus.streakDays}',
          color: Colors.deepOrange.shade600,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    setState(() {
      index += 1;
      locked = false;
      _ctrl
        ..reset()
        ..forward();
    });
  }

  void _toast({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 64,
        right: 16,
        child: _Toast(icon: icon, title: title, subtitle: subtitle, color: color),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colour Quiz'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: Container(
        color: Colors.purple.shade50,
        padding: const EdgeInsets.all(16),
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              Text(
                'Question ${index + 1} of ${questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              // Prompt image (sign for the colour)
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      q.promptImage,
                      fit: BoxFit.contain,
                      height: 220,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: q.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (_, i) {
                  final opt = q.options[i];
                  return ElevatedButton(
                    onPressed: locked ? null : () => _answer(i),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _Toast({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 240))..forward();
  late final Animation<Offset> _slide =
  Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColourOption {
  final String name;
  const _ColourOption(this.name);
}

class _Q {
  final String promptImage;
  final List<_ColourOption> options;
  final int correctIndex;
  _Q({required this.promptImage, required this.options, required this.correctIndex});
}

// ----------------------------------------------------
// Replace image paths with your real asset locations.
// Make sure to add them under flutter: assets: in pubspec.yaml
// e.g. assets/images/colour/red.jpg etc.
// ----------------------------------------------------
final List<_Q> _allQuestions = [
  _Q(
    promptImage: 'assets/images/colour/C1.jpg',
    options: [ _ColourOption('Red'), _ColourOption('Blue'), _ColourOption('Green'), _ColourOption('Yellow') ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C2.jpg',
    options: [ _ColourOption('Blue'), _ColourOption('Red'), _ColourOption('Orange'), _ColourOption('Green') ],
    correctIndex: 3,
  ),
  _Q(
    promptImage: 'assets/images/colour/C3.jpg',
    options: [ _ColourOption('Yellow'), _ColourOption('Blue'), _ColourOption('Black'), _ColourOption('Red') ],
    correctIndex: 2,
  ),
  _Q(
    promptImage: 'assets/images/colour/C4.jpg',
    options: [ _ColourOption('Grey'), _ColourOption('Orange'), _ColourOption('Green'), _ColourOption('Black') ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C5.jpg',
    options: [ _ColourOption('Pink'), _ColourOption('Grey'), _ColourOption('Purple'), _ColourOption('Brown') ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C6.jpg',
    options: [ _ColourOption('Yellow'), _ColourOption('White'), _ColourOption('Green'), _ColourOption('Blue') ],
    correctIndex: 0,
  ),
  _Q(
    promptImage: 'assets/images/colour/C7.jpg',
    options: [ _ColourOption('Purple'), _ColourOption('Pink'), _ColourOption('Black'), _ColourOption('Red') ],
    correctIndex: 3,
  ),
  _Q(
    promptImage: 'assets/images/colour/C8.jpg',
    options: [ _ColourOption('Red'), _ColourOption('Pink'), _ColourOption('Green'), _ColourOption('White') ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C9.jpg',
    options: [ _ColourOption('Purple'), _ColourOption('Orange'), _ColourOption('Brown'), _ColourOption('Blue') ],
    correctIndex: 2,
  ),
  _Q(
    promptImage: 'assets/images/colour/C10.jpg',
    options: [ _ColourOption('White'), _ColourOption('Grey'), _ColourOption('Black'), _ColourOption('Brown') ],
    correctIndex: 0,
  ),
  _Q(
    promptImage: 'assets/images/colour/C11.jpg',
    options: [ _ColourOption('Grey'), _ColourOption('Orange'), _ColourOption('Pink'), _ColourOption('Purple') ],
    correctIndex: 3,
  ),
];
