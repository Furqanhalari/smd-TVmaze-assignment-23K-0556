import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/show_repository.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../details/view/show_details_screen.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/show_poster_card.dart';
import '../bloc/shows_bloc.dart';
import '../widgets/bottom_loader.dart';
import '../widgets/featured_row.dart';

/// Creates the ShowsBloc and starts the first load.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ShowsBloc(context.read<ShowRepository>())..add(const ShowsFetched()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Asks for the next page once the user has scrolled 90% of the way down.
  /// After a failed page we wait for the Retry button instead.
  void _onScroll() {
    final position = _scrollController.position;
    final bloc = context.read<ShowsBloc>();
    if (position.pixels >= position.maxScrollExtent * 0.9 &&
        bloc.state.loadMoreError == null) {
      bloc.add(const ShowsLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ShowsBloc>();
    bloc.add(const ShowsRefreshed());
    // Keep the refresh spinner until the bloc emits the new state.
    await bloc.stream.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: BlocBuilder<ShowsBloc, ShowsState>(
        builder: (context, state) {
          switch (state.status) {
            case ShowsStatus.initial:
            case ShowsStatus.loading:
              return const LoadingView();
            case ShowsStatus.empty:
              return const EmptyView(
                icon: Icons.live_tv_outlined,
                message: 'No shows available right now.',
              );
            case ShowsStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () =>
                    context.read<ShowsBloc>().add(const ShowsFetched()),
              );
            case ShowsStatus.success:
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildContent(context, state),
              );
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShowsState state) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return CustomScrollView(
      controller: _scrollController,
      // Lets pull-to-refresh work even when the content is short.
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (state.featured.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Text('Top Rated', style: titleStyle),
            ),
          ),
          SliverToBoxAdapter(child: FeaturedRow(shows: state.featured)),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Text('All Shows', style: titleStyle),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final show = state.shows[index];
                return ShowPosterCard(
                  show: show,
                  onTap: () => Navigator.of(context)
                      .push(ShowDetailsScreen.route(show.id)),
                );
              },
              childCount: state.shows.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: BottomLoader(
            isLoading: state.isLoadingMore,
            error: state.loadMoreError,
            onRetry: () => context.read<ShowsBloc>().add(const ShowsLoadMore()),
          ),
        ),
      ],
    );
  }
}
