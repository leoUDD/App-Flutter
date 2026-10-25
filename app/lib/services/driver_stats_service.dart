
import 'package:dio/dio.dart';

import '../models/driver_season_stats.dart';

class DriverStatsService {
  DriverStatsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.jolpi.ca/ergast/f1',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;

  Future<DriverSeasonStats> getSeasonStats({
    required int season,
    required String driverId,
  }) async {
    int races = 0;
    int wins = 0;
    int podiums = 0;

    int offset = 0;
    int total = 1;

    // Consultar todas las páginas de resultados.
    while (offset < total) {
      final response = await _dio.get<Map<String, dynamic>>(
        '/$season/drivers/$driverId/results.json',
        queryParameters: {
          'limit': 100,
          'offset': offset,
        },
      );

      final mrData =
          response.data?['MRData'] as Map<String, dynamic>?;

      if (mrData == null) {
        throw const FormatException(
          'Respuesta inválida de Jolpica',
        );
      }

      total = int.tryParse(
            mrData['total'].toString(),
          ) ??
          0;

      final raceTable =
          mrData['RaceTable'] as Map<String, dynamic>;

      final raceList =
          (raceTable['Races'] as List?) ?? const [];

      if (raceList.isEmpty) break;

      for (final item in raceList) {
        final race = item as Map<String, dynamic>;

        final results =
            (race['Results'] as List?) ?? const [];

        if (results.isEmpty) continue;

        final result =
            results.first as Map<String, dynamic>;

        // positionText indica la posición final oficial.
        final position = int.tryParse(
          result['positionText']?.toString() ?? '',
        );

        races++;

        if (position == 1) {
          wins++;
        }

        if (position != null &&
            position >= 1 &&
            position <= 3) {
          podiums++;
        }
      }

      offset += raceList.length;
    }

    return DriverSeasonStats(
      races: races,
      wins: wins,
      podiums: podiums,
    );
  }
}
