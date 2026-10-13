import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/errors/exceptions.dart';
import '../../../data/models/show.dart';
import '../../../data/repositories/show_repository.dart';

part 'shows_event.dart';
part 'shows_state.dart';

class ShowsBloc extends Bloc<ShowsEvent, ShowsState> {
  static const int featuredCount = 10;

  final ShowRepository _repository;

  ShowsBloc(this._repository) : super(const ShowsState()) {
    on<ShowsFetched>(_onFetched);
    on<ShowsRefreshed>(_onRefreshed);
    // exhaustMap ignores new LoadMore events while one page is still loading,
    // so fast scrolling can't request the same page twice.
    on<ShowsLoadMore>(
      _onLoadMore,
      transformer: (events, mapper) => events.exhaustMap(mapper),
    );
  }

  Future<void> _onFetched(ShowsFetched event, Emitter<ShowsState> emit) async {
    emit(state.copyWith(status: ShowsStatus.loading));
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
      ShowsRefreshed event, Emitter<ShowsState> emit) async {
    // No loading state here: the RefreshIndicator spinner is enough.
    await _loadFirstPage(emit);
  }

  Future<void> _onLoadMore(ShowsLoadMore event, Emitter<ShowsState> emit) async {
    if (state.status != ShowsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final newShows = await _repository.fetchShows(state.nextPage);
      if (newShows.isEmpty) {
        // The API answered 404: there are no more pages.
        emit(state.copyWith(isLoadingMore: false, hasReachedMax: true));
      } else {
        emit(state.copyWith(
          isLoadingMore: false,
          shows: [...state.shows, ...newShows],
          nextPage: state.nextPage + 1,
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, loadMoreError: _message(e)));
    }
  }

  /// Loads page 0 and builds the featured row from it.
  Future<void> _loadFirstPage(Emitter<ShowsState> emit) async {
    try {
      final shows = await _repository.fetchShows(0);
      if (shows.isEmpty) {
        emit(const ShowsState(status: ShowsStatus.empty, hasReachedMax: true));
        return;
      }
      emit(ShowsState(
        status: ShowsStatus.success,
        shows: shows,
        featured: _topRated(shows),
        nextPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ShowsStatus.failure,
        errorMessage: _message(e),
      ));
    }
  }

  /// Highest rated shows first; shows without a rating are left out.
  static List<Show> _topRated(List<Show> shows) {
    final rated = shows.where((s) => s.rating != null).toList()
      ..sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated.take(featuredCount).toList();
  }

  static String _message(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';
}
