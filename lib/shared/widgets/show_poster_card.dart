import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/show.dart';
import 'poster_image.dart';
import 'rating_badge.dart';

/// Poster with the rating on top, then the title and genres below.
/// Used in the Home grid and the Top Rated row.
class ShowPosterCard extends StatelessWidget {
  final Show show;
  final VoidCallback? onTap;

  const ShowPosterCard({super.key, required this.show, this.onTap});

  @override
  Widget build(BuildContext context) {
    final genres =
        show.genres.isEmpty ? 'No genres' : show.genres.take(2).join(' • ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(url: show.imageMedium),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: RatingBadge(rating: show.rating),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            show.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
          ),
          Text(
            genres,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
