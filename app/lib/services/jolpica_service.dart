import 'package:dio/dio.dart';

import '../models/driver_standing.dart';
import '../models/race.dart';

class JolpicaService {
  JolpicaService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.jolpi.ca/ergast/f1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  // Caché simple en memoria: Jolpica tiene límite de peticiones.
  static const _cacheDuration = Duration(minutes: 5);
  final Map<String, ({DateTime at, Map<String, dynamic> data})> _cache = {};

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final key = '$path?$query';
    final cached = _cache[key];
    if (cached != null &&
        DateTime.now().difference(cached.at) < _cacheDuration) {
      return cached.data;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    final mrData = response.data!['MRData'] as Map<String, dynamic>;
    _cache[key] = (at: DateTime.now(), data: mrData);
    return mrData;
  }

  /// Clasificación del campeonato de pilotos. [season] puede ser 'current' o un año.
  Future<List<DriverStanding>> getDriverStandings({
    String season = 'current',
  }) async {
    final data = await _get(
      '/$season/driverstandings.json',
      query: {'limit': 100},
    );
    final lists = data['StandingsTable']['StandingsLists'] as List;
    if (lists.isEmpty) return [];
    final standings = lists.first['DriverStandings'] as List;
    return standings
        .map((e) => DriverStanding.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Calendario de la temporada.
  Future<List<Race>> getRaces({String season = 'current'}) async {
    final data = await _get('/$season.json', query: {'limit': 100});
    final races = data['RaceTable']['Races'] as List;
    return races.map((e) => Race.fromJson(e as Map<String, dynamic>)).toList();
  }
}
