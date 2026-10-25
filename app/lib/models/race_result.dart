class RaceResult {
  final String positionText;
  final String givenName;
  final String familyName;
  final String driverCode;
  final int grid;
  final int laps;
  final String teamId;
  final String teamName;
  final String? time;
  final String status;
  final double points;

  const RaceResult({
    required this.positionText,
    required this.givenName,
    required this.familyName,
    required this.driverCode,
    required this.grid,
    required this.laps,
    required this.teamId,
    required this.teamName,
    required this.time,
    required this.status,
    required this.points,
  });

  String get driverName => '$givenName $familyName';

  /// Primera letra del nombre y del apellido, en mayúscula (p. ej. "MV").
  String get initials {
    final first = givenName.isNotEmpty ? givenName[0] : '';
    final last = familyName.isNotEmpty ? familyName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get pointsLabel => points % 1 == 0 ? '${points.toInt()}' : '$points';

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    final driver = json['Driver'] as Map<String, dynamic>;
    final constructor = json['Constructor'] as Map<String, dynamic>?;
    final time = json['Time'] as Map<String, dynamic>?;
    return RaceResult(
      positionText: (json['positionText'] as String?) ?? '-',
      givenName: (driver['givenName'] as String?) ?? '',
      familyName: (driver['familyName'] as String?) ?? '',
      driverCode: (driver['code'] as String?) ?? '',
      grid: int.tryParse((json['grid'] as String?) ?? '') ?? 0,
      laps: int.tryParse((json['laps'] as String?) ?? '') ?? 0,
      teamId: (constructor?['constructorId'] as String?) ?? '',
      teamName: (constructor?['name'] as String?) ?? '-',
      time: time?['time'] as String?,
      status: (json['status'] as String?) ?? '',
      points: double.tryParse((json['points'] as String?) ?? '') ?? 0,
    );
  }
}
