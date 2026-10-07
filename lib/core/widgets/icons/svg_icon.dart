import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_starter/core/theme/app_colors.dart';
import 'package:project_starter/core/utils/scale_util.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.asset, {
    super.key,
    this.size,
    this.color,
    this.keepOriginalColors = false,
  });

  final String asset;
  final double? size;
  final Color? color;
  final bool keepOriginalColors;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size?.r,
      height: size?.r,
      colorFilter: keepOriginalColors
          ? null
          : ColorFilter.mode(color ?? context.colors.text, BlendMode.srcIn),
    );
  }
}
