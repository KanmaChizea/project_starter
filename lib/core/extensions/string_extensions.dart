extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;

    return split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String get toSentenceCase {
    if (isEmpty) return this;

    final spaced = replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    ).toLowerCase();

    return spaced.replaceAllMapped(
      RegExp(r'(^\s*|[.!?]\s+)([a-z])'),
      (m) => '${m[1]}${m[2]!.toUpperCase()}',
    );
  }

  /// [plural] is the full plural word, for words that don't just add an "s"
  /// (e.g. `'person'.pluralSafe(2, plural: 'people')`).
  String pluralSafe(int count, {String? plural}) {
    return count == 1 ? this : plural ?? '${this}s';
  }

  /// e.g. `'order'.plural(1200)` → `1,200 orders`.
  String plural(int count, {String? plural}) {
    return '${_formatNumber(count)} ${pluralSafe(count, plural: plural)}';
  }
}

extension StringNullExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

String _formatNumber(int number) => number.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);
