part of 'episodes_bloc.dart';

sealed class EpisodesEvent extends Equatable {
  const EpisodesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all episodes of one show (sent when the tab is first built and by Retry).
final class EpisodesFetched extends EpisodesEvent {
  final int showId;

  const EpisodesFetched(this.showId);

  @override
  List<Object?> get props => [showId];
}

/// The user picked another season in the dropdown.
final class EpisodesSeasonSelected extends EpisodesEvent {
  final int season;

  const EpisodesSeasonSelected(this.season);

  @override
  List<Object?> get props => [season];
}
