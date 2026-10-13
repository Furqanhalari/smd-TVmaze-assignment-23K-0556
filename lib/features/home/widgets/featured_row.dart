import 'package:flutter/material.dart';

import '../../../data/models/show.dart';
import '../../../shared/widgets/show_poster_card.dart';

/// Horizontal "Top Rated" list shown above the grid.
class FeaturedRow extends StatelessWidget {
  final List<Show> shows;

  const FeaturedRow({super.key, required this.shows});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shows.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => SizedBox(
          width: 130,
          child: ShowPosterCard(show: shows[index]),
        ),
      ),
    );
  }
}
