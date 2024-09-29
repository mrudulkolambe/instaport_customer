// ignore_for_file: non_constant_identifier_names

class Rider {
  String id;
  String fullname;
  String mobileno;
  String role;
  String age;
  String image;

  Rider({
    required this.id,
    required this.fullname,
    required this.mobileno,
    required this.role,
    required this.age,
    required this.image,
  });

  factory Rider.fromJson(dynamic json) {
    print(json["image"]);
    final id = json['_id'] as String;
    final fullname = json['fullname'] as String;
    final mobileno = json['mobileno'] as String;
    final role = json['role'] as String;
    final age = json['age'] as String;
    final image = json["image"] == null ? "" : json["image"]["url"] as String;

    return Rider(
      id: id,
      fullname: fullname,
      mobileno: mobileno,
      role: role,
      age: age,
      image: image,
    );
  }
}

class RiderDataResponse {
  bool error;
  String message;
  Rider rider;

  RiderDataResponse({
    required this.error,
    required this.message,
    required this.rider,
  });

  factory RiderDataResponse.fromJson(dynamic json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final rider = Rider.fromJson(json['rider']);
    return RiderDataResponse(
      error: error,
      message: message,
      rider: rider,
    );
  }
}