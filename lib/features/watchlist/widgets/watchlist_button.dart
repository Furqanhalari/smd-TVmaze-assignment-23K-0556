import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/show.dart';
import '../bloc/watchlist_bloc.dart';

/// "Add to Watchlist" / "Remove from Watchlist" button on the details page.
/// It reads the global WatchlistBloc, so the label is always up to date.
class WatchlistButton extends StatelessWidget {
  final Show show;

  const WatchlistButton({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    // Rebuild only when this show's saved / not saved status changes.
    final isSaved = context.select<WatchlistBloc, bool>(
      (bloc) => bloc.state.contains(show.id),
    );

    final button = isSaved
        ? OutlinedButton.icon(
            onPressed: () => _toggle(context, isSaved),
            icon: const Icon(Icons.favorite),
            label: const Text('Remove from Watchlist'),
          )
        : FilledButton.icon(
            onPressed: () => _toggle(context, isSaved),
            icon: const Icon(Icons.favorite_border),
            label: const Text('Add to Watchlist'),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(width: double.infinity, child: button),
    );
  }

  void _toggle(BuildContext context, bool isSaved) {
    context.read<WatchlistBloc>().add(WatchlistToggled(show));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(isSaved
            ? '${show.name} removed from your watchlist'
            : '${show.name} added to your watchlist'),
        duration: const Duration(seconds: 2),
      ));
  }
}
