part of 'episodes_bloc.dart';

enum EpisodesStatus { initial, loading, success, empty, failure }

class EpisodesState extends Equatable {
  final EpisodesStatus status;
  final Map<int, List<Episode>> seasons; // season number → its episodes
  final int? selectedSeason;
  final String? errorMessage;

  const EpisodesState({
    this.status = EpisodesStatus.initial,
    this.seasons = const {},
    this.selectedSeason,
    this.errorMessage,
  });

  /// Episodes of the season chosen in the dropdown.
  List<Episode> get selectedEpisodes => seasons[selectedSeason] ?? const [];

  EpisodesState copyWith({int? selectedSeason}) {
    return EpisodesState(
      status: status,
      seasons: seasons,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, seasons, selectedSeason, errorMessage];
}
