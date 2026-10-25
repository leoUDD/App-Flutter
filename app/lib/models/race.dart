class Race {
  final int round;
  final int season;
  final String name;
  final String circuitName;
  final String locality;
  final String country;
  final DateTime? date;
  final bool hasTime;

  const Race({
    required this.round,
    required this.season,
    required this.name,
    required this.circuitName,
    required this.locality,
    required this.country,
    required this.date,
    required this.hasTime,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    final circuit = json['Circuit'] as Map<String, dynamic>;
    final location = circuit['Location'] as Map<String, dynamic>;
    final dateStr = json['date'] as String?;
    final timeStr = json['time'] as String?;
    return Race(
      round: int.parse(json['round'] as String),
      season: int.parse(json['season'] as String),
      name: json['raceName'] as String,
      circuitName: circuit['circuitName'] as String,
      locality: location['locality'] as String,
      country: location['country'] as String,
      date: dateStr == null
          ? null
          : DateTime.tryParse(
              timeStr == null ? dateStr : '${dateStr}T$timeStr',
            ),
      hasTime: timeStr != null,
    );
  }
}
