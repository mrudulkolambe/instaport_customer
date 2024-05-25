import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/getdialog.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/getsnackbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/coupon_model.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:instaport_customer/models/price_model.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/screens/new_order.dart';
import 'package:instaport_customer/screens/order_payment/billdesk.dart';
import 'package:instaport_customer/services/location_service.dart';
import 'package:instaport_customer/services/uppercase_textfield_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/utils/toast_manager.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

final _storage = GetStorage();

class _PaymentFormState extends State<PaymentForm> {
  OrderController orderController = Get.put(OrderController());
  AddressController addressController = Get.put(AddressController());
  UserController userController = Get.put(UserController());
  TextEditingController couponController = TextEditingController();
  double commission = 0;
  bool fetchLoading = true;
  double amount = 0;
  int paymentindex = 0;
  bool showpg = false;
  InAppWebViewController? webView;
  double discount = 0.0;
  Address? codAddress;
  User? customer;
  List<double> distances = [];

  void handlePreFetch(double srclat, double srclng, double destlat,
      double destlng, List<Address> droplocations) async {
    var token = await _storage.read("token");
    double totalDistance = 0;
    double totalAmount = 0;
    var response = await http.get(Uri.parse("$apiUrl/price/get"));
    final userResponse = await http.get(Uri.parse('$apiUrl/user'),
        headers: {'Authorization': 'Bearer $token'});
    final userData = UserDataResponse.fromJson(jsonDecode(userResponse.body));
    userController.updateUser(userData.user);
    setState(() {
      customer = userData.user;
    });
    final data = PriceManipulationResponse.fromJson(jsonDecode(response.body));
    if (srclat == 0.0 && srclng == 0.0 && destlat == 0.0 && destlng == 0.0) {
      return;
    } else {
      setState(() {
        commission = data.priceManipulation.instaportCommission;
        fetchLoading = true;
      });
      var distanceMain = await LocationService()
          .fetchDistance(srclat, srclng, destlat, destlng);
      totalDistance = (distanceMain.rows[0].elements[0].distance.value / 1000);
      totalAmount = (distanceMain.rows[0].elements[0].distance.value / 1000) *
          data.priceManipulation.perKilometerCharge;
      distances.add(distanceMain.rows[0].elements[0].distance.value / 1000);
      if (droplocations.isNotEmpty) {
        for (int i = 0; i < droplocations.length; i++) {
          double srcLat, srcLng, destLat, destLng;
          if (i == 0) {
            srcLat = destlat;
            srcLng = destlng;
            destLat = droplocations[i].latitude;
            destLng = droplocations[i].longitude;
          } else {
            srcLat = droplocations[i - 1].latitude;
            srcLng = droplocations[i - 1].longitude;
            destLat = droplocations[i].latitude;
            destLng = droplocations[i].longitude;
          }
          var locationData = await LocationService()
              .fetchDistance(srcLat, srcLng, destLat, destLng);
          distances.add(locationData.rows[0].elements[0].distance.value / 1000);
          totalDistance +=
              locationData.rows[0].elements[0].distance.value / 1000;
          totalAmount +=
              (locationData.rows[0].elements[0].distance.value / 1000) *
                  data.priceManipulation.additionalPerKilometerCharge;
        }
      }
    }
    setState(() {
      final OrderController orderController = Get.find();
      if (totalDistance <= 1.0) {
        var finalAmount =
            orderController.currentorder.parcel_weight == items[0] ||
                    orderController.currentorder.parcel_weight == items[1]
                ? data.priceManipulation.baseOrderCharges
                : orderController.currentorder.parcel_weight == items[2]
                    ? data.priceManipulation.baseOrderCharges + 50
                    : orderController.currentorder.parcel_weight == items[3]
                        ? data.priceManipulation.baseOrderCharges + 100
                        : data.priceManipulation.baseOrderCharges + 150;
        amount = finalAmount;
      } else {
        var finalAmount =
            orderController.currentorder.parcel_weight == items[0] ||
                    orderController.currentorder.parcel_weight == items[1]
                ? totalAmount + data.priceManipulation.baseOrderCharges
                : orderController.currentorder.parcel_weight == items[2]
                    ? totalAmount + 50 + data.priceManipulation.baseOrderCharges
                    : orderController.currentorder.parcel_weight == items[3]
                        ? totalAmount +
                            100 +
                            data.priceManipulation.baseOrderCharges
                        : totalAmount +
                            150 +
                            data.priceManipulation.baseOrderCharges;
        amount = finalAmount;
      }
      print(distances);
      fetchLoading = false;
    });
  }

  void _setupJavaScriptHandler() {
    if (webView != null) {
      webView!.addJavaScriptHandler(
        handlerName: 'callFlutterFunction',
        callback: (args) {
          _performActionInFlutter();
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      fetchLoading = true;
    });
    handlePreFetch(
        orderController.currentorder.pickup.latitude,
        orderController.currentorder.pickup.longitude,
        orderController.currentorder.drop.latitude,
        orderController.currentorder.drop.longitude,
        addressController.droplocations);
  }

  void newClick() async {
    if (couponController.text.isNotEmpty) {
      var response =
          await http.get(Uri.parse("$apiUrl/coupons/${couponController.text}"));
      var couponData = CouponResponse.fromJson(jsonDecode(response.body));
      if (couponData.error) {
        GetSnackbar.info(couponData.message);
        couponController.text = '';
        discount = 0.0;
      } else {
        if (couponData.coupon.minimumCartValue > amount) {
          GetSnackbar.info(
              "Minimum Cart value should be Rs.${couponData.coupon.minimumCartValue}");
          couponController.text = "";
        } else {
          var checkDiscount = amount * (couponData.coupon.percentOff / 100);
          if (checkDiscount >= couponData.coupon.maxAmount) {
            discount = couponData.coupon.maxAmount;
          } else {
            discount = checkDiscount;
          }
        }
      }
    }
    setState(() {});
  }

  void handleClick() async {
    final token = await _storage.read("token");
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (paymentindex == 1) {
      final token = await _storage.read("token");
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST',
          Uri.parse('$apiUrl/customer-transactions/wallet-order-payment'));
      request.body = json.encode({
        "pickup": orderController.currentorder.pickup.toJson(),
        "drop": orderController.currentorder.drop.toJson(),
        "delivery_type": orderController.currentorder.delivery_type,
        "parcel_weight": orderController.currentorder.parcel_weight,
        "phone_number": orderController.currentorder.phone_number,
        "distances": distances,
        "vehicle": orderController.currentorder.vehicle,
        "status": "new",
        "payment_method": "wallet",
        "package": orderController.currentorder.package,
        "parcel_value": orderController.currentorder.parcel_value,
        "amount": amount - discount,
        "commission": commission,
        'droplocations': addressController.droplocations,
        'time_stamp': timestamp,
        'timer': 0,
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = jsonDecode(await response.stream.bytesToString());
        var orderData = OrderResponse.fromJson(data);
        if (orderData.error == false) {
          Get.dialog(const OrderSuccessDialog(), barrierDismissible: false);
          DatabaseReference ref =
              FirebaseDatabase.instance.ref("orders/${orderData.order.id}");
          await ref.set({"order": data["order"], "modified": ""});
          orderController.resetFields();
          addressController.resetfields();
        } else {
          print(data["message"]);
        }
      } else {
        // print(response.reasonPhrase);
      }
    } else if (paymentindex == 2) {
      // TODO: COD
      if (codAddress == null) {
        ToastManager.showToast("Please choose the payment address");
      } else {
        var request = http.Request('POST', Uri.parse('$apiUrl/order/create'));
        request.body = json.encode({
          "pickup": orderController.currentorder.pickup.toJson(),
          "drop": orderController.currentorder.drop.toJson(),
          "delivery_type": orderController.currentorder.delivery_type,
          "parcel_weight": orderController.currentorder.parcel_weight,
          "phone_number": orderController.currentorder.phone_number,
          "vehicle": orderController.currentorder.vehicle,
          "distances": distances,
          "status": "new",
          "payment_method": "cod",
          "package": orderController.currentorder.package,
          "parcel_value": orderController.currentorder.parcel_value,
          "amount": amount,
          "payment_address": codAddress,
          "commission": commission,
          'droplocations': addressController.droplocations,
          'time_stamp': timestamp,
          'timer': 0,
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          var data = jsonDecode(await response.stream.bytesToString());
          var orderData = OrderResponse.fromJson(data);
          if (orderData.error == false) {
            Get.dialog(const OrderSuccessDialog(), barrierDismissible: false);
            DatabaseReference ref =
                FirebaseDatabase.instance.ref("orders/${orderData.order.id}");
            await ref.set({"order": data["order"], "modified": ""});
            orderController.resetFields();
            addressController.resetfields();
          }
        } else {
          print(response.reasonPhrase);
        }
      }
    } else if (paymentindex == 0) {
      // TODO: ONLINE

      var request = http.Request('POST', Uri.parse('$apiUrl/order/create'));
      request.body = json.encode({
        "pickup": orderController.currentorder.pickup.toJson(),
        "drop": orderController.currentorder.drop.toJson(),
        "delivery_type": orderController.currentorder.delivery_type,
        "parcel_weight": orderController.currentorder.parcel_weight,
        "phone_number": orderController.currentorder.phone_number,
        "vehicle": orderController.currentorder.vehicle,
        "distances": distances,
        "status": "unpaid",
        "payment_method": "online",
        "package": orderController.currentorder.package,
        "parcel_value": orderController.currentorder.parcel_value,
        "amount": amount,
        "payment_address": codAddress,
        "commission": commission,
        'droplocations': addressController.droplocations,
        'time_stamp': timestamp,
        'timer': 0,
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = jsonDecode(await response.stream.bytesToString());
        var orderData = OrderResponse.fromJson(data);
        if (orderData.error == false) {
          DatabaseReference ref =
              FirebaseDatabase.instance.ref("orders/${orderData.order.id}");
          await ref.set({"order": data["order"], "modified": ""});
          // Get.dialog(const OrderSuccessDialog(), barrierDismissible: false);
          // orderController.resetFields();
          // addressController.resetfields();
          print("https://instaport-transactions.vercel.app/order.html?token=$token&order=${orderData.order.id}&amount=${orderData.order.amount}");
          Get.to(() => BillDeskPayment(url: "https://instaport-transactions.vercel.app/order.html?token=$token&order=${orderData.order.id}&amount=${orderData.order.amount}", order: orderData.order,));
        }
      } else {
        print(response.reasonPhrase);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: CustomAppBar(
          title: "Payment Details",
          back: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: fetchLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: accentColor,
                ),
              )
            : GetBuilder<OrderController>(
                init: OrderController(),
                builder: (ordercontroller) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  "Select payment:",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                paymentindex = 0;
                              }),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: paymentindex == 0
                                        ? accentColor
                                        : Colors.black12,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4F000000),
                                      blurRadius: 18,
                                      offset: Offset(2, 4),
                                      spreadRadius: -15,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 3.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                    "Online",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GetBuilder<UserController>(
                                init: UserController(),
                                builder: (controller) {
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      if (userController.user.wallet > amount) {
                                        paymentindex = 1;
                                      }
                                    }),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: controller.user.wallet > amount
                                            ? Colors.white
                                            : Colors.black12,
                                        border: Border.all(
                                          color: paymentindex == 1
                                              ? accentColor
                                              : Colors.black12,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          // BoxShadow(
                                          //   color: Color(0x4F000000),
                                          //   blurRadius: 18,
                                          //   offset: Offset(2, 4),
                                          //   spreadRadius: -10,
                                          // )
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 12.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 3.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Wallet",
                                                style: GoogleFonts.poppins(
                                                  color: customer != null &&
                                                          customer!.wallet >
                                                              amount
                                                      ? Colors.black
                                                      : Colors.black38,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "Rs.${customer != null ? customer!.wallet.toPrecision(1).toString() : 0}",
                                                style: GoogleFonts.poppins(
                                                  color: customer != null &&
                                                          customer!.wallet >
                                                              amount
                                                      ? Colors.black
                                                      : Colors.red,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                paymentindex = 2;
                              }),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: paymentindex == 2
                                        ? accentColor
                                        : Colors.black12,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4F000000),
                                      blurRadius: 18,
                                      offset: Offset(2, 4),
                                      spreadRadius: -15,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 3.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Cash on Delivery",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (paymentindex == 2)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Select Payment Address: ",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            if (paymentindex == 2)
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        codAddress =
                                            ordercontroller.currentorder.pickup;
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: codAddress != null &&
                                                  codAddress!.key ==
                                                      ordercontroller
                                                          .currentorder
                                                          .pickup
                                                          .key
                                              ? accentColor
                                              : Colors.black12,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x4F000000),
                                            blurRadius: 18,
                                            offset: Offset(2, 4),
                                            spreadRadius: -15,
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 15.0,
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            ordercontroller
                                                .currentorder.pickup.address,
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        codAddress =
                                            ordercontroller.currentorder.drop;
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: codAddress != null &&
                                                  codAddress!.key ==
                                                      ordercontroller
                                                          .currentorder.drop.key
                                              ? accentColor
                                              : Colors.black12,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x4F000000),
                                            blurRadius: 18,
                                            offset: Offset(2, 4),
                                            spreadRadius: -15,
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 15.0,
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            ordercontroller
                                                .currentorder.drop.address,
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...addressController.droplocations
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  codAddress = e.value;
                                                });
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: codAddress != null &&
                                                            codAddress!.key ==
                                                                e.value.key
                                                        ? accentColor
                                                        : Colors.black12,
                                                    width: 2,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0x4F000000),
                                                      blurRadius: 18,
                                                      offset: Offset(2, 4),
                                                      spreadRadius: -15,
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 15.0,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      e.value.address,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            if (paymentindex == 2)
                              const SizedBox(
                                height: 20,
                              ),
                            Row(
                              children: [
                                Text(
                                  "Apply Your Coupon",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width - 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: couponController,
                                      keyboardType: TextInputType.text,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      inputFormatters: [
                                        UpperCaseTextFormatter()
                                      ],
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Enter the coupon code",
                                        hintStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black38),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 15,
                                          horizontal: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: newClick,
                                      child: Text(
                                        "Apply",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Fare:",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Rs. ${amount.toPrecision(1)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Discount Amount:",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Rs. ${discount.toPrecision(1)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Grand Amount:",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Rs. ${(amount - discount).toPrecision(1)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: handleClick,
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: accentColor,
                                ),
                                child: Center(
                                  child: Text(
                                    "Place Order",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
  }

  void _performActionInFlutter() {
    GetSnackbar.info("this is a function called by javascript using webview");
  }
}
