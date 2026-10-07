extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ListNullExtension on List? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
