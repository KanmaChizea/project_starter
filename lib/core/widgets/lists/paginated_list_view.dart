import 'package:flutter/material.dart';
import 'package:project_starter/core/pagination/paginated_state.dart';
import 'package:project_starter/core/theme/app_colors.dart';
import 'package:project_starter/core/widgets/text/app_text.dart';

class PaginatedListView<T> extends StatelessWidget {
  const PaginatedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onLoadMore,
    this.onRefresh,
    this.separatorBuilder,
    this.emptyBuilder,
    this.padding,
  });

  final PaginatedState<T> state;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function()? onRefresh;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? emptyBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: PaginatedSliverList<T>(
            state: state,
            itemBuilder: itemBuilder,
            onLoadMore: onLoadMore,
            separatorBuilder: separatorBuilder,
            emptyBuilder: emptyBuilder,
          ),
        ),
      ],
    );

    final onRefresh = this.onRefresh;
    if (onRefresh == null) return scrollView;
    return RefreshIndicator(onRefresh: onRefresh, child: scrollView);
  }
}

/// For when a parent [CustomScrollView] owns the scrolling, e.g. a list below
/// a header. Wrap the parent in a RefreshIndicator for pull to refresh.
class PaginatedSliverList<T> extends StatelessWidget {
  const PaginatedSliverList({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onLoadMore,
    this.separatorBuilder,
    this.emptyBuilder,
  });

  final PaginatedState<T> state;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      final Widget child;
      if (state.errorMessage != null) {
        child = Center(
          child: _ErrorRetry(message: state.errorMessage!, onRetry: onLoadMore),
        );
      } else if (state.hasMore || state.isLoading) {
        child = const Center(child: CircularProgressIndicator());
      } else {
        child = emptyBuilder?.call(context) ?? const SizedBox.shrink();
      }
      return SliverFillRemaining(hasScrollBody: false, child: child);
    }

    final showFooter = state.hasMore || state.errorMessage != null;
    return SliverList.separated(
      itemCount: state.items.length + (showFooter ? 1 : 0),
      separatorBuilder: separatorBuilder ?? (_, _) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (index < state.items.length) {
          return itemBuilder(context, state.items[index]);
        }
        return _LoadMoreFooter(state: state, onLoadMore: onLoadMore);
      },
    );
  }
}

// Lazy lists only build the footer once the end of the list is within the
// scroll view's cache extent, so being built is the signal to load the next
// page. This works whichever widget owns the scrolling, and keeps loading
// while a page doesn't fill the screen.
class _LoadMoreFooter extends StatefulWidget {
  const _LoadMoreFooter({required this.state, required this.onLoadMore});

  final PaginatedState<Object?> state;
  final VoidCallback onLoadMore;

  @override
  State<_LoadMoreFooter> createState() => _LoadMoreFooterState();
}

class _LoadMoreFooterState extends State<_LoadMoreFooter> {
  @override
  void initState() {
    super.initState();
    _scheduleLoadMore();
  }

  @override
  void didUpdateWidget(_LoadMoreFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleLoadMore();
  }

  void _scheduleLoadMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = widget.state;
      if (!mounted ||
          state.isLoading ||
          !state.hasMore ||
          state.errorMessage != null) {
        return;
      }
      widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = widget.state.errorMessage;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: errorMessage != null
            ? _ErrorRetry(message: errorMessage, onRetry: widget.onLoadMore)
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(message, textAlign: TextAlign.center),
        TextButton(
          onPressed: onRetry,
          child: AppText('Retry', color: context.colors.primary),
        ),
      ],
    );
  }
}
