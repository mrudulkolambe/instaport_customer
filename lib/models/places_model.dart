class PlacesResponse {
  String status;
  List<dynamic> predictions;
  // List<dynamic> candidates;

  PlacesResponse({
    required this.status,
    required this.predictions,
    // required this.candidates,
  });

  factory PlacesResponse.fromJson(dynamic json) {
    final status = json['status'] as String;
    final predictions = json['predictions'] as List<dynamic>;
    return PlacesResponse(status: status, predictions: predictions);
    // return PlacesResponse(status: status, candidates: candidates);
  }
}

class Place {
  final String description;
  final String placeId;

  Place({
    required this.description,
    required this.placeId,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}

class LocationData {
  double latitude;
  double longitude;

  LocationData(
      {required this.latitude, required this.longitude});
  
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['lat'] + 0.0 as double,
      longitude: json['lng']+ 0.0 as double,
    );
  }
}
