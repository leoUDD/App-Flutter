
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/driver_standing.dart';
import '../models/saved_comparison.dart';
import '../services/jolpica_service.dart';
import '../services/saved_comparisons_service.dart';
import '../theme/app_theme.dart';

class SavedComparisonFormScreen extends StatefulWidget {
  const SavedComparisonFormScreen({
    super.key,
    required this.initialSeason,
    this.comparison,
    this.initialDriverAId,
    this.initialDriverBId,
  });

  final int initialSeason;
  final SavedComparison? comparison;
  final String? initialDriverAId;
  final String? initialDriverBId;

  @override
  State<SavedComparisonFormScreen> createState() =>
      _SavedComparisonFormScreenState();
}

class _SavedComparisonFormScreenState
    extends State<SavedComparisonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SavedComparisonsService();
  final _jolpica = JolpicaService();

  late final TextEditingController _titleController;
  late Future<List<DriverStanding>> _driversFuture;

  late int _season;
  String? _driverA;
  String? _driverB;
  bool _saving = false;

  bool get _editing => widget.comparison != null;

  @override
  void initState() {
    super.initState();

    final comparison = widget.comparison;

    _titleController = TextEditingController(
      text: comparison?.title ?? '',
    );

    _season = comparison?.season ?? widget.initialSeason;
    _driverA = comparison?.driverAId ?? widget.initialDriverAId;
    _driverB = comparison?.driverBId ?? widget.initialDriverBId;

    _loadDrivers();
  }

  void _loadDrivers() {
    _driversFuture = _jolpica.getDriverStandings(
      season: '$_season',
    );
  }

  void _changeSeason(int? value) {
    if (value == null || value == _season) return;

    setState(() {
      _season = value;
      _driverA = null;
      _driverB = null;
      _loadDrivers();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_driverA == null || _driverB == null) return;

    setState(() => _saving = true);

    try {
      if (_editing) {
        await _service.update(
          id: widget.comparison!.id,
          title: _titleController.text.trim(),
          season: _season,
          driverAId: _driverA!,
          driverBId: _driverB!,
        );
      } else {
        await _service.create(
          title: _titleController.text.trim(),
          season: _season,
          driverAId: _driverA!,
          driverBId: _driverB!,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) {
        _showMessage('No se pudo guardar: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = [
      for (int year = currentYear; year >= 1950; year--) year,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _editing ? 'Editar comparación' : 'Nueva comparación',
        ),
      ),
      body: FutureBuilder<List<DriverStanding>>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(_loadDrivers);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar carga de pilotos'),
              ),
            );
          }

          final drivers = snapshot.data ?? [];

          if (drivers.length < 2) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(_loadDrivers);
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'No hay suficientes pilotos. Reintentar',
                ),
              ),
            );
          }

          final ids = drivers.map((d) => d.driverId).toSet();

          final selectedA =
              ids.contains(_driverA) ? _driverA : null;
          final selectedB =
              ids.contains(_driverB) ? _driverB : null;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(
                  Icons.compare_arrows,
                  size: 48,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 12),

                Text(
                  _editing
                      ? 'ACTUALIZAR COMPARACIÓN'
                      : 'GUARDAR COMPARACIÓN',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  maxLength: 60,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la comparación',
                    hintText: 'Ej: Hamilton vs Verstappen',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.length < 3) {
                      return 'Escribe al menos 3 caracteres';
                    }

                    if (text.length > 60) {
                      return 'Máximo 60 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  key: ValueKey('season-$_season'),
                  initialValue: _season,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Temporada',
                    border: OutlineInputBorder(),
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year'),
                    );
                  }).toList(),
                  onChanged: _saving ? null : _changeSeason,
                  validator: (value) =>
                      value == null ? 'Selecciona una temporada' : null,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  key: ValueKey('driverA-$_season'),
                  initialValue: selectedA,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Piloto A',
                    border: OutlineInputBorder(),
                  ),
                  items: drivers.map((driver) {
                    return DropdownMenuItem<String>(
                      value: driver.driverId,
                      child: Text(
                        driver.fullName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() => _driverA = value);
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona el primer piloto';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  key: ValueKey('driverB-$_season'),
                  initialValue: selectedB,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Piloto B',
                    border: OutlineInputBorder(),
                  ),
                  items: drivers.map((driver) {
                    return DropdownMenuItem<String>(
                      value: driver.driverId,
                      child: Text(
                        driver.fullName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() => _driverB = value);
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona el segundo piloto';
                    }

                    if (value == _driverA) {
                      return 'Los pilotos deben ser diferentes';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _editing ? 'GUARDAR CAMBIOS' : 'GUARDAR',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
