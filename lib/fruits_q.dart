import 'package:flutter/material.dart';
import 'quest_status.dart';

class FruitsQuizScreen extends StatefulWidget {
  final int? startIndex;
  const FruitsQuizScreen({super.key, this.startIndex});

  @override
  State<FruitsQuizScreen> createState() => _FruitsQuizScreenState();
}

class _FruitsQuizScreenState extends State<FruitsQuizScreen>
    with SingleTickerProviderStateMixin {
  static const int sessionSize = 5;

  late List<int> activeIndices;
  late int currentSlot;
  bool isOptionSelected = false;

  final Map<int, bool> _sessionAnswers = {};
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Use your real images under assets/images/fruit/
  final List<Map<String, dynamic>> questions = [
    {"image": "assets/images/fruit/apple.jpg",      "options": ["Banana","Apple","Orange","Grape"], "correctIndex": 1},
    {"image": "assets/images/fruit/banana.jpg",     "options": ["Banana","Mango","Pear","Peach"], "correctIndex": 0},
    {"image": "assets/images/fruit/ciku.jpg",       "options": ["Apple","Ciku","Watermelon","Pineapple"], "correctIndex": 1},
    {"image": "assets/images/fruit/coconut.jpg",    "options": ["Cherry","Lemon","Coconut","Strawberry"], "correctIndex": 2},
    {"image": "assets/images/fruit/corn.jpg",       "options": ["Mango","Pear","Banana","Peach"], "correctIndex": 2},
    {"image": "assets/images/fruit/duku.jpg",       "options": ["Orange","Duku","Grape","Pear"], "correctIndex": 1},
    {"image": "assets/images/fruit/durian.jpg",     "options": ["Apple","Strawberry","Durian","Plum"], "correctIndex": 2},
    {"image": "assets/images/fruit/grape.jpg",      "options": ["Grape","Kiwi","Watermelon","Papaya"], "correctIndex": 0},
    {"image": "assets/images/fruit/langsat.jpg",    "options": ["Langsat","Banana","Grape","Orange"], "correctIndex": 0},
    {"image": "assets/images/fruit/lemon.jpg",      "options": ["Pear","Banana","Peach","Lemon"], "correctIndex": 3},
    {"image": "assets/images/fruit/mango.jpg",      "options": ["Pineapple","Watermelon","Mango","Apple"], "correctIndex": 2},
    {"image": "assets/images/fruit/mangosteen.jpg", "options": ["Lemon","Mangosteen","Strawberry","Grape"], "correctIndex": 1},
    {"image": "assets/images/fruit/orange.jpg",     "options": ["Peach","Orange","Banana","Mango"], "correctIndex": 1},
    {"image": "assets/images/fruit/papaya.jpg",     "options": ["Papaya","Grape","Orange","Pineapple"], "correctIndex": 0},
    {"image": "assets/images/fruit/peanut.jpg",     "options": ["Apple","Plum","Strawberry","Peanut"], "correctIndex": 3},
    {"image": "assets/images/fruit/pear.jpg",       "options": ["Kiwi","Pear","Papaya","Watermelon"], "correctIndex": 1},
    {"image": "assets/images/fruit/pineapple.jpg",  "options": ["Pineapple","Orange","Banana","Apple"], "correctIndex": 0},
    {"image": "assets/images/fruit/pomelo.jpg",     "options": ["Banana","Peach","Pear","Pomelo"], "correctIndex": 3},
    {"image": "assets/images/fruit/rambutan.jpg",   "options": ["Rambutan","Apple","Orange","Watermelon"], "correctIndex": 0},
    {"image": "assets/images/fruit/sour-sop.jpg",   "options": ["Banana","Durian","Soursop","Watermelon"], "correctIndex": 2},
    {"image": "assets/images/fruit/starfruit.jpg",  "options": ["Ciku","Starfruit","Pomelo","Apple"], "correctIndex": 1},
    {"image": "assets/images/fruit/sugar cane.jpg", "options": ["Durian","Sugar Cane","Coconut","Watermelon"], "correctIndex": 1},
    {"image": "assets/images/fruit/watermelon.jpg", "options": ["Corn","Watermelon","Mango","Peanut"], "correctIndex": 1},
  ];


  bool _isAnsweredInSession(int qIdx) => _sessionAnswers.containsKey(qIdx);

  int _firstUnansweredSlot() {
    for (int s = 0; s < activeIndices.length; s++) {
      if (!_isAnsweredInSession(activeIndices[s])) return s;
    }
    return 0;
  }

  bool _allAnsweredInSession() {
    for (final i in activeIndices) {
      if (!_sessionAnswers.containsKey(i)) return false;
    }
    return true;
  }

  int? _nextUnansweredSlotAfter(int fromSlot) {
    for (int s = fromSlot + 1; s < activeIndices.length; s++) {
      if (!_isAnsweredInSession(activeIndices[s])) return s;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    activeIndices = all.take(sessionSize).toList();

    int startSlot = widget.startIndex ?? _firstUnansweredSlot();
    startSlot = startSlot.clamp(0, activeIndices.length - 1);
    currentSlot = startSlot;

    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;
    final qIdx = activeIndices[currentSlot];
    if (_sessionAnswers.containsKey(qIdx)) return;

    setState(() => isOptionSelected = true);

    final correctIndex = questions[qIdx]['correctIndex'] as int;
    final isCorrect = selectedIndex == correctIndex;

    _sessionAnswers[qIdx] = isCorrect;

    if (isCorrect) {
      final oldLvl = QuestStatus.level;
      final levels = QuestStatus.addXp(20);
      _toast(icon: Icons.star, color: Colors.green.shade600, title: "Correct!", sub: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}");

      if (levels > 0) {
        final newlyUnlocked = QuestStatus.unlockedBetween(oldLvl, QuestStatus.level);
        for (final key in newlyUnlocked) {
          _toast(icon: Icons.lock_open, color: Colors.teal.shade700, title: "New Level Unlocked!", sub: QuestStatus.titleFor(key));
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } else {
      final correct = (questions[qIdx]['options'] as List)[correctIndex].toString();
      _toast(icon: Icons.close, color: Colors.red.shade600, title: "Incorrect", sub: "Correct: $correct");
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;
      final sessionScore = activeIndices.where((i) => _sessionAnswers[i] == true).length;

      _toast(icon: Icons.emoji_events, color: Colors.blue.shade600, title: "Quiz Complete!", sub: "Score: $sessionScore/${activeIndices.length}");

      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease && mounted) {
        _toast(icon: Icons.local_fire_department, color: Colors.deepOrange.shade600, title: "Streak +1!", sub: "Current streak: ${QuestStatus.streakDays}");
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final nextSlot = _nextUnansweredSlotAfter(currentSlot);
      setState(() {
        currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(0, activeIndices.length - 1);
        isOptionSelected = false;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  void _toast({required IconData icon, required Color color, required String title, required String sub}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60, right: 16,
        child: _SlideToast(bgColor: color, icon: icon, title: title, subtitle: sub),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = (question['options'] as List).map((e) => e.toString()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Fruits Level"), backgroundColor: Colors.blue.shade700),
      body: Container(
        color: Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Column(
              children: [
                Text("Question ${currentSlot + 1} of ${activeIndices.length}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Image.asset(question['image'], fit: BoxFit.contain, height: 180),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    children: List.generate(options.length, (i) {
                      return _kahootButton(options[i], _colors[i], () => handleAnswer(i));
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kahootButton(String label, Color color, VoidCallback onTap) {
    final qIdx = activeIndices[currentSlot];
    final alreadyAnswered = _sessionAnswers.containsKey(qIdx);

    return GestureDetector(
      onTap: alreadyAnswered ? null : onTap,
      child: Opacity(
        opacity: alreadyAnswered ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 4))],
          ),
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  List<Color> get _colors => const [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
  ];
}

class _SlideToast extends StatefulWidget {
  final Color bgColor;
  final IconData icon;
  final String title;
  final String subtitle;
  const _SlideToast({required this.bgColor, required this.icon, required this.title, required this.subtitle});

  @override
  State<_SlideToast> createState() => _SlideToastState();
}

class _SlideToastState extends State<_SlideToast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..forward();
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero)
      .chain(CurveTween(curve: Curves.easeOut)).animate(_ctrl);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.bgColor, borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
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