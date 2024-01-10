// ignore_for_file: empty_catches, avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/order_model.dart';

  final storage = GetStorage();
Future<void> getPastOrders() async {
  final OrderController orderController = Get.put(OrderController());
  final token = await storage.read("token");
  if (token != null) {
    const String url = '$apiUrl/order/customer/orders';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      final data = PastOrderResponse.fromJson(json.decode(response.body));
      orderController.updateOrders(data.orders);
      if (data.error) {
      } else {}
    } catch (error) {}
  } else {
    print("error");
  }
}