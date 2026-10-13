import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/core/errors/exceptions.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';
import 'package:tvmaze_app/features/search/bloc/search_bloc.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository repository;

  const girls = Show(id: 5, name: 'Girls');
  // Longer than the 500 ms debounce, so the search has time to run.
  const debounceWait = Duration(milliseconds: 600);

  setUp(() => repository = MockShowRepository());

  blocTest<SearchBloc, SearchState>(
    'emits loading then success after the debounce',
    setUp: () => when(() => repository.searchShows('girls'))
        .thenAnswer((_) async => [girls]),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc.add(const SearchQueryChanged('girls')),
    wait: debounceWait,
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'girls'),
      SearchState(
          status: SearchStatus.success, query: 'girls', results: [girls]),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'fast typing sends only one request, for the last query',
    setUp: () => when(() => repository.searchShows(any()))
        .thenAnswer((_) async => [girls]),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc
      ..add(const SearchQueryChanged('g'))
      ..add(const SearchQueryChanged('gi'))
      ..add(const SearchQueryChanged('girls')),
    wait: debounceWait,
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'girls'),
      SearchState(
          status: SearchStatus.success, query: 'girls', results: [girls]),
    ],
    verify: (_) {
      verify(() => repository.searchShows('girls')).called(1);
      verifyNever(() => repository.searchShows('g'));
      verifyNever(() => repository.searchShows('gi'));
    },
  );

  blocTest<SearchBloc, SearchState>(
    'emits empty when nothing matches',
    setUp: () =>
        when(() => repository.searchShows('zzz')).thenAnswer((_) async => []),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc.add(const SearchQueryChanged('zzz')),
    wait: debounceWait,
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'zzz'),
      SearchState(status: SearchStatus.empty, query: 'zzz'),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits failure with the exception message on a network error',
    setUp: () => when(() => repository.searchShows('dark'))
        .thenThrow(const NetworkException('No internet')),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc.add(const SearchQueryChanged('dark')),
    wait: debounceWait,
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'dark'),
      SearchState(
          status: SearchStatus.failure,
          query: 'dark',
          errorMessage: 'No internet'),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'a blank query goes back to initial without calling the API',
    build: () => SearchBloc(repository),
    seed: () => const SearchState(
        status: SearchStatus.success, query: 'girls', results: [girls]),
    act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
    wait: debounceWait,
    expect: () => const [SearchState()],
    verify: (_) => verifyNever(() => repository.searchShows(any())),
  );
}
