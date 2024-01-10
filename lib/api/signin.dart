import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:instaport_customer/screens/home.dart';

final _storage = GetStorage();

Future<void> loginCustomer({
  required String username,
  required String password,
}) async {
  const String url = '$apiUrl/user/signin';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobileno': username,
        'password': password,
      }),
    );
    final data = SignInResponse.fromJson(json.decode(response.body));
    if (data.error) {
    } else {
      _storage.write("token", data.token);
      Get.to(() => const Home());
    }
    // ignore: empty_catches
  } catch (error) {
  }
}
