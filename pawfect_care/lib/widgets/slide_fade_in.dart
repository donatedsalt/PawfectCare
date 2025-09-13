import 'package:flutter/material.dart';

class SlideFadeIn extends StatefulWidget {
  final Widget child;
  final Offset beginOffset;
  final int delayMs;
  final Duration duration;

  const SlideFadeIn({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 0.2),
    this.delayMs = 0,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  SlideFadeInState createState() => SlideFadeInState();
}

class SlideFadeInState extends State<SlideFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _offsetAnim = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final offset = _offsetAnim.value;
        final opacity = _opacityAnim.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(offset.dx * 50, offset.dy * 50),
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
