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
      final data = await _apiClient.get(ApiConstants.shows(page)) as List;
      return data.map((e) => Show.fromJson(e as Map<String, dynamic>)).toList();
    } on NotFoundException {
      return [];
    }
  }

  /// Search results come back as `[{score, show: {...}}]`.
  Future<List<Show>> searchShows(String query) async {
    final data = await _apiClient.get(ApiConstants.search(query)) as List;
    return data.map((e) {
      final item = e as Map<String, dynamic>;
      return Show.fromJson(item['show'] as Map<String, dynamic>);
    }).toList();
  }

  Future<Show> fetchShowDetails(int id) async {
    final data = await _apiClient.get(ApiConstants.showDetails(id));
    return Show.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CastMember>> fetchCast(int showId) async {
    final data = await _apiClient.get(ApiConstants.cast(showId)) as List;
    return data
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Episode>> fetchEpisodes(int showId) async {
    final data = await _apiClient.get(ApiConstants.episodes(showId)) as List;
    return data
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
