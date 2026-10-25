import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calendar_entry.dart';
import '../providers/season_provider.dart';
import '../services/jolpica_service.dart';
import '../theme/app_theme.dart';
import '../widgets/race_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_views.dart';
import 'race_result_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.service});

  final JolpicaService? service;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final JolpicaService _service = widget.service ?? JolpicaService();
  int _loadedSeason = DateTime.now().year;
  late Future<List<CalendarEntry>> _future = _service.getCalendar(
    season: _loadedSeason,
  );

  void _reload() {
    setState(() {
      _future = _service.getCalendar(season: _loadedSeason);
    });
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    if (season != _loadedSeason) {
      _loadedSeason = season;
      _future = _service.getCalendar(season: season);
    }
    return Scaffold(
      body: FutureBuilder<List<CalendarEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CardsSkeleton(
              title: 'Calendario',
              subtitle: 'Cargando carreras…',
            );
          }
          if (snapshot.hasError) {
            return ErrorView(
              title: 'Calendario',
              what: 'el calendario',
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          final entries = snapshot.data!;
          if (entries.isEmpty) {
            final previous = DateTime.now().year - 1;
            return EmptyView(
              title: 'Calendario',
              icon: Icons.event_busy_outlined,
              heading: 'No hay carreras para esta temporada',
              message: 'Todavía no hay un calendario publicado. Prueba con otra temporada.',
              actionLabel: 'Ver temporada $previous',
              onAction: () =>
                  context.read<SeasonProvider>().setSeason(previous),
            );
          }
          final played = entries.where((e) => e.played).length;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  'Calendario',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                _ProgressCard(played: played, total: entries.length),
                const SizedBox(height: 16),
                for (final entry in entries) ...[
                  RaceCard(
                    entry: entry,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RaceResultScreen(race: entry.race),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.played, required this.total});

  final int played;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : played / total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.avatar),
      ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$played',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    TextSpan(text: ' de $total carreras disputadas'),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(fraction * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
