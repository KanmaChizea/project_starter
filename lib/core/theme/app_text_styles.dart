import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static final body = GoogleFonts.inter(fontSize: 16);
}

extension TextStyleWeight on TextStyle {
  TextStyle weight(FontWeight weight) =>
      GoogleFonts.inter(fontWeight: weight, textStyle: this);
}
