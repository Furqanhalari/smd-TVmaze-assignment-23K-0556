import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/show.dart';
import '../../../shared/widgets/genre_chip.dart';
import '../../../shared/widgets/poster_image.dart';
import '../../../shared/widgets/rating_badge.dart';

/// Poster next to the title, years, runtime and rating, then the genre chips.
class DetailsHeader extends StatelessWidget {
  final Show show;

  const DetailsHeader({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    // e.g. "2008 - 2013 • 60 min". Unknown parts are left out.
    final subtitle = [
      if (show.yearsLabel.isNotEmpty) show.yearsLabel,
      if (show.runtime != null) '${show.runtime} min',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 160,
                  child: PosterImage(url: show.imageMedium),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      show.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 10),
                    RatingBadge(rating: show.rating),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (show.genres.isEmpty)
            const Text(
              'No genres',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final genre in show.genres) GenreChip(label: genre),
              ],
            ),
        ],
      ),
    );
  }
}
