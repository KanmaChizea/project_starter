import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:project_starter/core/constants/app_layout.dart';

/// Centres [child] and stops it growing past [maxWidth], so screens don't
/// stretch edge to edge on tablets. Narrower screens get no extra padding,
/// so phones are unaffected.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final inset = width.isFinite ? max(0.0, (width - maxWidth) / 2) : 0.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: child,
        );
      },
    );
  }
}
