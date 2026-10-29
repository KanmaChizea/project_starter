/// Widths that keep layouts readable on tablets. Phones are narrower than
/// all of these, so they're unaffected.
abstract final class AppLayout {
  /// Screens narrower than this are phones.
  static const double tabletBreakpoint = 600;

  /// Forms, lists and text-heavy screens.
  static const double maxContentWidth = 600;

  /// Product and category grids, which add columns instead of stretching.
  static const double maxCatalogWidth = 1100;

  static const double maxNavBarWidth = 480;

  /// The sign-in and sign-up forms on tablets.
  static const double maxAuthFormWidth = 480;
}
