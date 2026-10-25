class RaceResult {
  final String positionText;
  final String driverName;
  final String driverCode;
  final int grid;
  final int laps;
  final String teamName;
  final String? time;
  final String status;
  final double points;

  const RaceResult({
    required this.positionText,
    required this.driverName,
    required this.driverCode,
    required this.grid,
    required this.laps,
    required this.teamName,
    required this.time,
    required this.status,
    required this.points,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    final driver = json['Driver'] as Map<String, dynamic>;
    final constructor = (json['Constructor'] as Map<String, dynamic>?);
    final time = (json['Time'] as Map<String, dynamic>?);
    return RaceResult(
      positionText: (json['positionText'] as String? ?? '-'),
      driverName: '${driver['givenName']} ${driver['familyName']}',
      driverCode: driver['code'] as String? ?? '',
      grid: int.tryParse((json['grid'] as String?) ?? '') ?? 0,
      laps: int.tryParse((json['laps'] as String?) ?? '') ?? 0,
      teamName: (constructor?['name'] as String?) ?? '-',
      time: time?['time'] as String?,
      status: (json['status'] as String? ?? ''),
      points: double.tryParse((json['points'] as String?) ?? '') ?? 0,
    );
  }
}
