part of 'watchlist_bloc.dart';

enum WatchlistStatus { initial, loading, success, empty, failure }

class WatchlistState extends Equatable {
  final WatchlistStatus status;
  final List<Show> shows;
  final String? errorMessage;

  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.shows = const [],
    this.errorMessage,
  });

  /// Used by the details page to pick "Add" or "Remove".
  bool contains(int showId) => shows.any((s) => s.id == showId);

  @override
  List<Object?> get props => [status, shows, errorMessage];
}
