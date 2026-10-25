import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/season_provider.dart';
import '../models/race.dart';
import '../services/jolpica_service.dart';
import '../widgets/season_dropdown.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.service});

  final JolpicaService? service;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final JolpicaService _service = widget.service ?? JolpicaService();
  int _loadedSeason = DateTime.now().year;
  late Future<List<Race>> _future = _service.getRaces(season: '$_loadedSeason');

  void _reload() {
    setState(() {
      _future = _service.getRaces(season: '$_loadedSeason');
    });
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      return 'No se pudo conectar con la API (${error.type.name}).';
    }
    return 'Ocurrió un error inesperado.';
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    if (season != _loadedSeason) {
      _loadedSeason = season;
      _future = _service.getRaces(season: '$season');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de carreras'),
        actions: [const SeasonDropdown(), const SizedBox(width: 16)],
      ),

      body: FutureBuilder<List<Race>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage(snapshot.error!)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final races = snapshot.data!;
          if (races.isEmpty) {
            return const Center(
              child: Text('Sin carreras para esta temporada'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: races.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final race = races[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${race.round}')),
                  title: Text(race.name),
                  subtitle: Text(
                    '${race.circuitName}\n${race.locality}, ${race.country}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(race.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (race.hasTime && race.date != null)
                        Text(_formatTime(race.date!)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

const _months = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final d = date.toLocal();
  return '${d.day} ${_months[d.month - 1]}';
}

String _formatTime(DateTime? date) {
  if (date == null) return '-';
  final d = date.toLocal();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
