import 'package:flutter/material.dart';

class CustomPageTransitions {
  // Slide transition dari kanan ke kiri
  static Widget slideRightToLeft(Widget child, Animation<double> animation) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  // Slide transition dari kiri ke kanan
  static Widget slideLeftToRight(Widget child, Animation<double> animation) {
    const begin = Offset(-1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  // Fade transition dengan scale
  static Widget fadeScale(Widget child, Animation<double> animation) {
    const curve = Curves.easeInOutCubic;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Interval(0.5, 1.0, curve: curve),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.5, curve: curve),
        ),
        child: child,
      ),
    );
  }

  // Slide transition dari bawah ke atas (untuk dialog/modal)
  static Widget slideUp(Widget child, Animation<double> animation) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  // Slide transition dari atas ke bawah
  static Widget slideDown(Widget child, Animation<double> animation) {
    const begin = Offset(0.0, -1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;

  CustomPageRoute({
    required this.child,
    this.transitionType = TransitionType.slideRightToLeft,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case TransitionType.slideRightToLeft:
                return CustomPageTransitions.slideRightToLeft(child, animation);
              case TransitionType.slideLeftToRight:
                return CustomPageTransitions.slideLeftToRight(child, animation);
              case TransitionType.fadeScale:
                return CustomPageTransitions.fadeScale(child, animation);
              case TransitionType.slideUp:
                return CustomPageTransitions.slideUp(child, animation);
              case TransitionType.slideDown:
                return CustomPageTransitions.slideDown(child, animation);
            }
          },
        );
}

enum TransitionType {
  slideRightToLeft,
  slideLeftToRight,
  fadeScale,
  slideUp,
  slideDown,
}

// Helper functions untuk kemudahan penggunaan
class NavigationHelper {
  // Navigate dengan transisi default (slide right to left)
  static Future<T?> navigateTo<T>(
    BuildContext context,
    Widget page, {
    TransitionType transitionType = TransitionType.slideRightToLeft,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        child: page,
        transitionType: transitionType,
        duration: duration,
      ),
    );
  }

  // Navigate dan replace dengan transisi
  static Future<T?> navigateToReplace<T>(
    BuildContext context,
    Widget page, {
    TransitionType transitionType = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      CustomPageRoute<T>(
        child: page,
        transitionType: transitionType,
        duration: duration,
      ),
    );
  }

  // Navigate dan remove all previous routes (untuk login/logout)
  static Future<T?> navigateToAndClear<T>(
    BuildContext context,
    Widget page, {
    TransitionType transitionType = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      CustomPageRoute<T>(
        child: page,
        transitionType: transitionType,
        duration: duration,
      ),
      (route) => false,
    );
  }

  // Pop dengan transisi smooth
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}
