import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/show_repository.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/episodes_bloc.dart';
import 'episode_tile.dart';

/// The Episodes tab: a season dropdown and the episodes of that season.
/// Like the Cast tab, it only loads when first shown and is kept alive.
class EpisodesTab extends StatefulWidget {
  final int showId;

  const EpisodesTab({super.key, required this.showId});

  @override
  State<EpisodesTab> createState() => _EpisodesTabState();
}

class _EpisodesTabState extends State<EpisodesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => EpisodesBloc(context.read<ShowRepository>())
        ..add(EpisodesFetched(widget.showId)),
      child: BlocBuilder<EpisodesBloc, EpisodesState>(
        builder: (context, state) {
          switch (state.status) {
            case EpisodesStatus.initial:
            case EpisodesStatus.loading:
              return const LoadingView();
            case EpisodesStatus.empty:
              return const EmptyView(
                icon: Icons.video_library_outlined,
                message: 'No episodes available.',
              );
            case EpisodesStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () => context
                    .read<EpisodesBloc>()
                    .add(EpisodesFetched(widget.showId)),
              );
            case EpisodesStatus.success:
              final episodes = state.selectedEpisodes;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                // First row is the dropdown, the rest are episodes.
                itemCount: episodes.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _SeasonDropdown(state: state);
                  return EpisodeTile(episode: episodes[index - 1]);
                },
              );
          }
        },
      ),
    );
  }
}

/// "Season 1 (7 episodes)" picker. Choosing one adds EpisodesSeasonSelected.
class _SeasonDropdown extends StatelessWidget {
  final EpisodesState state;

  const _SeasonDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: DropdownButtonFormField<int>(
        value: state.selectedSeason,
        isExpanded: true,
        items: [
          for (final entry in state.seasons.entries)
            DropdownMenuItem(
              value: entry.key,
              child: Text(
                'Season ${entry.key} (${entry.value.length} '
                '${entry.value.length == 1 ? 'episode' : 'episodes'})',
              ),
            ),
        ],
        onChanged: (season) {
          if (season != null) {
            context.read<EpisodesBloc>().add(EpisodesSeasonSelected(season));
          }
        },
      ),
    );
  }
}
