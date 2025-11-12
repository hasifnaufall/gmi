import 'package:flutter/material.dart';
import 'sound_manager.dart';

class SoundWrapper extends StatelessWidget {
  final Widget child;

  const SoundWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        SoundManager().playClick();
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}