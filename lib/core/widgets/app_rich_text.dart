import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project_starter/core/theme/app_colors.dart';
import 'package:project_starter/core/theme/app_text_styles.dart';

class AppTextSpan {
  const AppTextSpan(this.data, {this.style, this.color, this.onTap});

  final String data;
  final TextStyle? style;
  final Color? color;
  final VoidCallback? onTap;
}

class AppRichText extends StatefulWidget {
  const AppRichText(
    this.spans, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final List<AppTextSpan> spans;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  State<AppRichText> createState() => _AppRichTextState();
}

class _AppRichTextState extends State<AppRichText> {
  // TextSpan doesn't own its recognizer, so they're kept here to be disposed.
  List<TapGestureRecognizer?> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _createRecognizers();
  }

  @override
  void didUpdateWidget(AppRichText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeRecognizers();
    _createRecognizers();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _createRecognizers() {
    _recognizers = [
      for (final span in widget.spans)
        span.onTap == null
            ? null
            : (TapGestureRecognizer()..onTap = span.onTap),
    ];
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? AppTextStyles.body;
    final resolvedColor = widget.color ?? context.colors.text;

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < widget.spans.length; i++)
            TextSpan(
              text: widget.spans[i].data,
              style: (widget.spans[i].style ?? const TextStyle()).copyWith(
                color: widget.spans[i].color,
              ),
              recognizer: _recognizers[i],
            ),
        ],
      ),
      style: baseStyle.copyWith(color: resolvedColor),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow:
          widget.overflow ??
          (widget.maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}
