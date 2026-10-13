import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/episode.dart';
import '../../../shared/widgets/poster_image.dart';

/// Thumbnail, episode number and name, airdate and runtime.
class EpisodeTile extends StatelessWidget {
  final Episode episode;

  const EpisodeTile({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final number = episode.number == null ? 'Special' : 'E${episode.number}';
    final details = [
      episode.airdate ?? 'Airdate TBA',
      if (episode.runtime != null) '${episode.runtime} min',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 120,
              height: 68, // roughly 16:9
              child: PosterImage(url: episode.imageMedium),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  episode.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(details, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
