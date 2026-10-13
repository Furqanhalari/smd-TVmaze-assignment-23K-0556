part of 'shows_bloc.dart';

sealed class ShowsEvent extends Equatable {
  const ShowsEvent();

  @override
  List<Object?> get props => [];
}

/// First load of the Home screen (also used by the Retry button).
final class ShowsFetched extends ShowsEvent {
  const ShowsFetched();
}

/// The user scrolled near the bottom, so load the next page.
final class ShowsLoadMore extends ShowsEvent {
  const ShowsLoadMore();
}

/// Pull-to-refresh: reload page 0 without showing the full-screen loader.
final class ShowsRefreshed extends ShowsEvent {
  const ShowsRefreshed();
}
