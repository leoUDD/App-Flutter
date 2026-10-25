import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_comparison.dart';
import '../providers/season_provider.dart';
import '../services/saved_comparisons_service.dart';
import '../theme/app_theme.dart';
import 'comparison_screen.dart';
import 'saved_comparison_form_screen.dart';

class SavedComparisonsScreen extends StatefulWidget {
  const SavedComparisonsScreen({super.key});

  @override
  State<SavedComparisonsScreen> createState() => _SavedComparisonsScreenState();
}

class _SavedComparisonsScreenState extends State<SavedComparisonsScreen> {
  final _service = SavedComparisonsService();
  late Future<List<SavedComparison>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAll();
  }

  void _reload() {
    setState(() {
      _future = _service.getAll();
    });
  }

  void _openComparison(SavedComparison comparison) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ComparisonScreen(
          initialSeason: comparison.season,
          initialDriverId: comparison.driverAId,
          initialDriverBId: comparison.driverBId,
          showBackButton: true,
        ),
      ),
    );
  }

  Future<void> _openForm({SavedComparison? comparison}) async {
    final season = comparison?.season ?? context.read<SeasonProvider>().season;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SavedComparisonFormScreen(
          initialSeason: season,
          comparison: comparison,
        ),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comparación guardada correctamente')),
      );
    }
  }

  Future<void> _delete(SavedComparison comparison) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar comparación'),
        content: Text('¿Eliminar "${comparison.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.delete(comparison.id);
      if (!mounted) return;

      _reload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Comparación eliminada')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }

  String _driverName(String id) {
    return id
        .split('_')
        .map((part) {
          if (part.isEmpty) return '';
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis comparaciones'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: FutureBuilder<List<SavedComparison>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Error de carga. Reintentar'),
              ),
            );
          }

          final comparisons = snapshot.data ?? [];

          if (comparisons.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmarks_outlined,
                      size: 56,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Todavía no tienes comparaciones guardadas',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presiona Nueva para crear la primera.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: comparisons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = comparisons[index];

              return Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Temporada ${item.season}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_driverName(item.driverAId)} '
                        'VS '
                        '${_driverName(item.driverBId)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      // NUEVO: ver gráficos de esta comparación guardada.
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openComparison(item),
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('Ver comparación'),
                        ),
                      ),

                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _openForm(comparison: item),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                          ),
                          TextButton.icon(
                            onPressed: () => _delete(item),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
