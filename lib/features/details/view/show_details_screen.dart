import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/show.dart';
import '../../../data/repositories/show_repository.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/poster_image.dart';
import '../bloc/show_details_bloc.dart';
import '../widgets/details_header.dart';
import '../widgets/overview_tab.dart';

/// Opened from a Home or Search tile with only the show id.
/// Creates its own ShowDetailsBloc, which is closed when the page is popped.
class ShowDetailsScreen extends StatelessWidget {
  final int showId;

  const ShowDetailsScreen({super.key, required this.showId});

  /// Used by the tiles: `Navigator.push(context, ShowDetailsScreen.route(id))`.
  static Route<void> route(int showId) {
    return MaterialPageRoute(
      builder: (_) => ShowDetailsScreen(showId: showId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShowDetailsBloc(context.read<ShowRepository>())
        ..add(ShowDetailsFetched(showId)),
      child: ShowDetailsView(showId: showId),
    );
  }
}

class ShowDetailsView extends StatelessWidget {
  final int showId;

  const ShowDetailsView({super.key, required this.showId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
      builder: (context, state) {
        switch (state.status) {
          case ShowDetailsStatus.initial:
          case ShowDetailsStatus.loading:
            return _simplePage(const LoadingView());
          case ShowDetailsStatus.empty:
            return _simplePage(const EmptyView(
              icon: Icons.search_off,
              message: 'This show could not be found.',
            ));
          case ShowDetailsStatus.failure:
            return _simplePage(ErrorView(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () => context
                  .read<ShowDetailsBloc>()
                  .add(ShowDetailsFetched(showId)),
            ));
          case ShowDetailsStatus.success:
            return _DetailsContent(show: state.show!);
        }
      },
    );
  }

  /// A plain page with a back button, for loading / empty / error.
  Widget _simplePage(Widget body) {
    return Scaffold(appBar: AppBar(), body: body);
  }
}

/// Backdrop image, header, a pinned TabBar and the three tabs.
class _DetailsContent extends StatelessWidget {
  final Show show;

  const _DetailsContent({required this.show});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              title: Text(show.name),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    PosterImage(url: show.imageOriginal ?? show.imageMedium),
                    // Fades the image into the background color.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black45, AppTheme.background],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: DetailsHeader(show: show)),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Episodes'),
                    Tab(text: 'Cast'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              OverviewTab(show: show),
              const EmptyView(
                icon: Icons.video_library_outlined,
                message: 'Episodes will appear here.',
              ),
              const EmptyView(
                icon: Icons.people_outline,
                message: 'Cast will appear here.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the TabBar pinned under the app bar while the header scrolls away.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: AppTheme.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
