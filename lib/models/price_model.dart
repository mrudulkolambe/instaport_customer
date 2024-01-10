class PriceManipulationResponse {
  bool error;
  String message;
  PriceManipulation priceManipulation;

  PriceManipulationResponse({
    required this.error,
    required this.message,
    required this.priceManipulation,
  });
  factory PriceManipulationResponse.fromJson(dynamic json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final priceManipulation = PriceManipulation.fromJson(json["priceManipulation"]);
    // final address = json['address'] as String;
    return PriceManipulationResponse(error: error, message: message, priceManipulation: priceManipulation);
  }
}

class PriceManipulation {
  String id;
  int perKilometerCharge;
  int additionalPerKilometerCharge;
  int additionalPickupCharge;
  int securityFeesCharges;
  int baseOrderCharges;
  int instaportCommission;
  int additionalDropCharge;

  PriceManipulation({
    required this.id,
    required this.perKilometerCharge,
    required this.additionalPerKilometerCharge,
    required this.additionalPickupCharge,
    required this.securityFeesCharges,
    required this.baseOrderCharges,
    required this.instaportCommission,
    required this.additionalDropCharge,
  });

  factory PriceManipulation.fromJson(dynamic json) {
    final id = json['_id'] as String;
    final perKilometerCharge = json['per_kilometer_charge'] as int;
    final additionalPerKilometerCharge = json['additional_per_kilometer_charge'] as int;
    final additionalPickupCharge = json['additional_pickup_charge'] as int;
    final securityFeesCharges = json['security_fees_charges'] as int;
    final baseOrderCharges = json['base_order_charges'] as int;
    final instaportCommission = json['instaport_commission'] as int;
    final additionalDropCharge = json['additional_drop_charge'] as int;
    return PriceManipulation(
      id: id,
      perKilometerCharge: perKilometerCharge,
      additionalPerKilometerCharge: additionalPerKilometerCharge,
      additionalPickupCharge: additionalPickupCharge,
      securityFeesCharges: securityFeesCharges,
      baseOrderCharges: baseOrderCharges,
      instaportCommission: instaportCommission,
      additionalDropCharge: additionalDropCharge,
    );
  }
}
