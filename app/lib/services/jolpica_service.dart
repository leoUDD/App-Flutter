import 'package:dio/dio.dart';

import '../models/calendar_entry.dart';
import '../models/race_result.dart';
import '../models/driver_standing.dart';
import '../models/race.dart';
import '../models/standings_data.dart';

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

  /// Clasificación de pilotos más el dato de si la temporada ya terminó.
  Future<StandingsData> getStandingsData({required int season}) async {
    final standingsFuture = getDriverStandings(season: '$season');
    final finishedFuture = _isSeasonFinished(season);
    return StandingsData(
      standings: await standingsFuture,
      seasonFinished: await finishedFuture,
    );
  }

  /// Una temporada pasada siempre está terminada. La del año en curso lo está
  /// solo si todas sus carreras ya tienen ganador. Ante un fallo, se asume que no.
  Future<bool> _isSeasonFinished(int season) async {
    if (season < DateTime.now().year) return true;
    try {
      final (races, winners) = await (
        getRaces(season: '$season'),
        getRaceWinners(season: season),
      ).wait;
      return races.isNotEmpty && winners.length >= races.length;
    } catch (_) {
      return false;
    }
  }

  /// Ganador de cada carrera ya disputada de la temporada, por número de ronda.
  /// Es una sola petición: `/{año}/results/1.json` devuelve solo el 1.º de cada carrera.
  Future<Map<int, RaceWinner>> getRaceWinners({required int season}) async {
    final data = await _get('/$season/results/1.json', query: {'limit': 100});
    final races = data['RaceTable']['Races'] as List;
    final winners = <int, RaceWinner>{};
    for (final race in races) {
      final results = (race['Results'] as List?) ?? const [];
      if (results.isEmpty) continue;
      final round = int.parse(race['round'] as String);
      winners[round] = RaceWinner.fromJson(
        results.first as Map<String, dynamic>,
      );
    }
    return winners;
  }

  /// Calendario de la temporada con el ganador de cada carrera disputada.
  /// Si falla la petición de ganadores, se muestra el calendario sin ellos.
  Future<List<CalendarEntry>> getCalendar({required int season}) async {
    final (races, winners) = await (
      getRaces(season: '$season'),
      getRaceWinners(season: season).catchError((_) => <int, RaceWinner>{}),
    ).wait;
    return races
        .map((race) => CalendarEntry(race: race, winner: winners[race.round]))
        .toList();
  }

  /// Resultados de una carrera.
  Future<List<RaceResult>> getRaceResults({
    required int season,
    required int round,
  }) async {
    final data = await _get(
      '/$season/$round/results.json',
      query: {'limit': 100},
    );
    final races = data['RaceTable']['Races'] as List;
    if (races.isEmpty) return [];
    final results = races.first['Results'] as List;
    return results
        .map((e) => RaceResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
