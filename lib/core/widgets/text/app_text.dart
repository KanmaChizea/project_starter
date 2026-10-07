import 'package:flutter/material.dart';
import 'package:project_starter/core/theme/app_colors.dart';
import 'package:project_starter/core/theme/app_text_styles.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? AppTextStyles.body;
    final resolvedColor = color ?? context.colors.text;

    return Text(
      data,
      style: baseStyle.copyWith(color: resolvedColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}
