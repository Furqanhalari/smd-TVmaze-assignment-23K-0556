import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_view.dart';

/// Watchlist screen. Placeholder until the watchlist is added.
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: const EmptyView(
        icon: Icons.favorite_border,
        message: 'Your watchlist is empty.',
      ),
    );
  }
}
