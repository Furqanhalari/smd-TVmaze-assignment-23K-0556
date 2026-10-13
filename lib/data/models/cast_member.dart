import 'package:equatable/equatable.dart';

/// One entry from `/shows/:id/cast`: an actor and the character they play.
class CastMember extends Equatable {
  final int personId;
  final String personName;
  final String? personImage;
  final String characterName;
  final String? characterImage;

  const CastMember({
    required this.personId,
    required this.personName,
    this.personImage,
    required this.characterName,
    this.characterImage,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final character = json['character'] as Map<String, dynamic>? ?? {};
    final personImage = person['image'] as Map<String, dynamic>?;
    final characterImage = character['image'] as Map<String, dynamic>?;

    return CastMember(
      personId: person['id'] as int? ?? 0,
      personName: person['name'] as String? ?? 'Unknown',
      personImage: personImage?['medium'] as String?,
      characterName: character['name'] as String? ?? 'Unknown',
      characterImage: characterImage?['medium'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'person': {
          'id': personId,
          'name': personName,
          'image': {'medium': personImage},
        },
        'character': {
          'name': characterName,
          'image': {'medium': characterImage},
        },
      };

  @override
  List<Object?> get props =>
      [personId, personName, personImage, characterName, characterImage];
}
