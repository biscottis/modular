import 'package:flutter/widgets.dart';

enum PageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
}

class PageTransition<T> extends PageRouteBuilder<T> {
  final Widget Function(BuildContext context) builder;
  final PageTransitionType type;
  final Curve curve;
  final Alignment? alignment;
  final Duration duration;

  PageTransition({
    Key? key,
    required this.builder,
    required this.type,
    this.curve = Curves.easeInOut,
    this.alignment,
    this.duration = const Duration(milliseconds: 600),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return builder(context);
          },
          transitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              case PageTransitionType.rightToLeft:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(-1.0, 0.0),
                    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
              case PageTransitionType.leftToRight:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(1.0, 0.0),
                    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
              case PageTransitionType.upToDown:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(0.0, 1.0),
                    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
              case PageTransitionType.downToUp:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(0.0, -1.0),
                    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
              case PageTransitionType.scale:
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
              case PageTransitionType.rotate:
                return RotationTransition(
                  alignment: alignment!,
                  turns: CurvedAnimation(parent: animation, curve: curve),
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: CurvedAnimation(parent: animation, curve: curve),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              case PageTransitionType.size:
                return Align(
                  alignment: Alignment.center,
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                    child: child,
                  ),
                );
              case PageTransitionType.rightToLeftWithFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(-1.0, 0.0),
                      ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
                      child: child,
                    ),
                  ),
                );
              case PageTransitionType.leftToRightWithFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(1.0, 0.0),
                      ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
                      child: child,
                    ),
                  ),
                );
              default:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
        );
}
