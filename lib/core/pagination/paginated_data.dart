class PaginatedData<T> {
  const PaginatedData({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}
