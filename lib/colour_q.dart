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
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    final all = List<_Q>.from(_allQuestions)..shuffle();
    questions = all.take(sessionSize).toList();

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _slide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  void _answer(int optionIndex) async {
    if (locked) return;
    final q = questions[index];
    final isCorrect = optionIndex == q.correctIndex;
    setState(() {
      locked = true;
      _pendingIndex = null;
      if (isCorrect) {
        _correctCount += 1;
      } else {
        _wrongCount += 1;
      }
    });

    if (isCorrect) {
      final levels = QuestStatus.addXp(20);
      _toast(icon: Icons.check_circle, title: 'Correct!', subtitle: '20 XP${levels > 0 ? " • Level up!" : ""}', color: const Color(0xFF2C5CB0));
    } else {
      _toast(icon: Icons.cancel, title: 'Oops!', subtitle: 'Answer: ${q.options[q.correctIndex].name}', color: const Color(0xFFFF4B4A));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (index == questions.length - 1) {
      QuestStatus.colourRoundsCompleted += 1;
      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease) {
        _toast(icon: Icons.local_fire_department, title: 'Streak +1!', subtitle: 'Current: ${QuestStatus.streakDays}', color: const Color(0xFFFF4B4A));
        await Future.delayed(const Duration(seconds: 2));
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
      _ctrl..reset()..forward();
    });
  }

  void _toast({required IconData icon, required String title, required String subtitle, required Color color}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(top: 64, right: 16, child: _Toast(icon: icon, title: title, subtitle: subtitle, color: color)),
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
    final first = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.logout_rounded,
        title: 'Leave quiz?',
        message: "Your current progress will be lost.",
        primaryLabel: 'Continue',
        secondaryLabel: 'Cancel',
      ),
    );
    if (first != true) return false;

    final second = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.warning_amber_rounded,
        title: 'Are you sure?',
        message: "This action can't be undone and your progress this round will be lost.",
        primaryLabel: 'Leave',
        secondaryLabel: 'Stay',
      ),
    );
    return second == true;
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];

    return WillPopScope(
      onWillPop: () async => await _confirmExitQuiz(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFFDC),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    _buildQuestionCard(q),
                    const SizedBox(height: 32),
                    _buildOptionsGrid(q),
                    const SizedBox(height: 12),
                    if (_pendingIndex != null) _buildConfirmBar(q),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            final shouldExit = await _confirmExitQuiz();
            if (shouldExit && mounted) Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C5CB0), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Colour Quiz", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C5CB0), letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text("Question ${index + 1} of ${questions.length}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF2C5CB0), borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text("Lvl ${QuestStatus.level}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final total = questions.length;
    final correct = _correctCount;
    final wrong = _wrongCount;
    final remaining = total - correct - wrong;

    Widget segment({required Color color, required int flex, required BorderRadius radius}) {
      if (flex <= 0) return const SizedBox.shrink();
      return Expanded(flex: flex, child: AnimatedContainer(duration: const Duration(milliseconds: 220), decoration: BoxDecoration(color: color, borderRadius: radius), height: 10));
    }

    final hasCorrect = correct > 0;
    final hasWrong = wrong > 0;
    final hasRemaining = remaining > 0;

    final bars = <Widget>[];
    if (hasCorrect) bars.add(segment(color: const Color(0xFF44b427), flex: correct, radius: hasWrong || hasRemaining ? const BorderRadius.horizontal(left: Radius.circular(8)) : BorderRadius.circular(8)));
    if (hasWrong) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(segment(color: const Color(0xFFFF4B4A), flex: wrong, radius: (!hasCorrect && !hasRemaining) ? BorderRadius.circular(8) : BorderRadius.zero));
    }
    if (hasRemaining) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(segment(color: const Color(0xFFE8EEF9), flex: remaining, radius: (hasCorrect || hasWrong) ? const BorderRadius.horizontal(right: Radius.circular(8)) : BorderRadius.circular(8)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFF2F6FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE3E6EE))),
          child: Row(children: bars),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendDot(label: 'Correct', color: Color(0xFF44b427)),
            _LegendDot(label: 'Wrong', color: Color(0xFFFF4B4A)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(_Q q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF9FBFF), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE3E6EE))),
      child: Column(
        children: [
          const Text("What colour is shown?", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C5CB0), letterSpacing: -0.3)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE3E6EE))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                q.promptImage,
                fit: BoxFit.contain,
                height: 180,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 180,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey), SizedBox(height: 8), Text('Image not found', style: TextStyle(color: Colors.grey))])),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(_Q q) {
    return Expanded(
      child: GridView.builder(
        itemCount: q.options.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.6),
        itemBuilder: (_, i) {
          final opt = q.options[i];
          final isPending = _pendingIndex == i;
          return GestureDetector(
            onTap: locked ? null : () => setState(() => _pendingIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isPending ? const Color(0xFF311E76) : const Color(0xFFE3E6EE), width: isPending ? 2 : 1),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: locked ? null : () => setState(() => _pendingIndex = i),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: const Color(0xFF2C5CB0), child: Text((i + 1).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(opt.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C5CB0)))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmBar(_Q q) {
    if (_pendingIndex == null) return const SizedBox.shrink();
    final label = q.options[_pendingIndex!].name;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3E6EE))),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 18, color: Color(0xFF2C5CB0)),
          const SizedBox(width: 8),
          Text('Selected: $label', style: const TextStyle(color: Color(0xFF2C5CB0), fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _pendingIndex = null), child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5CB0), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: locked
                ? null
                : () {
              final idx = _pendingIndex;
              if (idx != null) _answer(idx);
            },
            child: const Text('Confirm'),
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
  const _Toast({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..forward();
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

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
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: widget.color,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
      ],
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

final List<_Q> _allQuestions = [
  _Q(promptImage: 'assets/images/colour/C1.jpg', options: [_ColourOption('Red'), _ColourOption('Blue'), _ColourOption('Green'), _ColourOption('Yellow')], correctIndex: 1),
  _Q(promptImage: 'assets/images/colour/C2.jpg', options: [_ColourOption('Blue'), _ColourOption('Red'), _ColourOption('Orange'), _ColourOption('Green')], correctIndex: 3),
  _Q(promptImage: 'assets/images/colour/C3.jpg', options: [_ColourOption('Yellow'), _ColourOption('Blue'), _ColourOption('Black'), _ColourOption('Red')], correctIndex: 2),
  _Q(promptImage: 'assets/images/colour/C4.jpg', options: [_ColourOption('Grey'), _ColourOption('Orange'), _ColourOption('Green'), _ColourOption('Black')], correctIndex: 1),
  _Q(promptImage: 'assets/images/colour/C5.jpg', options: [_ColourOption('Pink'), _ColourOption('Grey'), _ColourOption('Purple'), _ColourOption('Brown')], correctIndex: 1),
  _Q(promptImage: 'assets/images/colour/C6.jpg', options: [_ColourOption('Yellow'), _ColourOption('White'), _ColourOption('Green'), _ColourOption('Blue')], correctIndex: 0),
  _Q(promptImage: 'assets/images/colour/C7.jpg', options: [_ColourOption('Purple'), _ColourOption('Pink'), _ColourOption('Black'), _ColourOption('Red')], correctIndex: 3),
  _Q(promptImage: 'assets/images/colour/C8.jpg', options: [_ColourOption('Red'), _ColourOption('Pink'), _ColourOption('Green'), _ColourOption('White')], correctIndex: 1),
  _Q(promptImage: 'assets/images/colour/C9.jpg', options: [_ColourOption('Purple'), _ColourOption('Orange'), _ColourOption('Brown'), _ColourOption('Blue')], correctIndex: 2),
  _Q(promptImage: 'assets/images/colour/C10.jpg', options: [_ColourOption('White'), _ColourOption('Grey'), _ColourOption('Black'), _ColourOption('Brown')], correctIndex: 0),
  _Q(promptImage: 'assets/images/colour/C11.jpg', options: [_ColourOption('Grey'), _ColourOption('Orange'), _ColourOption('Pink'), _ColourOption('Purple')], correctIndex: 3),
];

class _CleanConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;

  const _CleanConfirmDialog({required this.icon, required this.title, required this.message, required this.primaryLabel, required this.secondaryLabel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle), child: Icon(icon, size: 34, color: Color(0xFF2C5CB0))),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), letterSpacing: -0.2)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14.5, color: Color(0xFF6B7280), height: 1.35)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), foregroundColor: const Color(0xFF2C5CB0)),
                    child: Text(secondaryLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4B4A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: Text(primaryLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}