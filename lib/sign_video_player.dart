import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SignVideoPlayer extends StatefulWidget {
  final String title;
  final String videoPath;
  final List<Map<String, String>>? allItems; // All videos in the category
  final int? initialIndex; // Starting position

  const SignVideoPlayer({
    super.key,
    required this.title,
    required this.videoPath,
    this.allItems,
    this.initialIndex,
  });

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _ready = false;
  bool _popped = false; // guard against double-pop
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // PageView support
  late PageController _pageController;
  late int _currentIndex;
  String _currentTitle = "";
  String _currentVideoPath = "";
  final Set<String> _watchedInSession = {}; // Track watched videos in this session

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _currentTitle = widget.title;
    _currentVideoPath = widget.videoPath;

    // Initialize PageController
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    
    try {
      final vc = VideoPlayerController.asset(_currentVideoPath);
      await vc.initialize();
      
      if (!mounted) {
        vc.dispose();
        return;
      }
      
      // build chewie only after successful init and mount check
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
        cc.dispose();
        vc.dispose();
        return;
      }
      
      setState(() {
        _videoController = vc;
        _chewieController = cc;
        _ready = true;
      });
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't load video: $e"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onPageChanged(int index) async {
    if (index == _currentIndex) return; // Prevent duplicate calls
    
    // Mark previous video as watched if played for 1.5s
    await _markCurrentAsWatchedIfNeeded();

    // Store old controllers to dispose after new ones are created
    final oldChewieController = _chewieController;
    final oldVideoController = _videoController;
    
    // Clear references first
    _chewieController = null;
    _videoController = null;

    // Update to new video
    if (mounted) {
      setState(() {
        _currentIndex = index;
        _currentTitle = widget.allItems![index]['label']!;
        _currentVideoPath = widget.allItems![index]['video']!;
        _ready = false;
      });
    }

    // Dispose old controllers after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      oldChewieController?.dispose();
      oldVideoController?.dispose();
    });

    // Initialize new video
    if (mounted) {
      await _init();
    }
  }

  Future<void> _markCurrentAsWatchedIfNeeded() async {
    try {
      final vc = _videoController;
      if (vc != null && vc.value.isInitialized) {
        final pos = await vc.position ?? Duration.zero;
        if (pos.inMilliseconds >= 1500) {
          _watchedInSession.add(_currentTitle);
        }
      }
    } catch (_) {
      // Silently handle errors
    }
  }

  Future<bool> _onWillPop() async {
    // Prevent double-pop races
    if (_popped) return false;
    _popped = true;

    // Mark current video as watched if needed
    await _markCurrentAsWatchedIfNeeded();

    if (mounted) {
      // If using swipe mode (allItems provided), return the set of watched videos
      // Otherwise, return single bool
      if (widget.allItems != null) {
        Navigator.of(context).pop(_watchedInSession);
      } else {
        bool watched = _watchedInSession.contains(_currentTitle);
        Navigator.of(context).pop(watched);
      }
    }
    return false; // we already popped
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    
    // Dispose video controllers safely
    try {
      _chewieController?.pause();
      _chewieController?.dispose();
    } catch (_) {}
    
    try {
      _videoController?.dispose();
    } catch (_) {}
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use last known aspect ratio if available, otherwise a safe default
    final ar = (_videoController?.value.isInitialized ?? false)
        ? _videoController!.value.aspectRatio
        : 16 / 9;

    // Show swipe hint if multiple items available
    final bool hasMultipleItems = (widget.allItems?.length ?? 0) > 1;
    final int totalItems = widget.allItems?.length ?? 1;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text("Learn $_currentTitle"),
            ),
          ),
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
          actions: hasMultipleItems
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${_currentIndex + 1} / $totalItems",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              : null,
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
            // PageView for swipe support OR single player
            if (hasMultipleItems)
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const PageScrollPhysics(),
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  // Only show video player for current page
                  if (index == _currentIndex) {
                    return Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: !_ready || _chewieController == null
                              ? const CircularProgressIndicator(color: Colors.white)
                              : (_videoController?.value.isInitialized ?? false)
                                  ? AspectRatio(
                                      aspectRatio: ar == 0 ? (16 / 9) : ar,
                                      child: Chewie(controller: _chewieController!),
                                    )
                                  : const CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    // Empty placeholder for other pages
                    return const SizedBox.shrink();
                  }
                },
              )
            else
              // Single video mode (no swipe)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: !_ready || _chewieController == null
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (_videoController?.value.isInitialized ?? false)
                            ? AspectRatio(
                                aspectRatio: ar == 0 ? (16 / 9) : ar,
                                child: Chewie(controller: _chewieController!),
                              )
                            : const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            // Swipe hint overlay (shows for first 3 seconds)
            if (hasMultipleItems)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 0.0),
                  duration: const Duration(seconds: 3),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.swipe, color: Colors.white, size: 22),
                              SizedBox(width: 12),
                              Text(
                                "Swipe to navigate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
