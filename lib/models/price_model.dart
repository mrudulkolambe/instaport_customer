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
    final priceManipulation =
        PriceManipulation.fromJson(json["priceManipulation"]);
    return PriceManipulationResponse(
        error: error, message: message, priceManipulation: priceManipulation);
  }
}

class PriceManipulation {
  String id;
  double perKilometerCharge;
  double additionalPerKilometerCharge;
  double additionalPickupCharge;
  double securityFeesCharges;
  double baseOrderCharges;
  double instaportCommission;
  double additionalDropCharge;
  double withdrawalCharges;
  double cancellationCharges;

  PriceManipulation({
    required this.id,
    required this.perKilometerCharge,
    required this.additionalPerKilometerCharge,
    required this.additionalPickupCharge,
    required this.securityFeesCharges,
    required this.baseOrderCharges,
    required this.instaportCommission,
    required this.additionalDropCharge,
    required this.withdrawalCharges,
    required this.cancellationCharges,
  });

  factory PriceManipulation.fromJson(dynamic json) {
    final id = json['_id'] as String;
    final perKilometerCharge = json['per_kilometer_charge'] + 0.0 as double;
    final additionalPerKilometerCharge =
        json['additional_per_kilometer_charge'] + 0.0 as double;
    final additionalPickupCharge =
        json['additional_pickup_charge'] + 0.0 as double;
    final securityFeesCharges = json['security_fees_charges'] + 0.0 as double;
    final baseOrderCharges = json['base_order_charges'] + 0.0 as double;
    final instaportCommission = json['instaport_commission'] + 0.0 as double;
    final additionalDropCharge = json['additional_drop_charge'] + 0.0 as double;
    final withdrawalCharges = json['withdrawalCharges'] + 0.0 as double;
    final cancellationCharges = json['cancellationCharges'] + 0.0 as double;
    return PriceManipulation(
      id: id,
      perKilometerCharge: perKilometerCharge,
      additionalPerKilometerCharge: additionalPerKilometerCharge,
      additionalPickupCharge: additionalPickupCharge,
      securityFeesCharges: securityFeesCharges,
      baseOrderCharges: baseOrderCharges,
      instaportCommission: instaportCommission,
      additionalDropCharge: additionalDropCharge,
      withdrawalCharges: withdrawalCharges,
      cancellationCharges: cancellationCharges,
    );
  }
}
