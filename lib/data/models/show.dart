import 'package:equatable/equatable.dart';

/// A TV show from the TVMaze API.
/// Every field except [id] and [name] can be missing, so they are nullable.
class Show extends Equatable {
  final int id;
  final String name;
  final String? imageMedium;
  final String? imageOriginal;
  final double? rating;
  final List<String> genres;
  final String? summary; // raw HTML, strip it before showing
  final String? premiered;
  final String? ended;
  final String? status;
  final String? language;
  final String? network;
  final int? runtime;

  const Show({
    required this.id,
    required this.name,
    this.imageMedium,
    this.imageOriginal,
    this.rating,
    this.genres = const [],
    this.summary,
    this.premiered,
    this.ended,
    this.status,
    this.language,
    this.network,
    this.runtime,
  });

  /// Parses the TVMaze show JSON. Network falls back to the web channel
  /// (e.g. Netflix shows have no TV network).
  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    final network = json['network'] as Map<String, dynamic>?;
    final webChannel = json['webChannel'] as Map<String, dynamic>?;

    return Show(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      imageMedium: image?['medium'] as String?,
      imageOriginal: image?['original'] as String?,
      rating: (rating?['average'] as num?)?.toDouble(),
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((g) => g.toString())
          .toList(),
      summary: json['summary'] as String?,
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      status: json['status'] as String?,
      language: json['language'] as String?,
      network: (network?['name'] ?? webChannel?['name']) as String?,
      runtime: json['runtime'] as int?,
    );
  }

  /// Writes the same shape that [Show.fromJson] reads,
  /// so a saved show can be parsed back (used by the watchlist).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': {'medium': imageMedium, 'original': imageOriginal},
        'rating': {'average': rating},
        'genres': genres,
        'summary': summary,
        'premiered': premiered,
        'ended': ended,
        'status': status,
        'language': language,
        'network': network == null ? null : {'name': network},
        'runtime': runtime,
      };

  /// e.g. "2013 - 2015", "2019 - Present", or "" when unknown.
  String get yearsLabel {
    final start = _year(premiered);
    if (start == null) return '';
    final end = _year(ended);
    if (end != null) return '$start - $end';
    return status == 'Running' ? '$start - Present' : start;
  }

  static String? _year(String? date) =>
      (date != null && date.length >= 4) ? date.substring(0, 4) : null;

  @override
  List<Object?> get props => [
        id,
        name,
        imageMedium,
        imageOriginal,
        rating,
        genres,
        summary,
        premiered,
        ended,
        status,
        language,
        network,
        runtime,
      ];
}
