import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_view.dart';

/// Discover screen. Placeholder until the shows list is added.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: const EmptyView(
        icon: Icons.live_tv_outlined,
        message: 'Shows will appear here.',
      ),
    );
  }
}
