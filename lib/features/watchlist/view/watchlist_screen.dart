import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/show_list_tile.dart';
import '../../details/view/show_details_screen.dart';
import '../bloc/watchlist_bloc.dart';

/// Watchlist tab. Uses the global WatchlistBloc from main.dart,
/// so it has no BlocProvider of its own.
class WatchlistScreen extends StatelessWidget {
  /// Switches the bottom nav to Home (the "Explore Shows" button).
  final VoidCallback? onExplore;

  const WatchlistScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.shows.isEmpty
                ? 'Watchlist'
                : 'Watchlist (${state.shows.length})'),
            actions: [
              if (state.shows.isNotEmpty)
                IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _confirmClear(context),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WatchlistState state) {
    switch (state.status) {
      case WatchlistStatus.initial:
      case WatchlistStatus.loading:
        return const LoadingView();
      case WatchlistStatus.failure:
        return ErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () =>
              context.read<WatchlistBloc>().add(const WatchlistLoaded()),
        );
      case WatchlistStatus.empty:
        return EmptyView(
          icon: Icons.favorite_border,
          message: 'Your watchlist is empty.\n'
              'Add shows from their details page.',
          action: FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Explore Shows'),
          ),
        );
      case WatchlistStatus.success:
        return ListView.builder(
          itemCount: state.shows.length,
          itemBuilder: (context, index) {
            final show = state.shows[index];
            return ShowListTile(
              show: show,
              onTap: () =>
                  Navigator.of(context).push(ShowDetailsScreen.route(show.id)),
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.favorite, color: AppTheme.accent),
                onPressed: () => context
                    .read<WatchlistBloc>()
                    .add(WatchlistRemoved(show.id)),
              ),
            );
          },
        );
    }
  }

  /// Asks before deleting everything, since it can't be undone.
  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear watchlist?'),
        content: const Text('All saved shows will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<WatchlistBloc>().add(const WatchlistCleared());
    }
  }
}
