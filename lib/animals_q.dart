import 'package:flutter/material.dart';
import 'quest_status.dart';

class AnimalQuizScreen extends StatefulWidget {
  final int? startIndex;
  const AnimalQuizScreen({super.key, this.startIndex});

  @override
  State<AnimalQuizScreen> createState() => _AnimalQuizScreenState();
}

class _AnimalQuizScreenState extends State<AnimalQuizScreen>
    with SingleTickerProviderStateMixin {
  static const int sessionSize = 5;

  late List<int> activeIndices;
  late int currentSlot;
  bool isOptionSelected = false;
  int? _pendingIndex; // selected option awaiting confirmation

  final Map<int, bool> _sessionAnswers = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Provide your real images under assets/images/animals/
  final List<Map<String, dynamic>> rawQuestions = [
    // anai = termite
    {
      "image": "assets/images/animal/anai.jpg",
      "options": ["Ant", "Termite", "Wasp", "Bee"],
      "correctIndex": 1,
    },
    // angsa = goose
    {
      "image": "assets/images/animal/angsa.jpg",
      "options": ["Duck", "Goose", "Swan", "Turkey"],
      "correctIndex": 1,
    },
    // anjing = dog
    {
      "image": "assets/images/animal/anjing.jpg",
      "options": ["Fox", "Wolf", "Dog", "Coyote"],
      "correctIndex": 2,
    },
    // arnab = rabbit
    {
      "image": "assets/images/animal/arnab.jpg",
      "options": ["Hamster", "Rabbit", "Mouse", "Guinea Pig"],
      "correctIndex": 1,
    },
    // ayam = chicken
    {
      "image": "assets/images/animal/ayam.jpg",
      "options": ["Chicken", "Duck", "Goose", "Turkey"],
      "correctIndex": 0,
    },
    // babi = pig
    {
      "image": "assets/images/animal/babi.jpg",
      "options": ["Boar", "Pig", "Cow", "Goat"],
      "correctIndex": 1,
    },
    // badak sumbu = rhinoceros
    {
      "image": "assets/images/animal/badak sumbu.jpg",
      "options": ["Hippopotamus", "Rhinoceros", "Buffalo", "Elephant"],
      "correctIndex": 1,
    },
    // belalang = grasshopper
    {
      "image": "assets/images/animal/belalang.jpg",
      "options": ["Cricket", "Locust", "Grasshopper", "Praying Mantis"],
      "correctIndex": 2,
    },
    // beruang = bear
    {
      "image": "assets/images/animal/beruang.jpg",
      "options": ["Bear", "Lion", "Tiger", "Wolf"],
      "correctIndex": 0,
    },
    // biawak = monitor lizard
    {
      "image": "assets/images/animal/biawak.jpg",
      "options": ["Iguana", "Monitor Lizard", "Crocodile", "Gecko"],
      "correctIndex": 1,
    },
    // biri (biri-biri) = sheep
    {
      "image": "assets/images/animal/biri.jpg",
      "options": ["Goat", "Sheep", "Cow", "Yak"],
      "correctIndex": 1,
    },
    // buaya = crocodile
    {
      "image": "assets/images/animal/buaya.jpg",
      "options": ["Alligator", "Crocodile", "Monitor Lizard", "Snake"],
      "correctIndex": 1,
    },
    // burung = bird
    {
      "image": "assets/images/animals/burung.jpg",
      "options": ["Bird", "Eagle", "Duck", "Owl"],
      "correctIndex": 0,
    },
    // cicak = gecko
    {
      "image": "assets/images/animal/cicak.jpg",
      "options": ["Lizard", "Chameleon", "Gecko", "Newt"],
      "correctIndex": 2,
    },
    // gajah = elephant
    {
      "image": "assets/images/animal/gajah.jpg",
      "options": ["Rhino", "Hippo", "Elephant", "Buffalo"],
      "correctIndex": 2,
    },
    // gorila = gorilla
    {
      "image": "assets/images/animal/gorila.jpg",
      "options": ["Gorilla", "Chimpanzee", "Orangutan", "Baboon"],
      "correctIndex": 0,
    },
    // harimau = tiger
    {
      "image": "assets/images/animal/harimau.jpg",
      "options": ["Lion", "Leopard", "Cheetah", "Tiger"],
      "correctIndex": 3,
    },
    // helang = eagle
    {
      "image": "assets/images/animal/helang.jpg",
      "options": ["Falcon", "Eagle", "Hawk", "Owl"],
      "correctIndex": 1,
    },
    // ikan = fish
    {
      "image": "assets/images/animal/ikan.jpg",
      "options": ["Seal", "Dolphin", "Fish", "Shark"],
      "correctIndex": 2,
    },
    // itik = duck
    {
      "image": "assets/images/animal/itik.jpg",
      "options": ["Goose", "Turkey", "Chicken", "Duck"],
      "correctIndex": 3,
    },
    // jengking = scorpion
    {
      "image": "assets/images/animal/jengking.jpg",
      "options": ["Scorpion", "Spider", "Centipede", "Beetle"],
      "correctIndex": 0,
    },
    // kambing = goat
    {
      "image": "assets/images/animal/kambing.jpg",
      "options": ["Sheep", "Goat", "Cow", "Deer"],
      "correctIndex": 1,
    },
    // kancil = mouse-deer
    {
      "image": "assets/images/animal/kancil.jpg",
      "options": ["Mouse-deer", "Deer", "Antelope", "Gazelle"],
      "correctIndex": 0,
    },
    // labah (labah-labah) = spider
    {
      "image": "assets/images/animal/Labah.jpg",
      "options": ["Cockroach", "Ant", "Spider", "Mantis"],
      "correctIndex": 2,
    },
    // merak = peacock
    {
      "image": "assets/images/animal/merak.jpg",
      "options": ["Peacock", "Turkey", "Parrot", "Swan"],
      "correctIndex": 0,
    },
    // rama-rama = butterfly
    {
      "image": "assets/images/animal/rama-rama.jpg",
      "options": ["Moth", "Butterfly", "Dragonfly", "Bee"],
      "correctIndex": 1,
    },
    // singa = lion
    {
      "image": "assets/images/animal/singa.jpg",
      "options": ["Cheetah", "Leopard", "Tiger", "Lion"],
      "correctIndex": 3,
    },
    // zirafah = giraffe
    {
      "image": "assets/images/animal/zirafah.jpg",
      "options": ["Giraffe", "Camel", "Alpaca", "Donkey"],
      "correctIndex": 0,
    },
  ];

  late final List<Map<String, dynamic>> questions = rawQuestions
      .map(
        (q) => {
          "image": q["image"],
          "options": List<String>.from(q["options"]),
          "correctIndex": q["correctIndex"],
        },
      )
      .toList();

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
    final take = all.length < sessionSize ? all.length : sessionSize;
    activeIndices = all.take(take).toList();

    int startSlot = widget.startIndex ?? _firstUnansweredSlot();
    startSlot = startSlot.clamp(0, activeIndices.length - 1);
    currentSlot = startSlot;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmExitQuiz() async {
    final first = await showDialog<bool>(
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

    final second = await showDialog<bool>(
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
      _popup(
        icon: Icons.star,
        iconColor: Colors.yellow.shade700,
        title: "Correct!",
        subtitle: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}",
        bg: Colors.green.shade600,
      );

      if (levels > 0) {
        final newly = QuestStatus.unlockedBetween(oldLvl, QuestStatus.level);
        for (final key in newly) {
          _popup(
            icon: Icons.lock_open,
            iconColor: Colors.lightGreenAccent,
            title: "New Level Unlocked!",
            subtitle: QuestStatus.titleFor(key),
            bg: Colors.teal.shade700,
          );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } else {
      final correctText = (questions[qIdx]['options'] as List)[correctIndex]
          .toString();
      _popup(
        icon: Icons.close,
        iconColor: Colors.redAccent,
        title: "Incorrect",
        subtitle: "Correct: $correctText",
        bg: Colors.red.shade600,
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;
      final sessionScore = activeIndices
          .where((i) => _sessionAnswers[i] == true)
          .length;

      _popup(
        icon: Icons.emoji_events,
        iconColor: Colors.amber,
        title: "Quiz Complete!",
        subtitle: "Score: $sessionScore/${activeIndices.length}",
        bg: Colors.blue.shade600,
      );

      final streakUp = QuestStatus.addStreakForLevel();
      if (streakUp && mounted) {
        _popup(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: "Streak +1!",
          subtitle: "Current streak: ${QuestStatus.streakDays}",
          bg: Colors.deepOrange.shade600,
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final nextSlot = _nextUnansweredSlotAfter(currentSlot);
      setState(() {
        currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(
          0,
          activeIndices.length - 1,
        );
        isOptionSelected = false;
        _pendingIndex = null;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  void _popup({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color bg,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        right: 16,
        child: _Toast(
          icon: icon,
          iconColor: iconColor,
          title: title,
          subtitle: subtitle,
          bg: bg,
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  Widget _optionTile(String label, int index) {
    final answered = _sessionAnswers.containsKey(activeIndices[currentSlot]);
    final isPending = _pendingIndex == index;
    return GestureDetector(
      onTap: answered
          ? null
          : () {
              setState(() => _pendingIndex = index);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFC6DDFF),
          borderRadius: BorderRadius.circular(16),
          border: isPending ? Border.all(color: Colors.teal, width: 2) : null,
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
                label,
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
  }

  Widget _buildProgressBar() {
    final total = activeIndices.length;
    int correct = 0, wrong = 0;
    for (final i in activeIndices) {
      if (_sessionAnswers.containsKey(i)) {
        if (_sessionAnswers[i] == true) {
          correct++;
        } else {
          wrong++;
        }
      }
    }
    final remaining = total - correct - wrong;

    Widget seg(Color c, int flex) => Expanded(
      flex: flex,
      child: Container(color: c),
    );
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
              if (correct > 0) seg(Colors.green, correct),
              if (wrong > 0) seg(Colors.red, wrong),
              if (remaining > 0) seg(Colors.grey.shade400, remaining),
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

  Widget _buildConfirmBar(List<String> options) {
    final qIdx = activeIndices[currentSlot];
    final already = _sessionAnswers.containsKey(qIdx);
    if (_pendingIndex == null || already) return const SizedBox.shrink();

    final label = options[_pendingIndex!];
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
              backgroundColor: const Color(0xFF4AFF7C),
            ),
            onPressed: () {
              final idx = _pendingIndex;
              if (idx != null) handleAnswer(idx);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = (question['options'] as List)
        .map((e) => e.toString())
        .toList();

    return WillPopScope(
      onWillPop: () async => await _confirmExitQuiz(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Animals Level"),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2C5CB0),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Question ${currentSlot + 1} of ${activeIndices.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProgressBar(),
                const SizedBox(height: 14),
                // Question card with image + fallback
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
                      question['image'],
                      fit: BoxFit.contain,
                      height: 180,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
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
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (_, i) => _optionTile(options[i], i),
                  ),
                ),
                _buildConfirmBar(options),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color bg;
  const _Toast({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.bg,
  });

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    offset = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: widget.bg,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 280,
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
