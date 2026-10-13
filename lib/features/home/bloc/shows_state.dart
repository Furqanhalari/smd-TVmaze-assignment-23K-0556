part of 'shows_bloc.dart';

enum ShowsStatus { initial, loading, success, empty, failure }

class ShowsState extends Equatable {
  final ShowsStatus status;
  final List<Show> shows;
  final List<Show> featured; // "Top Rated" row
  final int nextPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage; // full-screen error (first load failed)
  final String? loadMoreError; // a later page failed, the list stays visible

  const ShowsState({
    this.status = ShowsStatus.initial,
    this.shows = const [],
    this.featured = const [],
    this.nextPage = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
  });

  /// Both error messages are cleared unless they are passed in again.
  ShowsState copyWith({
    ShowsStatus? status,
    List<Show>? shows,
    List<Show>? featured,
    int? nextPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    String? loadMoreError,
  }) {
    return ShowsState(
      status: status ?? this.status,
      shows: shows ?? this.shows,
      featured: featured ?? this.featured,
      nextPage: nextPage ?? this.nextPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        shows,
        featured,
        nextPage,
        hasReachedMax,
        isLoadingMore,
        errorMessage,
        loadMoreError,
      ];
}
