class CouponResponse {
  bool error;
  String message;
  dynamic coupon;

  CouponResponse({
    required this.error,
    required this.message,
    required this.coupon,
  });

  factory CouponResponse.fromJson(dynamic json) {
    final error = json["error"] as bool;
    final message = json['message'] as String;
    var coupon;
    if (json["coupon"] == null) {
       coupon = json['coupon'];
    }else{
       coupon = Coupon.fromJson(json['coupon']);
    }
    return CouponResponse(
      error: error,
      message: message,
      coupon: coupon,
    );
  }
}

class Coupon {
  String id;
  String code;
  int timestamp;
  bool disabled;
  double percentOff;
  double maxAmount;
  double minimumCartValue;

  Coupon({
    required this.id,
    required this.code,
    required this.timestamp,
    required this.disabled,
    required this.percentOff,
    required this.maxAmount,
    required this.minimumCartValue,
  });

  factory Coupon.fromJson(dynamic json) {
    final id = json["_id"] as String;
    final code = json["code"] as String;
    final timestamp = json["timestamp"] as int;
    final disabled = json['disabled'] as bool;
    final percentOff = json['percentOff'] + 0.0 as double;
    final maxAmount = json['maxAmount'] + 0.0 as double;
    final minimumCartValue = json['minimumCartValue'] + 0.0 as double;
    return Coupon(
      id: id,
      code: code,
      timestamp: timestamp,
      disabled: disabled,
      percentOff: percentOff,
      maxAmount: maxAmount,
      minimumCartValue: minimumCartValue,
    );
  }
}
