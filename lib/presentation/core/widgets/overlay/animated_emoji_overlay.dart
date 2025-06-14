import 'dart:math';
import 'package:flutter/material.dart';

/// Overlay hiệu ứng cảm xúc bay từ trên xuống với animation
class AnimatedEmojiOverlay extends StatefulWidget {
  final List<String> emojis;
  final Duration duration;
  final int emojiCount;
  final double emojiSize;
  final VoidCallback? onAnimationComplete;

  const AnimatedEmojiOverlay({
    super.key,
    required this.emojis,
    this.duration = const Duration(seconds: 3),
    this.emojiCount = 15,
    this.emojiSize = 30.0,
    this.onAnimationComplete,
  });

  /// Hiển thị hiệu ứng cảm xúc bay
  static void showEmojiRain(
    BuildContext context, {
    List<String> emojis = const ['❤️', '😍', '👍', '🎉', '✨', '🔥', '💖'],
    Duration duration = const Duration(seconds: 3),
    int emojiCount = 15,
    double emojiSize = 30.0,
    VoidCallback? onComplete,
  }) {
    try {
      final overlay = Overlay.of(context);
      debugPrint('Overlay found: $overlay');

      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          return AnimatedEmojiOverlay(
            emojis: emojis,
            duration: duration,
            emojiCount: emojiCount,
            emojiSize: emojiSize,
            onAnimationComplete: () {
              overlayEntry.remove();
              onComplete?.call();
            },
          );
        },
      );

      overlay.insert(overlayEntry);
    } catch (e, stackTrace) {
      debugPrint('Error in showEmojiRain: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  State<AnimatedEmojiOverlay> createState() => _AnimatedEmojiOverlayState();
}

class _AnimatedEmojiOverlayState extends State<AnimatedEmojiOverlay>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<EmojiData> _emojiData;
  final Random _random = Random();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _emojiData = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeAnimations();
      _isInitialized = true; // Set flag trước khi start animations
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    final screenSize = MediaQuery.of(context).size;

    for (int i = 0; i < widget.emojiCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds:
              widget.duration.inMilliseconds +
              _random.nextInt(1000), // Variation in duration
        ),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: -100,
        end: screenSize.height + 100,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInQuad));

      _controllers.add(controller);
      _animations.add(animation);

      // Tạo data cho mỗi emoji
      _emojiData.add(
        EmojiData(
          emoji: widget.emojis[_random.nextInt(widget.emojis.length)],
          x: _random.nextDouble() * screenSize.width,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 4,
          horizontalDrift: (_random.nextDouble() - 0.5) * 100,
          delay: _random.nextInt(500), // Delay up to 500ms
        ),
      );
    }
  }

  void _startAnimations() {
    if (!_isInitialized || _controllers.isEmpty) {
      return;
    }

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _emojiData[i].delay), () {
        if (mounted && _controllers.isNotEmpty && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }

    // Complete callback after all animations
    Future.delayed(
      Duration(milliseconds: widget.duration.inMilliseconds + 1500),
      () {
        if (mounted) {
          widget.onAnimationComplete?.call();
        }
      },
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa khởi tạo, return empty container
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: List.generate(
          widget.emojiCount,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final data = _emojiData[index];
              final progress = _controllers[index].value;

              return Positioned(
                left: data.x + (data.horizontalDrift * progress),
                top: _animations[index].value,
                child: Transform.rotate(
                  angle:
                      data.rotation + (data.rotationSpeed * progress * 2 * pi),
                  child: Opacity(
                    opacity: _calculateOpacity(progress),
                    child: Text(
                      data.emoji,
                      style: TextStyle(
                        fontSize: widget.emojiSize * _calculateScale(progress),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _calculateOpacity(double progress) {
    if (progress < 0.1) {
      return progress * 10; // Fade in
    } else if (progress > 0.8) {
      return (1 - progress) * 5; // Fade out
    }
    return 1.0;
  }

  double _calculateScale(double progress) {
    if (progress < 0.2) {
      return 0.5 + (progress * 2.5); // Scale up
    }
    return 1.0;
  }
}

/// Data class cho thông tin emoji
class EmojiData {
  final String emoji;
  final double x;
  final double rotation;
  final double rotationSpeed;
  final double horizontalDrift;
  final int delay;

  EmojiData({
    required this.emoji,
    required this.x,
    required this.rotation,
    required this.rotationSpeed,
    required this.horizontalDrift,
    required this.delay,
  });
}
