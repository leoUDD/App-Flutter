import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/race.dart';
import '../services/jolpica_service.dart';
import '../models/race_result.dart';

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

  String _errorMessage(Object error) {
    if (error is DioException) {
      return 'No se pudo conectar con la API (${error.type.name}).';
    }
    return 'Ocurrió un error inesperado.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.race.name)),

      body: FutureBuilder<List<RaceResult>>(
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
          final results = snapshot.data!;
          if (results.isEmpty) {
            return const Center(
              child: Text('Esta carrera aún no tiene resultados.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final result = results[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(result.positionText)),
                  title: Text(result.driverName),
                  subtitle: Text(
                    '${result.teamName} - salida: ${result.grid} - ${result.laps} vueltas',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(result.time ?? result.status),
                      Text(
                        '${result.points % 1 == 0 ? result.points.toInt() : result.points} pts',
                      ),
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
