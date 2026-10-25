import 'driver_standing.dart';

/// La clasificación de pilotos de una temporada y si esta ya terminó.
/// Sirve para decidir si el 1.º es "CAMPEÓN" (terminó) o "LÍDER" (en curso).
class StandingsData {
  final List<DriverStanding> standings;
  final bool seasonFinished;

  const StandingsData({required this.standings, required this.seasonFinished});
}
