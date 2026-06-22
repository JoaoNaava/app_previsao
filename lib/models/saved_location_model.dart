class SavedLocationModel {
  final double lat;
  final double lon;
  final String cityName;
  final DateTime updatedAt;

  const SavedLocationModel({
    required this.lat,
    required this.lon,
    required this.cityName,
    required this.updatedAt,
  });

  factory SavedLocationModel.fromMap(Map<String, dynamic> map) {
    return SavedLocationModel(
      lat: map['lat'] as double,
      lon: map['lon'] as double,
      cityName: map['city_name'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lon': lon,
        'city_name': cityName,
        'updated_at': updatedAt.toIso8601String(),
      };

  // ~1 km threshold (0.01° ≈ 1.1 km)
  bool isDifferentFrom(double newLat, double newLon) {
    return (lat - newLat).abs() > 0.01 || (lon - newLon).abs() > 0.01;
  }
}
