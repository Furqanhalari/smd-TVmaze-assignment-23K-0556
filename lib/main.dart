import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/repositories/show_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';

void main() {
  runApp(
    // Repositories are created once here and read by blocs via context.
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ShowRepository()),
        RepositoryProvider(create: (_) => WatchlistRepository()),
      ],
      // The WatchlistBloc sits above MaterialApp so every screen,
      // including pushed routes like the details page, can read it.
      child: BlocProvider(
        create: (context) =>
            WatchlistBloc(context.read<WatchlistRepository>())
              ..add(const WatchlistLoaded()),
        child: const TvMazeApp(),
      ),
    ),
  );
}
