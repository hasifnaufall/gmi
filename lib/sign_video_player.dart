import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SignVideoPlayer extends StatefulWidget {
  final String title;
  final String videoPath;

  const SignVideoPlayer({
    super.key,
    required this.title,
    required this.videoPath,
  });

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _ready = false;
  bool _popped = false; // guard against double-pop

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final vc = VideoPlayerController.asset(widget.videoPath);
      await vc.initialize();
      // build chewie only after successful init
      final cc = ChewieController(
        videoPlayerController: vc,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF0EA5E9),
          handleColor: const Color(0xFF22D3EE),
          backgroundColor: Colors.black26,
          bufferedColor: Colors.white24,
        ),
      );
      if (!mounted) {
        vc.dispose();
        cc.dispose();
        return;
      }
      setState(() {
        _videoController = vc;
        _chewieController = cc;
        _ready = true;
      });
    } catch (e) {
      // you can show a friendly error UI if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't load video: $e")),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Prevent double-pop races
    if (_popped) return false;
    _popped = true;

    bool watched = false;
    try {
      final vc = _videoController;
      if (vc != null && vc.value.isInitialized) {
        final pos = await vc.position ?? Duration.zero;
        watched = pos.inMilliseconds >= 1500; // >= 1.5s counts as watched
      }
    } catch (_) {
      watched = false;
    }

    if (mounted) {
      Navigator.of(context).pop(watched);
    }
    return false; // we already popped
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use last known aspect ratio if available, otherwise a safe default
    final ar = (_videoController?.value.isInitialized ?? false)
        ? _videoController!.value.aspectRatio
        : 16 / 9;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Learn ${widget.title}"),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _onWillPop();
            },
          ),
        ),
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // subtle dark overlay for focus
            Container(color: Colors.black.withOpacity(0.15)),
            // Player
            Center(
              child: !_ready || _chewieController == null
                  ? const CircularProgressIndicator(color: Colors.white)
                  : AspectRatio(
                aspectRatio: ar == 0 ? (16 / 9) : ar,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
