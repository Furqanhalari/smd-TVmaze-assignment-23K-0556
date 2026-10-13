import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/show.dart';

/// Saves the watchlist on the device with SharedPreferences.
/// The whole list is stored as one JSON string under [_key].
class WatchlistRepository {
  static const String _key = 'watchlist';

  SharedPreferences? _prefs;

  WatchlistRepository({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Returns the saved shows, or an empty list if nothing was saved yet.
  Future<List<Show>> loadWatchlist() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final data = jsonDecode(jsonString) as List;
      return data.map((e) => Show.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Unreadable data (e.g. an older format): start with an empty list.
      return [];
    }
  }

  /// Overwrites the saved list with [shows].
  Future<void> saveWatchlist(List<Show> shows) async {
    final prefs = await _instance;
    final jsonString = jsonEncode(shows.map((s) => s.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
