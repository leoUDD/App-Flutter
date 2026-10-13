import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/driver_standing.dart';
import '../services/jolpica_service.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key, this.service});

  final JolpicaService? service;

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late final JolpicaService _service = widget.service ?? JolpicaService();
  late Future<List<DriverStanding>> _future = _service.getDriverStandings();

  void _reload() {
    setState(() => _future = _service.getDriverStandings());
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      return 'No se pudo conectar con la API (${error.type.name}).';
    }
    return 'Ocurrió un error inesperado.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campeonato de pilotos')),
      body: FutureBuilder<List<DriverStanding>>(
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
                      onPressed: _reload, child: const Text('Reintentar')),
                ],
              ),
            );
          }
          final standings = snapshot.data!;
          if (standings.isEmpty) {
            return const Center(child: Text('Sin datos para esta temporada.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: standings.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = standings[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${s.position}')),
                  title: Text(s.fullName),
                  subtitle: Text('${s.teamName} · ${s.wins} victorias'),
                  trailing: Text(
                    '${s.points % 1 == 0 ? s.points.toInt() : s.points} pts',
                    style: Theme.of(context).textTheme.titleMedium,
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
