import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/cast_member.dart';
import '../models/episode.dart';
import '../models/show.dart';

/// All TVMaze API calls. Blocs talk to this class, never to http directly.
class ShowRepository {
  final ApiClient _apiClient;

  ShowRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// One page (up to 250 shows) of the show index.
  /// Returns an empty list after the last page (the API answers 404).
  Future<List<Show>> fetchShows(int page) async {
    try {
      final data = await _apiClient.get(ApiConstants.shows(page));
      return _parseList(data, Show.fromJson);
    } on NotFoundException {
      return [];
    }
  }

  /// Search results come back as `[{score, show: {...}}]`.
  Future<List<Show>> searchShows(String query) async {
    final data = await _apiClient.get(ApiConstants.search(query));
    return _parseList(
      data,
      (item) => Show.fromJson(item['show'] as Map<String, dynamic>),
    );
  }

  Future<Show> fetchShowDetails(int id) async {
    final data = await _apiClient.get(ApiConstants.showDetails(id));
    try {
      return Show.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      throw const ApiException('Invalid response from server.');
    }
  }

  Future<List<CastMember>> fetchCast(int showId) async {
    final data = await _apiClient.get(ApiConstants.cast(showId));
    return _parseList(data, CastMember.fromJson);
  }

  Future<List<Episode>> fetchEpisodes(int showId) async {
    final data = await _apiClient.get(ApiConstants.episodes(showId));
    return _parseList(data, Episode.fromJson);
  }

  /// Parses a JSON list item by item. A malformed item (e.g. missing id)
  /// is skipped, so one bad entry can't break the whole screen.
  static List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! List) {
      throw const ApiException('Invalid response from server.');
    }
    final items = <T>[];
    for (final item in data) {
      try {
        items.add(fromJson(item as Map<String, dynamic>));
      } catch (_) {
        // Skip this item and keep the rest.
      }
    }
    return items;
  }
}
