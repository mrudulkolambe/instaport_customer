import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/components/getdialog.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/main.dart';

final _storage = GetStorage();

void walletPayment(OrderController orderController, double amount, double discount) async {
  final token = await _storage.read("token");
  var headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json'
  };
  var request = http.Request(
      'POST', Uri.parse('$apiUrl/customer-transactions/wallet-order-payment'));
      print(orderController.currentorder.package);
      print(orderController.currentorder.phone_number);
  request.body = json.encode({
    "pickup": orderController.currentorder.pickup.toJson(),
    "drop": orderController.currentorder.drop.toJson(),
    "delivery_type": orderController.currentorder.delivery_type,
    "parcel_weight": orderController.currentorder.parcel_weight,
    "phone_number": orderController.currentorder.phone_number,
    "vehicle": orderController.currentorder.vehicle,
    "status": "new",
    "payment_method": "wallet",
    "package": orderController.currentorder.package,
    "parcel_value": orderController.currentorder.parcel_value,
    "amount": amount - discount,
  });
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  if (response.statusCode == 200) {
    var data = jsonDecode(await response.stream.bytesToString());
    if (data["error"] == false) {
      Get.dialog(const OrderSuccessDialog());
    } else {
      print(data["message"]);
    }
  } else {
    // print(response.reasonPhrase);
  }
}
