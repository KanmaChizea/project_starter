import 'dart:math';
import 'dart:ui';

class ScaleUtil {
  ScaleUtil._();

  static double _widthFactor = 1.0;
  static double _heightFactor = 1.0;

  // No phone goes past this, so phones scale exactly as designed while
  // tablets don't blow everything up to twice the size.
  static const _maxFactor = 1.2;

  /// [designWidth] & [designHeight] the dimensions your UI was designed for
  static void init({double designWidth = 375, double designHeight = 812}) {
    final view = PlatformDispatcher.instance.views.first;
    update(
      view.physicalSize / view.devicePixelRatio,
      designWidth: designWidth,
      designHeight: designHeight,
    );
  }

  /// Recalculates the factors for a new window size, e.g. after rotating or
  /// resizing an iPad split view. Uses the shortest and longest sides so
  /// sizes don't change with orientation.
  static void update(
    Size size, {
    double designWidth = 375,
    double designHeight = 812,
  }) {
    _widthFactor = min(size.shortestSide / designWidth, _maxFactor);
    _heightFactor = min(size.longestSide / designHeight, _maxFactor);
  }

  /// Scale font size. Only 30% of the width factor is applied so text
  /// doesn't grow or shrink as aggressively as layout dimensions.
  static double sp(double fontSize) {
    return fontSize * 0.7 + fontSize * _widthFactor * 0.3;
  }

  /// Scale width-based size (icons, buttons, paddings)
  static double w(double width) => width * _widthFactor;

  /// Scale height-based size (vertical spacing, containers)
  static double h(double height) => height * _heightFactor;
}

extension ScalingExtensions on num {
  double get w => ScaleUtil.w(toDouble());
  double get h => ScaleUtil.h(toDouble());
  double get sp => ScaleUtil.sp(toDouble());
  double get r => ScaleUtil.w(toDouble());
}
