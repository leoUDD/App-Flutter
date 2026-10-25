
class DriverSeasonStats {
  const DriverSeasonStats({
    required this.races,
    required this.wins,
    required this.podiums,
  });

  final int races;
  final int wins;
  final int podiums;

  // Porcentaje de carreras ganadas.
  double get winRate {
    if (races == 0) return 0;
    return (wins / races) * 100;
  }

  // Porcentaje de carreras terminadas en el podio.
  double get podiumRate {
    if (races == 0) return 0;
    return (podiums / races) * 100;
  }
}
