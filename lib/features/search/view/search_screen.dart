import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_view.dart';

/// Search screen. Placeholder until search is added.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const EmptyView(
        icon: Icons.search,
        message: 'Search for any TV show.',
      ),
    );
  }
}
