import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Footer under the grid: a spinner while the next page loads,
/// or a retry button if loading it failed.
class BottomLoader extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const BottomLoader({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox.shrink();
    if (isLoading) {
      child = const CircularProgressIndicator();
    } else if (error != null) {
      child = Column(
        children: [
          Text(error!, style: const TextStyle(color: AppTheme.textSecondary)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: child),
    );
  }
}
