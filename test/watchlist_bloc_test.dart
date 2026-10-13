import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/watchlist_repository.dart';
import 'package:tvmaze_app/features/watchlist/bloc/watchlist_bloc.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository repository;

  const dome = Show(id: 1, name: 'Under the Dome');
  const girls = Show(id: 5, name: 'Girls');

  setUpAll(() => registerFallbackValue(<Show>[]));

  setUp(() {
    repository = MockWatchlistRepository();
    // Saving succeeds unless a test says otherwise.
    when(() => repository.saveWatchlist(any())).thenAnswer((_) async {});
  });

  group('WatchlistLoaded', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'emits loading then success with the saved shows',
      setUp: () => when(() => repository.loadWatchlist())
          .thenAnswer((_) async => [dome]),
      build: () => WatchlistBloc(repository),
      act: (bloc) => bloc.add(const WatchlistLoaded()),
      expect: () => const [
        WatchlistState(status: WatchlistStatus.loading),
        WatchlistState(status: WatchlistStatus.success, shows: [dome]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits empty when nothing is saved',
      setUp: () =>
          when(() => repository.loadWatchlist()).thenAnswer((_) async => []),
      build: () => WatchlistBloc(repository),
      act: (bloc) => bloc.add(const WatchlistLoaded()),
      expect: () => const [
        WatchlistState(status: WatchlistStatus.loading),
        WatchlistState(status: WatchlistStatus.empty),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits failure when storage cannot be read',
      setUp: () =>
          when(() => repository.loadWatchlist()).thenThrow(Exception('disk')),
      build: () => WatchlistBloc(repository),
      act: (bloc) => bloc.add(const WatchlistLoaded()),
      expect: () => const [
        WatchlistState(status: WatchlistStatus.loading),
        WatchlistState(
          status: WatchlistStatus.failure,
          errorMessage: 'Could not load your watchlist.',
        ),
      ],
    );
  });

  group('WatchlistToggled', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'adds a missing show and saves the new list',
      build: () => WatchlistBloc(repository),
      seed: () =>
          const WatchlistState(status: WatchlistStatus.success, shows: [dome]),
      act: (bloc) => bloc.add(const WatchlistToggled(girls)),
      expect: () => const [
        WatchlistState(status: WatchlistStatus.success, shows: [dome, girls]),
      ],
      verify: (_) =>
          verify(() => repository.saveWatchlist([dome, girls])).called(1),
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'removes a show that is already saved',
      build: () => WatchlistBloc(repository),
      seed: () => const WatchlistState(
          status: WatchlistStatus.success, shows: [dome, girls]),
      act: (bloc) => bloc.add(const WatchlistToggled(dome)),
      expect: () => const [
        WatchlistState(status: WatchlistStatus.success, shows: [girls]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'two quick toggles are handled in order (sequential)',
      build: () => WatchlistBloc(repository),
      seed: () => const WatchlistState(status: WatchlistStatus.empty),
      act: (bloc) => bloc
        ..add(const WatchlistToggled(dome))
        ..add(const WatchlistToggled(girls)),
      expect: () => const [
        WatchlistState(status: WatchlistStatus.success, shows: [dome]),
        WatchlistState(status: WatchlistStatus.success, shows: [dome, girls]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'keeps the old list and sets errorMessage when saving fails',
      setUp: () => when(() => repository.saveWatchlist(any()))
          .thenThrow(Exception('disk full')),
      build: () => WatchlistBloc(repository),
      seed: () =>
          const WatchlistState(status: WatchlistStatus.success, shows: [dome]),
      act: (bloc) => bloc.add(const WatchlistToggled(girls)),
      expect: () => const [
        WatchlistState(
          status: WatchlistStatus.success,
          shows: [dome],
          errorMessage: 'Could not save your watchlist.',
        ),
      ],
    );
  });

  blocTest<WatchlistBloc, WatchlistState>(
    'WatchlistRemoved removes the show by id; last one gives empty',
    build: () => WatchlistBloc(repository),
    seed: () =>
        const WatchlistState(status: WatchlistStatus.success, shows: [dome]),
    act: (bloc) => bloc.add(const WatchlistRemoved(1)),
    expect: () => const [WatchlistState(status: WatchlistStatus.empty)],
  );

  blocTest<WatchlistBloc, WatchlistState>(
    'WatchlistCleared saves an empty list and emits empty',
    build: () => WatchlistBloc(repository),
    seed: () => const WatchlistState(
        status: WatchlistStatus.success, shows: [dome, girls]),
    act: (bloc) => bloc.add(const WatchlistCleared()),
    expect: () => const [WatchlistState(status: WatchlistStatus.empty)],
    verify: (_) => verify(() => repository.saveWatchlist([])).called(1),
  );

  test('contains() reports whether a show is saved', () {
    const state =
        WatchlistState(status: WatchlistStatus.success, shows: [dome]);
    expect(state.contains(1), isTrue);
    expect(state.contains(5), isFalse);
  });
}
