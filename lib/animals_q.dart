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

  final Map<int, bool> _sessionAnswers = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Provide your real images under assets/images/animals/
  final List<Map<String, dynamic>> rawQuestions = [
    // anai = termite
    {
      "image": "assets/images/animal/anai.png",
      "options": ["Ant", "Termite", "Wasp", "Bee"],
      "correctIndex": 1
    },
    // angsa = goose
    {
      "image": "assets/images/animal/angsa.png",
      "options": ["Duck", "Goose", "Swan", "Turkey"],
      "correctIndex": 1
    },
    // anjing = dog
    {
      "image": "assets/images/animal/anjing.png",
      "options": ["Fox", "Wolf", "Dog", "Coyote"],
      "correctIndex": 2
    },
    // arnab = rabbit
    {
      "image": "assets/images/animal/arnab.png",
      "options": ["Hamster", "Rabbit", "Mouse", "Guinea Pig"],
      "correctIndex": 1
    },
    // ayam = chicken
    {
      "image": "assets/images/animal/ayam.png",
      "options": ["Chicken", "Duck", "Goose", "Turkey"],
      "correctIndex": 0
    },
    // babi = pig
    {
      "image": "assets/images/animal/babi.png",
      "options": ["Boar", "Pig", "Cow", "Goat"],
      "correctIndex": 1
    },
    // badak sumbu = rhinoceros
    {
      "image": "assets/images/animal/badak sumbu.png",
      "options": ["Hippopotamus", "Rhinoceros", "Buffalo", "Elephant"],
      "correctIndex": 1
    },
    // belalang = grasshopper
    {
      "image": "assets/images/animal/belalang.png",
      "options": ["Cricket", "Locust", "Grasshopper", "Praying Mantis"],
      "correctIndex": 2
    },
    // beruang = bear
    {
      "image": "assets/images/animal/beruang.png",
      "options": ["Bear", "Lion", "Tiger", "Wolf"],
      "correctIndex": 0
    },
    // biawak = monitor lizard
    {
      "image": "assets/images/animal/biawak.png",
      "options": ["Iguana", "Monitor Lizard", "Crocodile", "Gecko"],
      "correctIndex": 1
    },
    // biri (biri-biri) = sheep
    {
      "image": "assets/images/animal/biri.png",
      "options": ["Goat", "Sheep", "Cow", "Yak"],
      "correctIndex": 1
    },
    // buaya = crocodile
    {
      "image": "assets/images/animal/buaya.png",
      "options": ["Alligator", "Crocodile", "Monitor Lizard", "Snake"],
      "correctIndex": 1
    },
    // burung = bird
    {
      "image": "assets/images/animals/burung.png",
      "options": ["Bird", "Eagle", "Duck", "Owl"],
      "correctIndex": 0
    },
    // cicak = gecko
    {
      "image": "assets/images/animal/cicak.png",
      "options": ["Lizard", "Chameleon", "Gecko", "Newt"],
      "correctIndex": 2
    },
    // gajah = elephant
    {
      "image": "assets/images/animal/gajah.png",
      "options": ["Rhino", "Hippo", "Elephant", "Buffalo"],
      "correctIndex": 2
    },
    // gorila = gorilla
    {
      "image": "assets/images/animal/gorila.png",
      "options": ["Gorilla", "Chimpanzee", "Orangutan", "Baboon"],
      "correctIndex": 0
    },
    // harimau = tiger
    {
      "image": "assets/images/animal/harimau.png",
      "options": ["Lion", "Leopard", "Cheetah", "Tiger"],
      "correctIndex": 3
    },
    // helang = eagle
    {
      "image": "assets/images/animal/helang.png",
      "options": ["Falcon", "Eagle", "Hawk", "Owl"],
      "correctIndex": 1
    },
    // ikan = fish
    {
      "image": "assets/images/animal/ikan.png",
      "options": ["Seal", "Dolphin", "Fish", "Shark"],
      "correctIndex": 2
    },
    // itik = duck
    {
      "image": "assets/images/animal/itik.png",
      "options": ["Goose", "Turkey", "Chicken", "Duck"],
      "correctIndex": 3
    },
    // jengking = scorpion
    {
      "image": "assets/images/animal/jengking.png",
      "options": ["Scorpion", "Spider", "Centipede", "Beetle"],
      "correctIndex": 0
    },
    // kambing = goat
    {
      "image": "assets/images/animal/kambing.png",
      "options": ["Sheep", "Goat", "Cow", "Deer"],
      "correctIndex": 1
    },
    // kancil = mouse-deer
    {
      "image": "assets/images/animal/kancil.png",
      "options": ["Mouse-deer", "Deer", "Antelope", "Gazelle"],
      "correctIndex": 0
    },
    // labah (labah-labah) = spider
    {
      "image": "assets/images/animal/Labah.png",
      "options": ["Cockroach", "Ant", "Spider", "Mantis"],
      "correctIndex": 2
    },
    // merak = peacock
    {
      "image": "assets/images/animal/merak.png",
      "options": ["Peacock", "Turkey", "Parrot", "Swan"],
      "correctIndex": 0
    },
    // rama-rama = butterfly
    {
      "image": "assets/images/animal/rama-rama.png",
      "options": ["Moth", "Butterfly", "Dragonfly", "Bee"],
      "correctIndex": 1
    },
    // singa = lion
    {
      "image": "assets/images/animal/singa.png",
      "options": ["Cheetah", "Leopard", "Tiger", "Lion"],
      "correctIndex": 3
    },
    // zirafah = giraffe
    {
      "image": "assets/images/animal/zirafah.png",
      "options": ["Giraffe", "Camel", "Alpaca", "Donkey"],
      "correctIndex": 0
    },
  ];


  late final List<Map<String, dynamic>> questions =
  rawQuestions.map((q) => {
    "image": q["image"],
    "options": List<String>.from(q["options"]),
    "correctIndex": q["correctIndex"],
  }).toList();

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
      final correctText = (questions[qIdx]['options'] as List)[correctIndex].toString();
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
      final sessionScore = activeIndices.where((i) => _sessionAnswers[i] == true).length;

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
        currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(0, activeIndices.length - 1);
        isOptionSelected = false;
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
        child: _Toast(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle, bg: bg),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  Widget _kahootButton(String label, Color color, int index) {
    final qIdx = activeIndices[currentSlot];
    final already = _sessionAnswers.containsKey(qIdx);

    return GestureDetector(
      onTap: already ? null : () => handleAnswer(index),
      child: Opacity(
        opacity: already ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 4))],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = (question['options'] as List).map((e) => e.toString()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Animals Level"), backgroundColor: Colors.blue.shade700),
      body: Container(
        color: Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Column(
              children: [
                Text(
                  "Question ${currentSlot + 1} of ${activeIndices.length}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Image.asset(question['image'], fit: BoxFit.contain, height: 180),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    children: List.generate(options.length, (i) {
                      return _kahootButton(
                        options[i],
                        const [Colors.redAccent, Colors.blueAccent, Colors.orangeAccent, Colors.greenAccent][i],
                        i,
                      );
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
}

class _Toast extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color bg;
  const _Toast({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.bg});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this)..forward();
    offset = Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
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
                    Text(widget.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(widget.subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
