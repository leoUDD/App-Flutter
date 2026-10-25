class SavedComparison {
  const SavedComparison({
    required this.id,
    required this.title,
    required this.season,
    required this.driverAId,
    required this.driverBId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int season;
  final String driverAId;
  final String driverBId;
  final DateTime createdAt;

  factory SavedComparison.fromJson(Map<String, dynamic> json) {
    return SavedComparison(
      id: json['id'] as String,
      title: json['title'] as String,
      season: json['season'] as int,
      driverAId: json['driver_a_id'] as String,
      driverBId: json['driver_b_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
