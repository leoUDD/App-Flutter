import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_standing.dart';
import '../models/driver_season_stats.dart';
import '../providers/season_provider.dart';
import '../services/jolpica_service.dart';
import '../services/driver_stats_service.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_compare_card.dart';
import '../widgets/comparison_bar.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({
    super.key,
    this.initialDriverId,
    this.initialDriverBId,
    this.initialSeason,
    this.showBackButton = false,
  });

  final String? initialDriverId;
  final String? initialDriverBId;
  final int? initialSeason;
  final bool showBackButton;

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final _jolpica = JolpicaService();
  final _statsService = DriverStatsService();

  final Map<String, Future<List<DriverSeasonStats>>> _cache = {};

  int? _loadedSeason;
  Future<List<DriverStanding>>? _driversFuture;
  String? _driverA;
  String? _driverB;

  void _prepareSeason(int season) {
    if (_loadedSeason == season) return;

    _loadedSeason = season;
    _driverA = widget.initialDriverId;
    _driverB = widget.initialDriverBId;

    _driversFuture = _jolpica.getDriverStandings(season: '$season');
  }

  Future<List<DriverSeasonStats>> _compare(
    int season,
    String driverA,
    String driverB,
  ) {
    final key = '$season/$driverA/$driverB';

    return _cache.putIfAbsent(
      key,
      () => Future.wait([
        _statsService.getSeasonStats(season: season, driverId: driverA),
        _statsService.getSeasonStats(season: season, driverId: driverB),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final season =
        widget.initialSeason ?? context.watch<SeasonProvider>().season;
    _prepareSeason(season);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showBackButton
          ? AppBar(title: const Text('Comparador'))
          : null,
      body: FutureBuilder<List<DriverStanding>>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _driversFuture = _jolpica.getDriverStandings(
                      season: '$season',
                    );
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Error al cargar. Reintentar'),
              ),
            );
          }

          final drivers = snapshot.data ?? [];

          if (drivers.length < 2) {
            return const Center(
              child: Text(
                'Se necesitan al menos dos pilotos '
                'para comparar.',
              ),
            );
          }

          final a = drivers.firstWhere(
            (d) => d.driverId == _driverA,
            orElse: () => drivers.first,
          );

          final b = drivers.firstWhere(
            (d) => d.driverId == _driverB && d.driverId != a.driverId,
            orElse: () => drivers.firstWhere((d) => d.driverId != a.driverId),
          );

          final colorA = _comparisonColor(a.teamId);
          final colorB = _comparisonColor(b.teamId);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'Comparador',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Temporada $season · Elige dos pilotos',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: DriverCompareCard(
                      title: 'PILOTO A',
                      driver: a,
                      color: colorA,
                      options: drivers
                          .where((d) => d.driverId != b.driverId)
                          .toList(),
                      onChanged: (id) {
                        setState(() => _driverA = id);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DriverCompareCard(
                      title: 'PILOTO B',
                      driver: b,
                      color: colorB,
                      options: drivers
                          .where((d) => d.driverId != a.driverId)
                          .toList(),
                      onChanged: (id) {
                        setState(() => _driverB = id);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              FutureBuilder<List<DriverSeasonStats>>(
                future: _compare(season, a.driverId, b.driverId),
                builder: (context, statsSnapshot) {
                  if (statsSnapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (statsSnapshot.hasError) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _cache.remove(
                              '$season/${a.driverId}/${b.driverId}',
                            );
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar estadísticas'),
                      ),
                    );
                  }

                  final stats = statsSnapshot.data!;
                  final statsA = stats[0];
                  final statsB = stats[1];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MetricRow(
                        title: 'Carreras disputadas',
                        a: statsA.races.toDouble(),
                        b: statsB.races.toDouble(),
                        textA: '${statsA.races}',
                        textB: '${statsB.races}',
                        colorA: colorA,
                        colorB: colorB,
                      ),
                      _MetricRow(
                        title: 'Victorias',
                        a: statsA.wins.toDouble(),
                        b: statsB.wins.toDouble(),
                        textA: '${statsA.wins}',
                        textB: '${statsB.wins}',
                        colorA: colorA,
                        colorB: colorB,
                      ),
                      _MetricRow(
                        title: 'Podios',
                        a: statsA.podiums.toDouble(),
                        b: statsB.podiums.toDouble(),
                        textA: '${statsA.podiums}',
                        textB: '${statsB.podiums}',
                        colorA: colorA,
                        colorB: colorB,
                      ),
                      _MetricRow(
                        title: 'Winrate',
                        a: statsA.winRate,
                        b: statsB.winRate,
                        textA: '${statsA.winRate.toStringAsFixed(1)}%',
                        textB: '${statsB.winRate.toStringAsFixed(1)}%',
                        colorA: colorA,
                        colorB: colorB,
                      ),
                      _MetricRow(
                        title: '% de podios',
                        a: statsA.podiumRate,
                        b: statsB.podiumRate,
                        textA: '${statsA.podiumRate.toStringAsFixed(1)}%',
                        textB: '${statsB.podiumRate.toStringAsFixed(1)}%',
                        colorA: colorA,
                        colorB: colorB,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// El negro de Mercedes no se distinguiría del fondo.
Color _comparisonColor(String teamId) {
  if (teamId == 'mercedes') {
    return const Color(0xFF00D2BE);
  }
  return teamColor(teamId);
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.title,
    required this.a,
    required this.b,
    required this.textA,
    required this.textB,
    required this.colorA,
    required this.colorB,
  });

  final String title;
  final double a;
  final double b;
  final String textA;
  final String textB;
  final Color colorA;
  final Color colorB;

  @override
  Widget build(BuildContext context) {
    final maximum = a > b ? a : b;
    final ratioA = maximum == 0 ? 0.0 : a / maximum;
    final ratioB = maximum == 0 ? 0.0 : b / maximum;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                textA,
                style: TextStyle(
                  color: colorA,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                textB,
                style: TextStyle(
                  color: colorB,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ComparisonBar(fraction: ratioA, color: colorA),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ComparisonBar(fraction: ratioB, color: colorB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
