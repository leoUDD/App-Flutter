import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/saved_comparison.dart';

class SavedComparisonsService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;

    if (id == null) {
      throw StateError('Debes iniciar sesión');
    }

    return id;
  }

  void _validate({
    required String title,
    required int season,
    required String driverAId,
    required String driverBId,
  }) {
    if (title.trim().length < 3 || title.trim().length > 60) {
      throw ArgumentError('El nombre debe tener entre 3 y 60 caracteres');
    }

    if (season < 1950 || season > 2100) {
      throw ArgumentError('Temporada inválida');
    }

    if (driverAId.isEmpty || driverBId.isEmpty || driverAId == driverBId) {
      throw ArgumentError('Selecciona dos pilotos diferentes');
    }
  }

  // READ: obtener las comparaciones del usuario.
  Future<List<SavedComparison>> getAll() async {
    final userId = _userId;

    final rows = await _client
        .from('saved_comparisons')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.map((row) => SavedComparison.fromJson(row)).toList();
  }

  // CREATE: guardar una nueva comparación.
  Future<SavedComparison> create({
    required String title,
    required int season,
    required String driverAId,
    required String driverBId,
  }) async {
    _validate(
      title: title,
      season: season,
      driverAId: driverAId,
      driverBId: driverBId,
    );

    final userId = _userId;

    final row = await _client
        .from('saved_comparisons')
        .insert({
          'user_id': userId,
          'title': title.trim(),
          'season': season,
          'driver_a_id': driverAId,
          'driver_b_id': driverBId,
        })
        .select()
        .single();

    return SavedComparison.fromJson(row);
  }

  // UPDATE: editar una comparación existente.
  Future<SavedComparison> update({
    required String id,
    required String title,
    required int season,
    required String driverAId,
    required String driverBId,
  }) async {
    _validate(
      title: title,
      season: season,
      driverAId: driverAId,
      driverBId: driverBId,
    );

    final userId = _userId;

    final row = await _client
        .from('saved_comparisons')
        .update({
          'title': title.trim(),
          'season': season,
          'driver_a_id': driverAId,
          'driver_b_id': driverBId,
        })
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .maybeSingle();

    if (row == null) {
      throw StateError('Comparación no encontrada');
    }

    return SavedComparison.fromJson(row);
  }

  // DELETE: eliminar una comparación.
  Future<void> delete(String id) async {
    final userId = _userId;

    final rows = await _client
        .from('saved_comparisons')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .select('id');

    if (rows.isEmpty) {
      throw StateError('Comparación no encontrada');
    }
  }
}
