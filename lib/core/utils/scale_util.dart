import 'dart:ui';

class ScaleUtil {
  ScaleUtil._();

  static double _widthFactor = 1.0;
  static double _heightFactor = 1.0;

  /// [designWidth] & [designHeight] the dimensions your UI was designed for
  static void init({double designWidth = 375, double designHeight = 812}) {
    final view = PlatformDispatcher.instance.views.first;
    final deviceWidth = view.physicalSize.width / view.devicePixelRatio;
    final deviceHeight = view.physicalSize.height / view.devicePixelRatio;

    _widthFactor = deviceWidth / designWidth;
    _heightFactor = deviceHeight / designHeight;
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
