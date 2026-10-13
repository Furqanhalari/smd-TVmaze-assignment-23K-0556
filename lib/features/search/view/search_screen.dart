import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/show_repository.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/show_list_tile.dart';
import '../bloc/search_bloc.dart';
import '../widgets/search_bar_field.dart';

/// Creates the SearchBloc for the Search tab.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(context.read<ShowRepository>()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    context.read<SearchBloc>().add(SearchQueryChanged(text));
  }

  void _onClear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBarField(
              controller: _controller,
              onChanged: _onChanged,
              onClear: _onClear,
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                switch (state.status) {
                  case SearchStatus.initial:
                    return const EmptyView(
                      icon: Icons.search,
                      message: 'Search for any TV show.',
                    );
                  case SearchStatus.loading:
                    return const LoadingView();
                  case SearchStatus.empty:
                    return EmptyView(
                      icon: Icons.search_off,
                      message: "No shows found for '${state.query}'",
                    );
                  case SearchStatus.failure:
                    return ErrorView(
                      message: state.errorMessage ?? 'Something went wrong.',
                      onRetry: () => _onChanged(_controller.text),
                    );
                  case SearchStatus.success:
                    return ListView.builder(
                      // Scrolling the results hides the keyboard.
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: state.results.length,
                      itemBuilder: (context, index) =>
                          ShowListTile(show: state.results[index]),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
