class RiderLocation {
  String id;
  double latitude;
  double longitude;
  String timestamp;

  RiderLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory RiderLocation.fromJson(Map<String, dynamic> json) {
    return RiderLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      id: json['id'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}
