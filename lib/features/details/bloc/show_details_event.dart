part of 'show_details_bloc.dart';

sealed class ShowDetailsEvent extends Equatable {
  const ShowDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Load one show by id (sent when the screen opens and by Retry).
final class ShowDetailsFetched extends ShowDetailsEvent {
  final int showId;

  const ShowDetailsFetched(this.showId);

  @override
  List<Object?> get props => [showId];
}
