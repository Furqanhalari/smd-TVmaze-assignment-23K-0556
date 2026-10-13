import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Small star + rating pill. Shows "N/A" when the rating is null.
class RatingBadge extends StatelessWidget {
  final double? rating;

  const RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: AppTheme.rating),
          const SizedBox(width: 3),
          Text(
            rating?.toStringAsFixed(1) ?? 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
