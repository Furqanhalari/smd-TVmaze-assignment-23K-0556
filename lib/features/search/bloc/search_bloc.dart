import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/errors/exceptions.dart';
import '../../../data/models/show.dart';
import '../../../data/repositories/show_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

const _debounceDuration = Duration(milliseconds: 500);

/// Waits until the user stops typing for 500 ms, then handles only the
/// latest query. switchMap cancels a search that is still running when a
/// newer query arrives, so old results can never replace new ones.
EventTransformer<E> debounceSwitch<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ShowRepository _repository;

  SearchBloc(this._repository) : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceSwitch(_debounceDuration),
    );
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();

    // An empty search box goes back to the start screen.
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(SearchState(status: SearchStatus.loading, query: query));
    try {
      final results = await _repository.searchShows(query);
      emit(SearchState(
        status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
        query: query,
        results: results,
      ));
    } catch (e) {
      emit(SearchState(
        status: SearchStatus.failure,
        query: query,
        errorMessage: _message(e),
      ));
    }
  }

  static String _message(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';
}
