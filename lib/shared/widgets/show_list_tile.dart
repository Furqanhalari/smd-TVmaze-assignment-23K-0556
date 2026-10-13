import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/show.dart';
import 'poster_image.dart';
import 'rating_badge.dart';

/// Row with a small poster, the title, years, genres and rating.
/// Used for search results and the watchlist.
class ShowListTile extends StatelessWidget {
  final Show show;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ShowListTile({
    super.key,
    required this.show,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final genres =
        show.genres.isEmpty ? 'No genres' : show.genres.take(3).join(' • ');
    final years = show.yearsLabel;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 88,
                child: PosterImage(url: show.imageMedium),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (years.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(years, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    genres,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RatingBadge(rating: show.rating),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
