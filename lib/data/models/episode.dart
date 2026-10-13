import 'package:equatable/equatable.dart';

/// One episode from `/shows/:id/episodes`.
class Episode extends Equatable {
  final int id;
  final String name;
  final int season;
  final int? number; // null for specials
  final String? airdate;
  final int? runtime;
  final String? imageMedium;
  final String? summary;

  const Episode({
    required this.id,
    required this.name,
    required this.season,
    this.number,
    this.airdate,
    this.runtime,
    this.imageMedium,
    this.summary,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final airdate = json['airdate'] as String?;

    return Episode(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'TBA',
      season: json['season'] as int? ?? 0,
      number: json['number'] as int?,
      // TVMaze sends an empty string when the airdate is unknown
      airdate: (airdate == null || airdate.isEmpty) ? null : airdate,
      runtime: json['runtime'] as int?,
      imageMedium: image?['medium'] as String?,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'season': season,
        'number': number,
        'airdate': airdate,
        'runtime': runtime,
        'image': {'medium': imageMedium},
        'summary': summary,
      };

  @override
  List<Object?> get props =>
      [id, name, season, number, airdate, runtime, imageMedium, summary];
}
