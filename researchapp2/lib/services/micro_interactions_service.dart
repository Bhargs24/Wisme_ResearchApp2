import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for adding delightful micro-interactions throughout the app
class MicroInteractionsService {
  /// Provide haptic feedback for different interaction types
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  /// Create smooth scale animation for button presses
  static Widget createPressableCard({
    required Widget child,
    required VoidCallback onTap,
    bool enableHaptic = true,
    double scaleAmount = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _PressableCard(
      onTap: onTap,
      enableHaptic: enableHaptic,
      scaleAmount: scaleAmount,
      duration: duration,
      child: child,
    );
  }

  /// Create floating action animation
  static Widget createFloatingAction({
    required Widget child,
    required VoidCallback onTap,
    Duration delay = Duration.zero,
  }) {
    return _FloatingActionWidget(
      onTap: onTap,
      delay: delay,
      child: child,
    );
  }

  /// Create slide-in animation for content
  static Widget createSlideIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
    Offset begin = const Offset(0, 0.1),
  }) {
    return _SlideInWidget(
      delay: delay,
      duration: duration,
      begin: begin,
      child: child,
    );
  }

  /// Create fade-in animation
  static Widget createFadeIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _FadeInWidget(
      delay: delay,
      duration: duration,
      child: child,
    );
  }

  /// Create progress indicator with smooth animation
  static Widget createAnimatedProgress({
    required double progress,
    Color? color,
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return _AnimatedProgressIndicator(
      progress: progress,
      color: color,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  /// Create shimmer loading effect
  static Widget createShimmerLoading({
    required Widget child,
    bool isLoading = true,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _ShimmerLoading(
      isLoading: isLoading,
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      child: child,
    );
  }

  /// Create success celebration animation
  static void showSuccessCelebration(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessCelebrationDialog(message: message),
    );
  }
}

/// Pressable card widget with scale animation
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enableHaptic;
  final double scaleAmount;
  final Duration duration;

  const _PressableCard({
    required this.child,
    required this.onTap,
    this.enableHaptic = true,
    this.scaleAmount = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleAmount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        if (widget.enableHaptic) {
          MicroInteractionsService.lightHaptic();
        }
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Floating action widget with bounce animation
class _FloatingActionWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration delay;

  const _FloatingActionWidget({
    required this.child,
    required this.onTap,
    this.delay = Duration.zero,
  });

  @override
  State<_FloatingActionWidget> createState() => _FloatingActionWidgetState();
}

class _FloatingActionWidgetState extends State<_FloatingActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Slide-in animation widget
class _SlideInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset begin;

  const _SlideInWidget({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.begin = const Offset(0, 0.1),
  });

  @override
  State<_SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<_SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Fade-in animation widget
class _FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const _FadeInWidget({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<_FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Animated progress indicator
class _AnimatedProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;

  const _AnimatedProgressIndicator({
    required this.progress,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<_AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<_AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation.value,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation(widget.color),
        );
      },
    );
  }
}

/// Shimmer loading effect
class _ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerLoading({
    required this.child,
    this.isLoading = true,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Success celebration dialog
class _SuccessCelebrationDialog extends StatefulWidget {
  final String message;

  const _SuccessCelebrationDialog({required this.message});

  @override
  State<_SuccessCelebrationDialog> createState() => _SuccessCelebrationDialogState();
}

class _SuccessCelebrationDialogState extends State<_SuccessCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleController.forward();
    
    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _fadeController.forward().then((_) {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
