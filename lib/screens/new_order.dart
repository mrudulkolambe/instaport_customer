import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/components/getsnackbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/price_model.dart';
import 'package:instaport_customer/screens/location_picker/places_autocomplete.dart';
import 'package:instaport_customer/screens/order_form.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/services/location_service.dart';

class Neworder extends StatefulWidget {
  const Neworder({super.key});

  @override
  State<Neworder> createState() => _NeworderState();
}

final List<String> items = [
  '0-1 kg',
  '1-5 kg',
  '5-10 kg',
  '10-15 kg',
  '15-20 kg'
];
const String type = "now";

class _NeworderState extends State<Neworder> {
  AddressController addressController = AddressController();
  OrderController orderController = OrderController();
  String dropdownValue = items.first;
  double amount = 0.0;
  String deliveryType = type;
  PriceManipulation priceManipulation = PriceManipulation(
    id: "id",
    perKilometerCharge: 0,
    additionalPerKilometerCharge: 0,
    additionalPickupCharge: 0,
    securityFeesCharges: 0,
    baseOrderCharges: 0,
    instaportCommission: 0,
    additionalDropCharge: 0,
  );
  @override
  void initState() {
    super.initState();
    handleFetchPrice();
  }

  void handleFetchPrice() async {
    var response = await http.get(Uri.parse("$apiUrl/price/get"));
    final data = PriceManipulationResponse.fromJson(jsonDecode(response.body));
    setState(() {
      priceManipulation = data.priceManipulation;
    });
  }

  void handlePreFetch(
      double srclat, double srclng, double destlat, double destlng) async {
    if (srclat == 0.0 && srclng == 0.0 && destlat == 0.0 && destlng == 0.0) {
      return;
    } else {
      var distanceObj = await LocationService()
          .fetchDistance(srclat, srclng, destlat, destlng);
      var response = await http.get(Uri.parse("$apiUrl/price/get"));
      final data =
          PriceManipulationResponse.fromJson(jsonDecode(response.body));
      setState(() {
        priceManipulation = data.priceManipulation;
        if (distanceObj.rows[0].elements[0].distance.value <= 4000) {
          amount = data.priceManipulation.baseOrderCharges + 0.0;
        } else {
          amount = (data.priceManipulation.perKilometerCharge *
                      ((distanceObj.rows[0].elements[0].distance.value - 4000) /
                          1000))
                  .toPrecision(1) +
              data.priceManipulation.baseOrderCharges;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const CustomAppBar(
            title: "New Order",
          ),
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(),
        body: SafeArea(
          child: GetBuilder<OrderController>(
            init: OrderController(),
            builder: (ordercontroller) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    GetBuilder<OrderController>(builder: (controller) {
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.updateType("now");
                              },
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        controller.currentorder.delivery_type ==
                                                "now"
                                            ? accentColor
                                            : Colors.white,
                                    border: Border.all(
                                      width: 2,
                                      color: accentColor,
                                    )),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.string(
                                      '<svg width="24" height="24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10.989 13.267 7.599 6.5l5.962 4.707a1.67 1.67 0 0 1 .01 2.62c-.844.675-2.1.402-2.582-.56Z" stroke="#001A72" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M4.3 4.102c-2.036 2-3.3 4.79-3.3 7.873C1 18.064 5.925 23 12 23s11-4.936 11-11.025c0-5.339-3.786-9.79-8.814-10.807-.92-.186-1.38-.279-1.783.052C12 1.55 12 2.086 12 3.155v1.103" stroke="#001A72" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Deliver Now",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "from ₹${priceManipulation.baseOrderCharges}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.updateType("scheduled"),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        controller.currentorder.delivery_type ==
                                                "scheduled"
                                            ? accentColor
                                            : Colors.white,
                                    border: Border.all(
                                      width: 2,
                                      color: accentColor,
                                    )),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.string(
                                      '<svg width="23" height="25" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18.131 1.5v2.2M4.868 1.5v2.2M1 12.768c0-4.793 0-7.19 1.384-8.679C3.768 2.6 5.995 2.6 10.45 2.6h2.1c4.455 0 6.682 0 8.066 1.49C22 5.577 22 7.974 22 12.767v.564c0 4.794 0 7.19-1.384 8.68C19.232 23.5 17.005 23.5 12.55 23.5h-2.1c-4.455 0-6.682 0-8.066-1.489C1 20.522 1 18.126 1 13.333v-.565ZM1.553 8.1h19.895" stroke="#001A72" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Schedule",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "from ₹${priceManipulation.baseOrderCharges}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "As soon as feasible, we will designate the closest courier to pick up and deliver.",
                            style: GoogleFonts.poppins(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: accentColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: DropdownButton(
                                isExpanded: true,
                                value: ordercontroller
                                            .currentorder.parcel_weight ==
                                        "0-1 kg"
                                    ? dropdownValue
                                    : ordercontroller
                                        .currentorder.parcel_weight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                hint: Text(
                                  "Select weight",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onChanged: (String? newValue) {
                                  ordercontroller.updateWeight(newValue!);
                                  setState(() => dropdownValue = newValue);
                                },
                                items: items
                                    .map(
                                      (String value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                iconSize: 0,
                                underline: const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GetBuilder<AddressController>(
                        init: AddressController(),
                        builder: (controller) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 27.5,
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "1",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 77.5,
                                    width: 2,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "2",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 77.5,
                                    width: 2,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "+",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => PlacesAutoComplete(
                                            latitude:
                                                controller.pickup.latitude,
                                            longitude:
                                                controller.pickup.longitude,
                                            text: controller.pickup.text,
                                            index: 0,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.08),
                                          border: Border.all(
                                            width: 2,
                                            color: accentColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                "Pickup Point",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                controller
                                                        .pickup.text.isNotEmpty
                                                    ? controller.pickup.text
                                                    : "Add a pickup point for the courier",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => PlacesAutoComplete(
                                            latitude: controller.drop.latitude,
                                            longitude:
                                                controller.drop.longitude,
                                            text: controller.drop.text,
                                            index: 1,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color:
                                                accentColor.withOpacity(0.08),
                                            border: Border.all(
                                              width: 2,
                                              color: accentColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                "Delivery Point",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                controller.drop.text.isNotEmpty
                                                    ? controller.drop.text
                                                    : "Add a drop point for the courier",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black54,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.08),
                                          border: Border.all(
                                            width: 2,
                                            color: accentColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              "Add a Delivery Point",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Add a delivery point for the courier",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        }),
                    const SizedBox(
                      height: 30,
                    ),
                    GetBuilder<AddressController>(
                        init: AddressController(),
                        builder: (addressController) {
                          return GestureDetector(
                            onTap: () => handlePreFetch(
                                addressController.pickup.latitude,
                                addressController.pickup.longitude,
                                addressController.drop.latitude,
                                addressController.drop.longitude),
                            child: Container(
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 8,
                                ),
                                child: Text(
                                  amount == 0.0 &&
                                          (addressController.pickup.text.isEmpty || addressController.drop.text.isEmpty) 
                                      ? "Click here to calculate the estimated fare"
                                      : dropdownValue == items[0] ||
                                              dropdownValue == items[1]
                                          ? "Estimated Fare: Rs.${amount.toString()}"
                                          : dropdownValue == items[2]
                                              ? "Estimated Fare: Rs.${(amount + 50).toString()}"
                                              : dropdownValue == items[3]
                                                  ? "Estimated Fare: Rs.${(amount + 100).toString()}"
                                                  : "Estimated Fare: Rs.${(amount + 150).toString()}",
                                                  key: Key("$dropdownValue ${addressController.pickup.address} ${addressController.drop.address}"),
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: amount == 0.0
                                          ? FontWeight.normal
                                          : FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }),
                    const SizedBox(
                      height: 30,
                    ),
                    GetBuilder<OrderController>(
                        init: OrderController(),
                        builder: (orderController) {
                          return GestureDetector(
                            onTap: () {
                              if (orderController
                                      .currentorder.pickup.text.isNotEmpty &&
                                  orderController
                                      .currentorder.drop.text.isNotEmpty) {
                                Get.to(() => const OrderForm());
                              } else {
                                GetSnackbar.info(
                                  "Incomplete form please fill the entire form",
                                );
                              }
                            },
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  "Continue",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
