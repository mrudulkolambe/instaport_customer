import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/components/past_order_card.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/constants/svgs.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/utils/toast_manager.dart';

class PastOrders extends StatefulWidget {
  const PastOrders({super.key});

  @override
  State<PastOrders> createState() => PastOrdersState();
}

final _storage = GetStorage();

class PastOrdersState extends State<PastOrders> {
  final OrderController orderController = Get.put(OrderController());
  List<Orders> orders = [];
  bool loading = true;
  @override
  void initState() {
    getPastOrders();
    super.initState();
  }

  Future<void> getPastOrders() async {
    final token = await _storage.read("token");
    if (token != null) {
      setState(() {
        loading = true;
      });
      const String url = '$apiUrl/order/customer/orders';
      try {
        final response = await http
            .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
        final data = PastOrderResponse.fromJson(json.decode(response.body));
        // ToastManager.showToast(data.message);
        if (data.error) {
          setState(() {
            loading = false;
          });
        } else {
          setState(() {
            orders = data.orders;
            loading = false;
          });
        }
      } catch (error) {
        print("Error: $error");
        ToastManager.showToast("Error: $error");
      }
    } else {
      ToastManager.showToast("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: CustomAppBar(
          title: "Orders",
          back: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: loading
                ? SizedBox(
                    height: MediaQuery.of(context).size.height - 175,
                    child: const Center(
                      child: SpinKitFadingCircle(color: accentColor, size: 30),
                    ),
                  )
                : orders.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 175,
                        child: Center(
                          child: SvgPicture.string(noDataFoundSVG),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height - 175,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) => PastOrderCard(
                              data: orders[index],
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                            itemCount: orders.length,
                          ),
                        ),
                      ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
