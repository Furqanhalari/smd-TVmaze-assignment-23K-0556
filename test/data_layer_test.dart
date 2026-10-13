import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmaze_app/core/errors/exceptions.dart';
import 'package:tvmaze_app/core/network/api_client.dart';
import 'package:tvmaze_app/core/utils/html_utils.dart';
import 'package:tvmaze_app/data/models/cast_member.dart';
import 'package:tvmaze_app/data/models/episode.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';

void main() {
  group('Show model', () {
    test('parses a full show', () {
      final show = Show.fromJson(const {
        'id': 1,
        'name': 'Under the Dome',
        'image': {'medium': 'm.jpg', 'original': 'o.jpg'},
        'rating': {'average': 6.6},
        'genres': ['Drama', 'Thriller'],
        'premiered': '2013-06-24',
        'ended': '2015-09-10',
        'network': {'name': 'CBS'},
      });
      expect(show.rating, 6.6);
      expect(show.genres, ['Drama', 'Thriller']);
      expect(show.network, 'CBS');
      expect(show.yearsLabel, '2013 - 2015');
    });

    test('handles null image, rating, genres and network', () {
      final show = Show.fromJson(const {
        'id': 2,
        'name': 'X',
        'image': null,
        'rating': {'average': null},
        'genres': null,
        'network': null,
        'webChannel': {'name': 'Netflix'},
      });
      expect(show.imageMedium, isNull);
      expect(show.rating, isNull);
      expect(show.genres, isEmpty);
      expect(show.network, 'Netflix');
      expect(show.yearsLabel, '');
    });

    test('toJson round-trips through fromJson', () {
      const show = Show(id: 3, name: 'Y', rating: 8.0, network: 'HBO');
      expect(Show.fromJson(show.toJson()), show);
    });
  });

  test('CastMember and Episode handle missing fields', () {
    final cast = CastMember.fromJson(const {
      'person': {'id': 1, 'name': 'A', 'image': null},
      'character': {'name': 'B', 'image': null},
    });
    expect(cast.personImage, isNull);

    final ep = Episode.fromJson(
        const {'id': 1, 'name': 'Pilot', 'season': 1, 'airdate': ''});
    expect(ep.airdate, isNull);
    expect(ep.number, isNull);
  });

  test('HtmlUtils strips tags and entities', () {
    expect(HtmlUtils.strip('<p><b>Hi</b> &amp; bye</p>'), 'Hi & bye');
    expect(HtmlUtils.strip(null), '');
  });

  group('ShowRepository', () {
    ShowRepository repoWith(http.Response Function(http.Request) handler) =>
        ShowRepository(
          apiClient: ApiClient(client: MockClient((r) async => handler(r))),
        );

    test('fetchShows returns empty list on 404 (past last page)', () async {
      final repo = repoWith((_) => http.Response('', 404));
      expect(await repo.fetchShows(999), isEmpty);
    });

    test('searchShows unwraps the show field', () async {
      final repo = repoWith((_) => http.Response(
          jsonEncode([
            {
              'score': 0.9,
              'show': {'id': 5, 'name': 'Girls'}
            }
          ]),
          200));
      final results = await repo.searchShows('girls');
      expect(results.single.name, 'Girls');
    });

    test('server error throws ApiException', () async {
      final repo = repoWith((_) => http.Response('', 500));
      expect(repo.fetchShowDetails(1), throwsA(isA<ApiException>()));
    });

    test('a malformed item is skipped, the rest are kept', () async {
      final repo = repoWith((_) => http.Response(
          jsonEncode([
            {'id': 1, 'name': 'Good'},
            {'name': 'No id'},
            'not a map',
          ]),
          200));
      final shows = await repo.fetchShows(0);
      expect(shows.map((s) => s.name), ['Good']);
    });

    test('an unexpected response shape throws ApiException', () async {
      final repo = repoWith((_) => http.Response('{"oops": true}', 200));
      expect(repo.fetchCast(1), throwsA(isA<ApiException>()));
    });

    test('a dropped connection throws NetworkException', () async {
      final repo = ShowRepository(
        apiClient: ApiClient(
          client: MockClient((_) async => throw http.ClientException('down')),
        ),
      );
      expect(repo.searchShows('x'), throwsA(isA<NetworkException>()));
    });
  });
}
