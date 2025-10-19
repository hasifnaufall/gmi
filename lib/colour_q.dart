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
  int? _pendingIndex;
  int _correctCount = 0;
  int _wrongCount = 0;

  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // build 5 random questions
    final all = List<_Q>.from(_allQuestions)..shuffle();
    questions = all.take(sessionSize).toList();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(0.8, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_ctrl);
  }

  void _answer(int optionIndex) async {
    if (locked) return;
    final q = questions[index];
    final isCorrect = optionIndex == q.correctIndex;
    setState(() {
      locked = true;
      if (isCorrect) {
        _correctCount += 1;
      } else {
        _wrongCount += 1;
      }
    });

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
      _pendingIndex = null;
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
        child: _Toast(
          icon: icon,
          title: title,
          subtitle: subtitle,
          color: color,
        ),
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

  Future<bool> _confirmExitQuiz() async {
    final first =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Leave quiz?'),
            content: const Text("You'll lose your current round progress."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (!first) return false;

    final second =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              "This action can't be undone and your progress this round will be lost.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;

    return second;
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];

    return WillPopScope(
      onWillPop: () async => await _confirmExitQuiz(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Colour Quiz'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C5CB0),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SlideTransition(
            position: _slide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Question ${index + 1} of ${questions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProgressBar(),
                const SizedBox(height: 14),
                // Prompt image (sign for the colour)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      q.promptImage,
                      fit: BoxFit.contain,
                      height: 220,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: GridView.builder(
                    itemCount: q.options.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (_, i) {
                      final opt = q.options[i];
                      final isPending = _pendingIndex == i;
                      return GestureDetector(
                        onTap: locked
                            ? null
                            : () => setState(() => _pendingIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC6DDFF),
                            borderRadius: BorderRadius.circular(16),
                            border: isPending
                                ? Border.all(color: Colors.teal, width: 2)
                                : null,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  opt.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E4A8F),
                                  ),
                                ),
                              ),
                              if (isPending)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Selected',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildConfirmBar(q),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = questions.length;
    final correct = _correctCount;
    final wrong = _wrongCount;
    final remaining = total - correct - wrong;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              if (correct > 0)
                Expanded(
                  flex: correct,
                  child: Container(color: Colors.green),
                ),
              if (wrong > 0)
                Expanded(
                  flex: wrong,
                  child: Container(color: Colors.red),
                ),
              if (remaining > 0)
                Expanded(
                  flex: remaining,
                  child: Container(color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Correct: $correct',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
            Text(
              'Wrong: $wrong',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
            Text(
              'Left: $remaining',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmBar(_Q q) {
    if (_pendingIndex == null) return const SizedBox.shrink();
    final label = q.options[_pendingIndex!].name;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Confirm "$label"?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _pendingIndex = null),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5CB0),
            ),
            onPressed: locked
                ? null
                : () {
                    final idx = _pendingIndex;
                    if (idx != null) _answer(idx);
                  },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Toast extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _Toast({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(1.0, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
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
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
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
  _Q({
    required this.promptImage,
    required this.options,
    required this.correctIndex,
  });
}

// ----------------------------------------------------
// Replace image paths with your real asset locations.
// Make sure to add them under flutter: assets: in pubspec.yaml
// e.g. assets/images/colour/red.jpg etc.
// ----------------------------------------------------
final List<_Q> _allQuestions = [
  _Q(
    promptImage: 'assets/images/colour/C1.jpg',
    options: [
      _ColourOption('Red'),
      _ColourOption('Blue'),
      _ColourOption('Green'),
      _ColourOption('Yellow'),
    ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C2.jpg',
    options: [
      _ColourOption('Blue'),
      _ColourOption('Red'),
      _ColourOption('Orange'),
      _ColourOption('Green'),
    ],
    correctIndex: 3,
  ),
  _Q(
    promptImage: 'assets/images/colour/C3.jpg',
    options: [
      _ColourOption('Yellow'),
      _ColourOption('Blue'),
      _ColourOption('Black'),
      _ColourOption('Red'),
    ],
    correctIndex: 2,
  ),
  _Q(
    promptImage: 'assets/images/colour/C4.jpg',
    options: [
      _ColourOption('Grey'),
      _ColourOption('Orange'),
      _ColourOption('Green'),
      _ColourOption('Black'),
    ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C5.jpg',
    options: [
      _ColourOption('Pink'),
      _ColourOption('Grey'),
      _ColourOption('Purple'),
      _ColourOption('Brown'),
    ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C6.jpg',
    options: [
      _ColourOption('Yellow'),
      _ColourOption('White'),
      _ColourOption('Green'),
      _ColourOption('Blue'),
    ],
    correctIndex: 0,
  ),
  _Q(
    promptImage: 'assets/images/colour/C7.jpg',
    options: [
      _ColourOption('Purple'),
      _ColourOption('Pink'),
      _ColourOption('Black'),
      _ColourOption('Red'),
    ],
    correctIndex: 3,
  ),
  _Q(
    promptImage: 'assets/images/colour/C8.jpg',
    options: [
      _ColourOption('Red'),
      _ColourOption('Pink'),
      _ColourOption('Green'),
      _ColourOption('White'),
    ],
    correctIndex: 1,
  ),
  _Q(
    promptImage: 'assets/images/colour/C9.jpg',
    options: [
      _ColourOption('Purple'),
      _ColourOption('Orange'),
      _ColourOption('Brown'),
      _ColourOption('Blue'),
    ],
    correctIndex: 2,
  ),
  _Q(
    promptImage: 'assets/images/colour/C10.jpg',
    options: [
      _ColourOption('White'),
      _ColourOption('Grey'),
      _ColourOption('Black'),
      _ColourOption('Brown'),
    ],
    correctIndex: 0,
  ),
  _Q(
    promptImage: 'assets/images/colour/C11.jpg',
    options: [
      _ColourOption('Grey'),
      _ColourOption('Orange'),
      _ColourOption('Pink'),
      _ColourOption('Purple'),
    ],
    correctIndex: 3,
  ),
];
