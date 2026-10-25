import 'race.dart';

/// Ganador de una carrera, tal como se muestra en el calendario ("C. Leclerc").
class RaceWinner {
  final String name;
  final String teamId;

  const RaceWinner({required this.name, required this.teamId});

  /// [json] es una fila de `Results` (la del primer puesto).
  factory RaceWinner.fromJson(Map<String, dynamic> json) {
    final driver = json['Driver'] as Map<String, dynamic>;
    final given = (driver['givenName'] as String?) ?? '';
    final family = (driver['familyName'] as String?) ?? '';
    final constructor = json['Constructor'] as Map<String, dynamic>?;
    return RaceWinner(
      name: given.isEmpty ? family : '${given[0]}. $family',
      teamId: (constructor?['constructorId'] as String?) ?? '',
    );
  }
}

/// Una carrera del calendario junto con su ganador (si ya se disputó).
class CalendarEntry {
  final Race race;
  final RaceWinner? winner;

  const CalendarEntry({required this.race, required this.winner});

  bool get played => winner != null;
}
