import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/show_repository.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/cast_bloc.dart';
import 'cast_tile.dart';

/// The Cast tab. Its CastBloc is created (and the API called) only when
/// the tab is first shown. Keep-alive stops it reloading on every swipe.
class CastTab extends StatefulWidget {
  final int showId;

  const CastTab({super.key, required this.showId});

  @override
  State<CastTab> createState() => _CastTabState();
}

class _CastTabState extends State<CastTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => CastBloc(context.read<ShowRepository>())
        ..add(CastFetched(widget.showId)),
      child: BlocBuilder<CastBloc, CastState>(
        builder: (context, state) {
          switch (state.status) {
            case CastStatus.initial:
            case CastStatus.loading:
              return const LoadingView();
            case CastStatus.empty:
              return const EmptyView(
                icon: Icons.people_outline,
                message: 'No cast information available.',
              );
            case CastStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () =>
                    context.read<CastBloc>().add(CastFetched(widget.showId)),
              );
            case CastStatus.success:
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.cast.length,
                itemBuilder: (_, index) => CastTile(member: state.cast[index]),
              );
          }
        },
      ),
    );
  }
}
