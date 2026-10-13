import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/show.dart';
import '../../../data/repositories/watchlist_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

/// Global bloc (provided above MaterialApp), so the details page and the
/// Watchlist tab always see the same list.
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository _repository;

  WatchlistBloc(this._repository) : super(const WatchlistState()) {
    on<WatchlistLoaded>(_onLoaded, transformer: _sequential());
    on<WatchlistToggled>(_onToggled, transformer: _sequential());
    on<WatchlistRemoved>(_onRemoved, transformer: _sequential());
    on<WatchlistCleared>(_onCleared, transformer: _sequential());
  }

  /// Handles events one at a time, so two quick taps can't
  /// save an outdated list over a newer one.
  static EventTransformer<E> _sequential<E>() =>
      (events, mapper) => events.asyncExpand(mapper);

  Future<void> _onLoaded(
      WatchlistLoaded event, Emitter<WatchlistState> emit) async {
    emit(const WatchlistState(status: WatchlistStatus.loading));
    try {
      final shows = await _repository.loadWatchlist();
      emit(_stateFor(shows));
    } catch (_) {
      emit(const WatchlistState(
        status: WatchlistStatus.failure,
        errorMessage: 'Could not load your watchlist.',
      ));
    }
  }

  Future<void> _onToggled(
      WatchlistToggled event, Emitter<WatchlistState> emit) async {
    final shows = state.contains(event.show.id)
        ? state.shows.where((s) => s.id != event.show.id).toList()
        : [...state.shows, event.show];
    await _saveAndEmit(shows, emit);
  }

  Future<void> _onRemoved(
      WatchlistRemoved event, Emitter<WatchlistState> emit) async {
    final shows = state.shows.where((s) => s.id != event.showId).toList();
    await _saveAndEmit(shows, emit);
  }

  Future<void> _onCleared(
      WatchlistCleared event, Emitter<WatchlistState> emit) async {
    await _saveAndEmit([], emit);
  }

  /// Saves first, then shows the new list. If saving fails the old
  /// list is kept and only an error message is added.
  Future<void> _saveAndEmit(
      List<Show> shows, Emitter<WatchlistState> emit) async {
    try {
      await _repository.saveWatchlist(shows);
      emit(_stateFor(shows));
    } catch (_) {
      emit(WatchlistState(
        status: state.status,
        shows: state.shows,
        errorMessage: 'Could not save your watchlist.',
      ));
    }
  }

  static WatchlistState _stateFor(List<Show> shows) => WatchlistState(
        status:
            shows.isEmpty ? WatchlistStatus.empty : WatchlistStatus.success,
        shows: shows,
      );
}
