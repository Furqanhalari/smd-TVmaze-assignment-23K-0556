/// Base URL, endpoints and network settings for the TVMaze API.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.tvmaze.com';
  static const Duration timeout = Duration(seconds: 15);

  static String shows(int page) => '/shows?page=$page';
  static String search(String query) =>
      '/search/shows?q=${Uri.encodeQueryComponent(query)}';
  static String showDetails(int id) => '/shows/$id';
  static String cast(int id) => '/shows/$id/cast';
  static String episodes(int id) => '/shows/$id/episodes';
}
