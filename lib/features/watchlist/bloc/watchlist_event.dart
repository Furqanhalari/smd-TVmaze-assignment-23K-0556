part of 'watchlist_bloc.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Reads the saved watchlist from the device (on app start and on Retry).
final class WatchlistLoaded extends WatchlistEvent {
  const WatchlistLoaded();
}

/// The Add/Remove button on the details page.
/// Adds the show if it is missing, otherwise removes it.
final class WatchlistToggled extends WatchlistEvent {
  final Show show;

  const WatchlistToggled(this.show);

  @override
  List<Object?> get props => [show];
}

/// The heart button on a Watchlist tile.
final class WatchlistRemoved extends WatchlistEvent {
  final int showId;

  const WatchlistRemoved(this.showId);

  @override
  List<Object?> get props => [showId];
}

/// The "Clear all" button.
final class WatchlistCleared extends WatchlistEvent {
  const WatchlistCleared();
}
