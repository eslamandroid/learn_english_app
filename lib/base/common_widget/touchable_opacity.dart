import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@immutable
class TouchableOpacity extends StatefulWidget {
  const TouchableOpacity({
    super.key,
    required this.child,
    this.activeOpacity = 0.2,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(activeOpacity >= 0.0 && activeOpacity <= 1.0);

  final Widget child;
  final double activeOpacity;

  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;

  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;
  final DragStartBehavior dragStartBehavior;

  @override
  State<TouchableOpacity> createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final lower = widget.activeOpacity.clamp(0.0, 1.0);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: lower,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: widget.behavior,
      excludeFromSemantics: widget.excludeFromSemantics,
      dragStartBehavior: widget.dragStartBehavior,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _controller.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.activeOpacity != 1.0) _controller.reverse();
    widget.onTapDown?.call(details);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.activeOpacity != 1.0) _controller.forward();
    widget.onTapUp?.call(details);
  }

  void _handleTapCancel() {
    if (widget.activeOpacity != 1.0) _controller.forward();
    widget.onTapCancel?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
