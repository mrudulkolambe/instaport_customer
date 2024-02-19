// ignore_for_file: non_constant_identifier_names

import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/rider_model.dart';

class PastOrderResponse {
  bool error;
  String message;
  List<Orders> orders;

  PastOrderResponse({
    required this.error,
    required this.message,
    required this.orders,
  });

  factory PastOrderResponse.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    return PastOrderResponse(
        error: error,
        message: message,
        orders: List.from(json["order"]).map((e) {
          return Orders.fromJson(e);
        }).toList());
  }
}

class OrderResponse {
  bool error;
  String message;
  Orders order;

  OrderResponse({
    required this.error,
    required this.message,
    required this.order,
  });

  factory OrderResponse.fromJson(dynamic json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final order = Orders.fromJson(json['order']);
    return OrderResponse(error: error, message: message, order: order);
  }
}

class Orders {
  Address pickup;
  Address drop;
  List<Address> droplocations;
  String id;
  String delivery_type;
  String parcel_weight;
  String phone_number;
  bool notify_sms;
  bool courier_bag;
  String vehicle;
  String status;
  String payment_method;
  String customer;
  String package;
  int time_stamp;
  int parcel_value;
  Rider? rider;
  List<OrderStatus> orderStatus;
  double amount;
  Orders({
    required this.pickup,
    required this.drop,
    required this.id,
    required this.droplocations,
    required this.delivery_type,
    required this.parcel_weight,
    required this.phone_number,
    required this.notify_sms,
    required this.courier_bag,
    required this.vehicle,
    required this.status,
    required this.payment_method,
    required this.customer,
    required this.package,
    required this.time_stamp,
    required this.parcel_value,
    required this.amount,
    required this.orderStatus,
    this.rider,
  });

  factory Orders.fromJson(dynamic json) {
    final pickup = Address.fromJson(json['pickup']);
    final drop = Address.fromJson(json['drop']);
    final orderStatus = List.from(json["orderStatus"]).map((e) {
      return OrderStatus.fromJson(e);
    }).toList();
    final List<Address> droplocations = json['droplocations'] == null
        ? []
        : List.from(json["droplocations"]).map((e) {
            return Address.fromJson(e);
          }).toList();
    final id = json['_id'] as String;
    final delivery_type = json['delivery_type'] as String;
    final parcel_weight = json['parcel_weight'] as String;
    final phone_number = json['phone_number'] as String;
    final notify_sms = json['notify_sms'] as bool;
    final courier_bag = json['courier_bag'] as bool;
    final vehicle = json['vehicle'] as String;
    final status = json['status'] as String;
    final payment_method = json['payment_method'] as String;
    final customer = json['customer'] as String;
    final package = json['package'] as String;
    final time_stamp = json['time_stamp'] as int;
    final parcel_value = json['parcel_value'];
    final amount = json['amount'] + 0.0;
    final rider = json["rider"] == null ? null : Rider.fromJson(json['rider']);

    return Orders(
      pickup: pickup,
      drop: drop,
      id: id,
      delivery_type: delivery_type,
      parcel_weight: parcel_weight,
      droplocations: droplocations,
      phone_number: phone_number,
      notify_sms: notify_sms,
      courier_bag: courier_bag,
      vehicle: vehicle,
      status: status,
      payment_method: payment_method,
      customer: customer,
      package: package,
      time_stamp: time_stamp,
      parcel_value: parcel_value,
      amount: amount,
      rider: rider,
      orderStatus: orderStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup.toJson(),
      'drop': drop.toJson(),
      'id': id,
      'delivery_type': delivery_type,
      'parcel_weight': parcel_weight,
      'phone_number': phone_number,
      'notify_sms': notify_sms,
      'courier_bag': courier_bag,
      'vehicle': vehicle,
      'status': status,
      'payment_method': payment_method,
      'customer': customer,
      'package': package,
      'time_stamp': time_stamp,
      'parcel_value': parcel_value,
      'amount': amount,
      'rider': rider,
      'orderStatus': orderStatus,
    };
  }
}

class OrderStatus {
  int timestamp;
  String message;
  String? image;
  String? key;

  OrderStatus({
    required this.timestamp,
    required this.message,
    this.image,
    this.key,
  });

  factory OrderStatus.fromJson(dynamic json) {
    final timestamp = json['timestamp'] as int;
    final message = json['message'] as String;
    final image = json['image'];
    final key = json['key'];
    return OrderStatus(
      timestamp: timestamp,
      message: message,
      image: image,
      key: key,
    );
  }
}
