import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cast_member.dart';
import '../../../shared/widgets/poster_image.dart';

/// Round actor photo, actor name and the character they play.
class CastTile extends StatelessWidget {
  final CastMember member;

  const CastTile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipOval(
        child: SizedBox(
          width: 56,
          height: 56,
          // Fall back to the character photo if the actor has none.
          child: PosterImage(url: member.personImage ?? member.characterImage),
        ),
      ),
      title: Text(
        member.personName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        'as ${member.characterName}',
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }
}
