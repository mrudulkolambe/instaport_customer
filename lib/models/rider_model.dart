// ignore_for_file: non_constant_identifier_names

class Rider {
  String id;
  String fullname;
  String mobileno;
  String role;
  String age;
  String image;
  double wallet_amount;
  ReferenceContact? referenceContact1;
  ReferenceContact? referenceContact2;
  String? address;
  String? aadharcard;
  String? pancard;
  String? vehicle;
  String? ifsc;
  String? accno;
  String? accname;
  String? drivinglicense;

  Rider({
    required this.id,
    required this.fullname,
    required this.mobileno,
    required this.role,
    required this.age,
    required this.image,
    required this.wallet_amount,
    this.address,
    this.aadharcard,
    this.pancard,
    this.vehicle,
    this.ifsc,
    this.accname,
    this.accno,
    this.referenceContact1,
    this.referenceContact2,
    this.drivinglicense,
  });

  factory Rider.fromJson(dynamic json) {
    print("Rider wallet: ${json["wallet_amount"]}");
    final id = json['_id'] as String;
    final fullname = json['fullname'] as String;
    final mobileno = json['mobileno'] as String;
    final role = json['role'] as String;
    final age = json['age'] as String;
    final image = json["image"] as String;
    final wallet_amount = json["wallet_amount"] + 0.0 as double;
    final address = json["address"];
    final aadharcard = json["aadhar_number"];
    final pancard = json["pan_number"];
    final accno = json["acc_no"];
    final accIFSC = json["acc_ifsc"];
    final accHolder = json["acc_holder"];
    final drivinglicense = json["drivinglicense"];
    final refCon1 = json["reference_contact_1"] == null
        ? null
        : ReferenceContact.fromJson(json["reference_contact_1"]);
    final refCon2 = json["reference_contact_2"] == null
        ? null
        : ReferenceContact.fromJson(json["reference_contact_2"]);

    return Rider(
      id: id,
      fullname: fullname,
      mobileno: mobileno,
      role: role,
      age: age,
      image: image,
      wallet_amount: wallet_amount,
      address: address,
      aadharcard: aadharcard,
      pancard: pancard,
      accname: accHolder,
      accno: accno,
      ifsc: accIFSC,
      referenceContact1: refCon1,
      referenceContact2: refCon2,
      drivinglicense: drivinglicense,
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

class ReferenceContact {
  String name;
  String relation;
  String number;

  ReferenceContact({
    required this.name,
    required this.relation,
    required this.number,
  });

  factory ReferenceContact.fromJson(dynamic json) {
    final name = json['name'] as String;
    final relation = json['relation'] as String;
    final number = json['phonenumber'] as String;
    return ReferenceContact(
      name: name,
      relation: relation,
      number: number,
    );
  }
}
