import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../../../data/models/episode.dart';
import '../../../data/repositories/show_repository.dart';

part 'episodes_event.dart';
part 'episodes_state.dart';

/// Loads `/shows/:id/episodes` the first time the Episodes tab is opened
/// and groups the flat list by season number.
class EpisodesBloc extends Bloc<EpisodesEvent, EpisodesState> {
  final ShowRepository _repository;

  EpisodesBloc(this._repository) : super(const EpisodesState()) {
    on<EpisodesFetched>(_onFetched);
    on<EpisodesSeasonSelected>(_onSeasonSelected);
  }

  Future<void> _onFetched(
      EpisodesFetched event, Emitter<EpisodesState> emit) async {
    emit(const EpisodesState(status: EpisodesStatus.loading));
    try {
      final episodes = await _repository.fetchEpisodes(event.showId);
      if (episodes.isEmpty) {
        emit(const EpisodesState(status: EpisodesStatus.empty));
        return;
      }
      final seasons = groupBySeason(episodes);
      emit(EpisodesState(
        status: EpisodesStatus.success,
        seasons: seasons,
        selectedSeason: seasons.keys.first,
      ));
    } catch (e) {
      emit(EpisodesState(
        status: EpisodesStatus.failure,
        errorMessage: e is ApiException
            ? e.message
            : 'Something went wrong. Please try again.',
      ));
    }
  }

  void _onSeasonSelected(
      EpisodesSeasonSelected event, Emitter<EpisodesState> emit) {
    emit(state.copyWith(selectedSeason: event.season));
  }

  /// `[S1E1, S1E2, S2E1]` → `{1: [S1E1, S1E2], 2: [S2E1]}`, seasons in order.
  static Map<int, List<Episode>> groupBySeason(List<Episode> episodes) {
    final grouped = <int, List<Episode>>{};
    for (final episode in episodes) {
      grouped.putIfAbsent(episode.season, () => []).add(episode);
    }
    final seasonNumbers = grouped.keys.toList()..sort();
    return {for (final s in seasonNumbers) s: grouped[s]!};
  }
}
