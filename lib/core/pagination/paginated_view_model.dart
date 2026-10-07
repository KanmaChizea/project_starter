import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_starter/core/utils/result.dart';

import 'paginated_data.dart';
import 'paginated_state.dart';

/// Base view model for paginated lists. Subclasses implement [fetchPage].
/// A view-scoped instance starts loading with `..loadNextPage()` when it's
/// created; a shared one with [loadIfEmpty] from each view that shows it.
abstract class PaginatedViewModel<T> extends Cubit<PaginatedState<T>> {
  PaginatedViewModel({this.firstPage = 1})
    : super(PaginatedState(nextPage: firstPage));

  final int firstPage;

  // Incremented by refresh and reset so results from requests they superseded
  // are dropped.
  int _generation = 0;

  Future<Result<PaginatedData<T>>> fetchPage(int page);

  /// Loads the first page unless items are already loaded. Safe to call each
  /// time a view opens.
  Future<void> loadIfEmpty() async {
    if (state.items.isEmpty) await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    final generation = _generation;
    emit(state.copyWith(isLoading: true, errorMessage: () => null));
    final result = await fetchPage(state.nextPage);
    if (isClosed || generation != _generation) return;

    result.fold(
      (error) => emit(
        state.copyWith(isLoading: false, errorMessage: () => error.message),
      ),
      (data) => emit(
        state.copyWith(
          items: [...state.items, ...data.items],
          nextPage: state.nextPage + 1,
          hasMore: data.hasMore,
          isLoading: false,
        ),
      ),
    );
  }

  /// Reloads from [firstPage]. Current items stay visible until it succeeds.
  Future<void> refresh() async {
    final generation = ++_generation;
    emit(state.copyWith(isLoading: true, errorMessage: () => null));
    final result = await fetchPage(firstPage);
    if (isClosed || generation != _generation) return;

    result.fold(
      (error) => emit(
        state.copyWith(isLoading: false, errorMessage: () => error.message),
      ),
      (data) => emit(
        PaginatedState(
          items: data.items,
          nextPage: firstPage + 1,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  void reset() {
    _generation++;
    emit(PaginatedState(nextPage: firstPage));
  }
}
