// ignore_for_file: non_constant_identifier_names

class Address {
  String text;
  double latitude;
  double longitude;
  String building_and_flat;
  String floor_and_wing;
  String instructions;
  String phone_number;
  String address;
  String name;
  String? fromtime;
  String? totime;
  String? date;
  String key;

  Address({
    required this.text,
    required this.latitude,
    required this.longitude,
    required this.building_and_flat,
    required this.floor_and_wing,
    required this.instructions,
    required this.phone_number,
    required this.address,
    required this.name,
    required this.key,
    this.date,
    this.fromtime,
    this.totime,
  });

  factory Address.fromJson(dynamic json) {
    final text = json['text'] as String;
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;
    final building_and_flat = json['building_and_flat'] as String;
    final floor_and_wing = json['floor_and_wing'] as String;
    final instructions = json['instructions'] as String;
    final key = json['key'] as String;
    final phone_number = json['phone_number'] as String;
    final address = json['address'] as String;
    final name = json['name'] as String;
    final fromtime = json['fromtime'];
    final date = json['date'];
    final totime = json['totime'];
    // final address = json['address'] as String;
    return Address(
      text: text,
      latitude: latitude,
      longitude: longitude,
      building_and_flat: building_and_flat,
      key: key,
      floor_and_wing: floor_and_wing,
      instructions: instructions,
      phone_number: phone_number,
      address: address,
      name: name,
      fromtime: fromtime,
      totime: totime,
      date: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'latitude': latitude,
      'longitude': longitude,
      'key': key,
      'building_and_flat': building_and_flat,
      'floor_and_wing': floor_and_wing,
      'instructions': instructions,
      'phone_number': phone_number,
      'address': address,
      'name': name,
      'date': date,
      'totime': totime,
      'fromtime': fromtime,
    };
  }
}

class AddressObject {
  Address address;
  String instructions;
  String phone_number;

  AddressObject({
    required this.address,
    required this.instructions,
    required this.phone_number,
  });

  factory AddressObject.fromJson(dynamic json) {
    final address = Address.fromJson(json['address']);
    final instructions = json['instructions'] as String;
    final phone_number = json['phone_number'] as String;
    return AddressObject(
      address: address,
      instructions: instructions,
      phone_number: phone_number,
    );
  }
}
