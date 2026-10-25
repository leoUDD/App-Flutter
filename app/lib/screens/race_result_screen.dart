import 'package:flutter/material.dart';

import '../models/race.dart';
import '../models/race_result.dart';
import '../services/jolpica_service.dart';
import '../theme/app_theme.dart';
import '../widgets/result_podium.dart';
import '../widgets/result_table.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_views.dart';

const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

class RaceResultScreen extends StatefulWidget {
  const RaceResultScreen({super.key, required this.race, this.service});

  final Race race;
  final JolpicaService? service;

  @override
  State<RaceResultScreen> createState() => _RaceResultScreenState();
}

class _RaceResultScreenState extends State<RaceResultScreen> {
  late final JolpicaService _service = widget.service ?? JolpicaService();
  late Future<List<RaceResult>> _future = _load();

  Future<List<RaceResult>> _load() {
    return _service.getRaceResults(
      season: widget.race.season,
      round: widget.race.round,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  /// "Interlagos · Brasil · 3 nov 2024 · 69 vueltas"
  String _subtitle(List<RaceResult> results) {
    final race = widget.race;
    final date = race.date?.toLocal();
    final parts = [
      race.circuitName,
      race.country,
      if (date != null) '${date.day} ${_months[date.month - 1]} ${date.year}',
      if (results.isNotEmpty && results.first.laps > 0)
        '${results.first.laps} vueltas',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final race = widget.race;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 0,
        title: const Text(
          'Resultado',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E3039)),
            ),
            child: Text(
              'Ronda ${race.round} · ${race.season}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<RaceResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return StandingsSkeleton(
              title: race.name,
              subtitle: 'Cargando resultado…',
            );
          }
          if (snapshot.hasError) {
            return ErrorView(
              what: 'el resultado',
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final results = snapshot.data!;
          if (results.isEmpty) {
            return const EmptyView(
              heading: 'Esta carrera aún no se ha disputado',
              message: 'Los resultados estarán disponibles cuando termine la carrera.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Text(
                  race.name,
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle(results),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                if (results.length >= 3) ...[
                  ResultPodium(top3: results.sublist(0, 3)),
                  const SizedBox(height: 14),
                ],
                ResultTable(results: results),
              ],
            ),
          );
        },
      ),
    );
  }
}
