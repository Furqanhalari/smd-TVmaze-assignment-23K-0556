import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/core/errors/exceptions.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';
import 'package:tvmaze_app/features/home/bloc/shows_bloc.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository repository;

  const low = Show(id: 1, name: 'Low', rating: 5.0);
  const high = Show(id: 2, name: 'High', rating: 9.0);
  const unrated = Show(id: 3, name: 'Unrated');
  const page0 = [low, high, unrated];
  const page1 = [Show(id: 4, name: 'Next')];

  // A state that already has page 0 loaded.
  const loaded = ShowsState(
    status: ShowsStatus.success,
    shows: page0,
    featured: [high, low],
    nextPage: 1,
  );

  setUp(() => repository = MockShowRepository());

  group('ShowsFetched', () {
    blocTest<ShowsBloc, ShowsState>(
      'emits loading then success, with Top Rated sorted by rating',
      setUp: () =>
          when(() => repository.fetchShows(0)).thenAnswer((_) async => page0),
      build: () => ShowsBloc(repository),
      act: (bloc) => bloc.add(const ShowsFetched()),
      expect: () => const [
        ShowsState(status: ShowsStatus.loading),
        loaded,
      ],
    );

    blocTest<ShowsBloc, ShowsState>(
      'emits empty when page 0 has no shows',
      setUp: () =>
          when(() => repository.fetchShows(0)).thenAnswer((_) async => []),
      build: () => ShowsBloc(repository),
      act: (bloc) => bloc.add(const ShowsFetched()),
      expect: () => const [
        ShowsState(status: ShowsStatus.loading),
        ShowsState(status: ShowsStatus.empty, hasReachedMax: true),
      ],
    );

    blocTest<ShowsBloc, ShowsState>(
      'emits failure with the exception message when offline',
      setUp: () => when(() => repository.fetchShows(0))
          .thenThrow(const NetworkException('No internet')),
      build: () => ShowsBloc(repository),
      act: (bloc) => bloc.add(const ShowsFetched()),
      expect: () => const [
        ShowsState(status: ShowsStatus.loading),
        ShowsState(status: ShowsStatus.failure, errorMessage: 'No internet'),
      ],
    );
  });

  group('ShowsLoadMore', () {
    blocTest<ShowsBloc, ShowsState>(
      'appends the next page and increments nextPage',
      setUp: () =>
          when(() => repository.fetchShows(1)).thenAnswer((_) async => page1),
      build: () => ShowsBloc(repository),
      seed: () => loaded,
      act: (bloc) => bloc.add(const ShowsLoadMore()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        loaded.copyWith(shows: [...page0, ...page1], nextPage: 2),
      ],
    );

    blocTest<ShowsBloc, ShowsState>(
      'sets hasReachedMax when the next page is empty (404)',
      setUp: () =>
          when(() => repository.fetchShows(1)).thenAnswer((_) async => []),
      build: () => ShowsBloc(repository),
      seed: () => loaded,
      act: (bloc) => bloc.add(const ShowsLoadMore()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        loaded.copyWith(hasReachedMax: true),
      ],
    );

    blocTest<ShowsBloc, ShowsState>(
      'keeps the list and sets loadMoreError when a page fails',
      setUp: () => when(() => repository.fetchShows(1))
          .thenThrow(const NetworkException('Timed out')),
      build: () => ShowsBloc(repository),
      seed: () => loaded,
      act: (bloc) => bloc.add(const ShowsLoadMore()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        loaded.copyWith(loadMoreError: 'Timed out'),
      ],
    );

    blocTest<ShowsBloc, ShowsState>(
      'does nothing once hasReachedMax is true',
      build: () => ShowsBloc(repository),
      seed: () => loaded.copyWith(hasReachedMax: true),
      act: (bloc) => bloc.add(const ShowsLoadMore()),
      expect: () => const <ShowsState>[],
      verify: (_) => verifyNever(() => repository.fetchShows(any())),
    );
  });

  blocTest<ShowsBloc, ShowsState>(
    'ShowsRefreshed reloads page 0 without a loading state',
    setUp: () =>
        when(() => repository.fetchShows(0)).thenAnswer((_) async => page0),
    build: () => ShowsBloc(repository),
    seed: () => loaded.copyWith(shows: [...page0, ...page1], nextPage: 2),
    act: (bloc) => bloc.add(const ShowsRefreshed()),
    expect: () => const [loaded],
  );
}
