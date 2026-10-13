import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/repositories/show_repository.dart';

void main() {
  runApp(
    // Repositories are created once here and read by blocs via context.
    RepositoryProvider(
      create: (_) => ShowRepository(),
      child: const TvMazeApp(),
    ),
  );
}
