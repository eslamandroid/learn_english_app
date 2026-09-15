library page_transition;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTransition<T> extends CustomTransitionPage<T> {
  /// Child for your next page
  final Widget? childCurrent;

  /// Transition types
  ///  fade,rightToLeft,leftToRight, upToDown,downToUp,scale,rotate,size,rightToLeftWithFade,leftToRightWithFade
  final PageTransitionType type;

  /// Curves for transitions
  final Curve curve;

  /// Alignment for transitions
  final Alignment? alignment;

  /// Duration for your transition default is 300 ms
  final Duration duration;

  /// Duration for your pop transition default is 300 ms
  final Duration reverseDuration;

  final bool isIos;

  PageTransition({
    Key? key,
    required Widget child,
    required this.type,
    this.childCurrent,
    this.curve = Curves.linear,
    this.alignment,
    Color barrierColor = Colors.black26,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration = const Duration(milliseconds: 200),
    bool fullscreenDialog = false,
    bool opaque = false,
    this.isIos = false,
  }) : super(
          transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(opacity: animation, child: child);

              /// PageTransitionType.rightToLeft which is the give us right to left transition
              case PageTransitionType.rightToLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );

              /// PageTransitionType.leftToRight which is the give us left to right transition
              case PageTransitionType.leftToRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );

              /// PageTransitionType.topToBottom which is the give us up to down transition
              case PageTransitionType.topToBottom:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              // ignore: dead_code

              /// PageTransitionType.downToUp which is the give us down to up transition
              case PageTransitionType.bottomToTop:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );

              /// PageTransitionType.scale which is the scale functionality for transition you can also use curve for this transition

              case PageTransitionType.scale:
                assert(alignment != null, "we require alignment");
                return ScaleTransition(
                  alignment: alignment!,
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      0.00,
                      0.50,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );

              /// PageTransitionType.rotate which is the rotate functionality for transition you can also use alignment for this transition

              case PageTransitionType.rotate:
                return RotationTransition(
                  alignment: alignment!,
                  turns: animation,
                  child: ScaleTransition(
                    alignment: alignment,
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );

              /// PageTransitionType.size which is the rotate functionality for transition you can also use curve for this transition

              case PageTransitionType.size:
                return Align(
                  alignment: alignment!,
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                    child: child,
                  ),
                );

              /// PageTransitionType.rightToLeftWithFade which is the fade functionality from right o left

              case PageTransitionType.rightToLeftWithFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );

              /// PageTransitionType.leftToRightWithFade which is the fade functionality from left o right with curve

              case PageTransitionType.leftToRightWithFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );

              case PageTransitionType.rightToLeftJoined:
                return Stack(
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(-1.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: child,
                    )
                  ],
                );

              case PageTransitionType.leftToRightJoined:
                return Stack(
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: const Offset(0.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: child,
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    )
                  ],
                );

              case PageTransitionType.topToBottomJoined:
                return Stack(
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -1.0),
                        end: const Offset(0.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: child,
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(0.0, 1.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    )
                  ],
                );

              case PageTransitionType.bottomToTopJoined:
                return Stack(
                  children: <Widget>[
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: const Offset(0.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: child,
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(0.0, -1.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    )
                  ],
                );

              case PageTransitionType.rightToLeftPop:
                return Stack(
                  children: <Widget>[
                    child,
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(-1.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    ),
                  ],
                );

              case PageTransitionType.leftToRightPop:
                return Stack(
                  children: <Widget>[
                    child,
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 0.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    )
                  ],
                );

              case PageTransitionType.topToBottomPop:
                return Stack(
                  children: <Widget>[
                    child,
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(0.0, 1.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    )
                  ],
                );

              case PageTransitionType.bottomToTopPop:
                return Stack(
                  children: <Widget>[
                    child,
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(0.0, -1.0),
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        ),
                      ),
                      child: childCurrent,
                    )
                  ],
                );
              }
          },
          child: child,
          maintainState: true,
          barrierColor: barrierColor,
          opaque: opaque,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => reverseDuration;
}

/// Transition enum
enum PageTransitionType {
  /// Fade Animation
  fade,

  /// Right to left animation
  rightToLeft,

  /// Left to right animation
  leftToRight,

  /// Top to bottom animation
  topToBottom,

  /// Bottom to top animation
  bottomToTop,

  /// Scale animation
  scale,

  /// Rotate animation
  rotate,

  /// Size animation
  size,

  /// Right to left with fading animation
  rightToLeftWithFade,

  /// Left to right with fading animation
  leftToRightWithFade,

  /// Left to right slide as if joined
  leftToRightJoined,

  /// Right to left slide as if joined
  rightToLeftJoined,

  /// Top to bottom as if joined
  topToBottomJoined,

  /// Bottom to top as if joined
  bottomToTopJoined,

  /// Pop the current screen left to right
  leftToRightPop,

  /// Pop the current screen right to left
  rightToLeftPop,

  /// Pop the current screen top to bottom
  topToBottomPop,

  /// Pop the current screen bottom to top
  bottomToTopPop,
}
