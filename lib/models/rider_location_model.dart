class RiderLocation {
  double latitude;
  double longitude;

  RiderLocation({
    required this.latitude,
    required this.longitude,
  });

  factory RiderLocation.fromJson(Map<String, dynamic> json) {
    return RiderLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
