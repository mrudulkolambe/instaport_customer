// ignore_for_file: non_constant_identifier_names

class Address {
  String text;
  double latitude;
  double longitude;
  String building;
  String floor;
  String flatno;
  String instructions;
  String phone_number;
  String address;
  String zipcode;

  Address({
    required this.text,
    required this.latitude,
    required this.longitude,
    required this.building,
    required this.floor,
    required this.flatno,
    required this.instructions,
    required this.phone_number,
    required this.address,
    required this.zipcode,
  });

  factory Address.fromJson(dynamic json) {
    final text = json['text'] as String;
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;
    final building = json['building'] as String;
    final floor = json['floor'] as String;
    final flatno = json['flatno'] as String;
    final instructions = json['instructions'] as String;
    final phone_number = json['phone_number'] as String;
    final address = json['address'] as String;
    final zipcode = json['zipcode'] as String;
    // final address = json['address'] as String;
    return Address(
      text: text,
      latitude: latitude,
      longitude: longitude,
      building: building,
      floor: floor,
      flatno: flatno,
      instructions: instructions,
      phone_number: phone_number,
      address: address,
      zipcode: zipcode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'latitude': latitude,
      'longitude': longitude,
      'building': building,
      'flatno': flatno,
      'floor': floor,
      'instructions': instructions,
      'phone_number': phone_number,
      'address': address,
      'zipcode': zipcode,
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
        phone_number: phone_number);
  }
}
