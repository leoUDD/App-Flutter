import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_standing.dart';
import '../models/standings_data.dart';
import '../providers/season_provider.dart';
import '../services/jolpica_service.dart';
import '../theme/app_theme.dart';
import '../widgets/podium.dart';
import '../widgets/skeleton.dart';
import '../widgets/standing_row.dart';
import '../widgets/state_views.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key, this.service});

  final JolpicaService? service;

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late final JolpicaService _service = widget.service ?? JolpicaService();
  int _loadedSeason = DateTime.now().year;
  late Future<StandingsData> _future = _service.getStandingsData(
    season: _loadedSeason,
  );

  void _reload() {
    setState(() {
      _future = _service.getStandingsData(season: _loadedSeason);
    });
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    if (season != _loadedSeason) {
      _loadedSeason = season;
      _future = _service.getStandingsData(season: season);
    }
    return Scaffold(
      body: FutureBuilder<StandingsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const StandingsSkeleton(
              title: 'Ranking de pilotos',
              subtitle: 'Cargando clasificación…',
            );
          }
          if (snapshot.hasError) {
            return ErrorView(
              title: 'Ranking de pilotos',
              what: 'la clasificación',
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final data = snapshot.data!;
          final standings = data.standings;
          if (standings.isEmpty) {
            final previous = DateTime.now().year - 1;
            return EmptyView(
              title: 'Ranking de pilotos',
              heading: 'No hay resultados disponibles para esta temporada',
              message: 'Todavía no se ha disputado ninguna carrera. Prueba con otra temporada.',
              actionLabel: 'Ver temporada $previous',
              onAction: () =>
                  context.read<SeasonProvider>().setSeason(previous),
            );
          }
          final hasPodium = standings.length >= 3;
          final rows = hasPodium ? standings.sublist(3) : standings;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StandingsHeader(
                  season: _loadedSeason,
                  count: standings.length,
                ),
                const SizedBox(height: 16),
                if (hasPodium) ...[
                  Podium(
                    top3: standings.sublist(0, 3),
                    seasonFinished: data.seasonFinished,
                  ),
                  const SizedBox(height: 16),
                ],
                if (rows.isNotEmpty) _RowsCard(rows: rows),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader({required this.season, required this.count});

  final int season;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ranking de pilotos',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Clasificación · Temporada $season',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        Text(
          '$count pilotos',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.rows});

  final List<DriverStanding> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.avatar),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.avatar),
            StandingRow(standing: rows[i]),
          ],
        ],
      ),
    );
  }
}
