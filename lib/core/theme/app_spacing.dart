import 'package:flutter/widgets.dart';
import 'package:project_starter/core/utils/scale_util.dart';

abstract final class AppSpacing {
  static SizedBox get v4 => SizedBox(height: 4.h);
  static SizedBox get v8 => SizedBox(height: 8.h);
  static SizedBox get v12 => SizedBox(height: 12.h);
  static SizedBox get v14 => SizedBox(height: 14.h);
  static SizedBox get v16 => SizedBox(height: 16.h);
  static SizedBox get v20 => SizedBox(height: 20.h);
  static SizedBox get v24 => SizedBox(height: 24.h);
  static SizedBox get v28 => SizedBox(height: 28.h);
  static SizedBox get v32 => SizedBox(height: 32.h);
  static SizedBox get v38 => SizedBox(height: 38.h);
  static SizedBox get v40 => SizedBox(height: 40.h);
  static SizedBox get v48 => SizedBox(height: 48.h);

  static SizedBox get h4 => SizedBox(width: 4.w);
  static SizedBox get h8 => SizedBox(width: 8.w);
  static SizedBox get h12 => SizedBox(width: 12.w);
  static SizedBox get h16 => SizedBox(width: 16.w);
  static SizedBox get h20 => SizedBox(width: 20.w);
  static SizedBox get h28 => SizedBox(width: 28.w);
  static SizedBox get h32 => SizedBox(width: 32.w);

  static EdgeInsets get padding4 => EdgeInsets.all(4.r);
  static EdgeInsets get padding8 => EdgeInsets.all(8.r);
  static EdgeInsets get padding10 => EdgeInsets.all(10.r);
  static EdgeInsets get padding12 => EdgeInsets.all(12.r);
  static EdgeInsets get padding16 => EdgeInsets.all(16.r);

  static EdgeInsets symmetricPadding({double? horizontal, double? vertical}) =>
      EdgeInsets.symmetric(
        horizontal: (horizontal ?? 0).w,
        vertical: (vertical ?? 0).h,
      );

  static EdgeInsets fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) => EdgeInsets.fromLTRB(left.w, top.h, right.w, bottom.h);

  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => EdgeInsets.only(
    left: (left ?? 0).w,
    top: (top ?? 0).h,
    right: (right ?? 0).w,
    bottom: (bottom ?? 0).h,
  );

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 20.w);
}
