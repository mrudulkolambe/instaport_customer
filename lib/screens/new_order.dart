// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/address_container.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/components/contactpicker.dart';
import 'package:instaport_customer/components/getsnackbar.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/price_model.dart';
import 'package:instaport_customer/screens/home.dart';
import 'package:instaport_customer/screens/location_picker/location_picker.dart';
import 'package:instaport_customer/screens/order_form.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/services/location_service.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/timeformatter.dart';
import 'package:instaport_customer/utils/validator.dart';

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
  bool loading = true;
  String deliveryType = type;
  int indexes = 0;
  List<Address> deliveryPoints = [];
  bool predictionLoading = false;

  PriceManipulation priceManipulation = PriceManipulation(
    id: "id",
    perKilometerCharge: 0,
    additionalPerKilometerCharge: 0,
    additionalPickupCharge: 0,
    securityFeesCharges: 0,
    baseOrderCharges: 0,
    instaportCommission: 0,
    additionalDropCharge: 0,
    withdrawalCharges: 0,
    cancellationCharges: 0,
  );
  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
      dropdownValue = orderController.currentorder.parcel_weight;
    });
    handleFetchPrice();
  }

  void handleFetchPrice() async {
    var response = await http.get(Uri.parse("$apiUrl/price/get"));
    final data = PriceManipulationResponse.fromJson(jsonDecode(response.body));
    setState(() {
      priceManipulation = data.priceManipulation;
      loading = false;
    });
  }

  void handlePreFetch() async {
    final AddressController addressController = Get.put(AddressController());
    double totalDistance = 0;
    double totalAmount = 0;
    var response = await http.get(Uri.parse("$apiUrl/price/get"));
    final data = PriceManipulationResponse.fromJson(jsonDecode(response.body));
    if (addressController.pickup.latitude == 0.0 ||
        addressController.pickup.longitude == 0.0 ||
        addressController.drop.latitude == 0.0 ||
        addressController.drop.longitude == 0.0) {
      return;
    } else {
      setState(() {
        predictionLoading = true;
      });
      var distanceMain = await LocationService().fetchDistance(
          addressController.pickup.latitude,
          addressController.pickup.longitude,
          addressController.drop.latitude,
          addressController.drop.longitude);
      totalDistance = (distanceMain.rows[0].elements[0].distance.value / 1000);
      totalAmount = (distanceMain.rows[0].elements[0].distance.value / 1000) *
          data.priceManipulation.perKilometerCharge;
      if (addressController.droplocations.isNotEmpty) {
        for (int i = 0; i < addressController.droplocations.length; i++) {
          double srcLat, srcLng, destLat, destLng;
          if (i == 0) {
            srcLat = addressController.drop.latitude;
            srcLng = addressController.drop.longitude;
            destLat = addressController.droplocations[i].latitude;
            destLng = addressController.droplocations[i].longitude;
          } else {
            srcLat = addressController.droplocations[i - 1].latitude;
            srcLng = addressController.droplocations[i - 1].longitude;
            destLat = addressController.droplocations[i].latitude;
            destLng = addressController.droplocations[i].longitude;
          }
          var locationData = await LocationService()
              .fetchDistance(srcLat, srcLng, destLat, destLng);
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
      print(amount);
      predictionLoading = false;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _instructioncontroller = TextEditingController();
  final TextEditingController _buildingcontroller = TextEditingController();
  final TextEditingController _floorcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _fromtimecontroller = TextEditingController();
  final TextEditingController _totimecontroller = TextEditingController();
  @override
  void dispose() {
    _datetimefocusnode.dispose();
    super.dispose();
  }

  void _removeFocus() {
    _datetimefocusnode.unfocus();
  }

  final FocusNode _datetimefocusnode = FocusNode();

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller,
    String type,
  ) async {
    DateTime selectedDateTime = DateTime.now();
    if (type == "date") {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        setState(() {
          controller.text =
              readTimestampAsDate(pickedDate.millisecondsSinceEpoch);
        });
      }
    } else if (type == "time") {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.inputOnly,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          controller.text =
              readTimestampAsTime(selectedDateTime.millisecondsSinceEpoch);
        });
      }
    }
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Label(label: "Name: "),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Invalid name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  controller: _namecontroller,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter your name",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 2, color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Label(label: "Phone Number: "),
                TextFormField(
                  validator: (value) => validatePhoneNumber(value!),
                  inputFormatters: [phoneNumberMask],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _phonecontroller,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: ContactPickerWidget(
                      textcontroller: _phonecontroller,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter your phone number",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 2, color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                ),
                if (orderController.currentorder.delivery_type == "scheduled")
                  const SizedBox(
                    height: 10,
                  ),
                if (orderController.currentorder.delivery_type == "scheduled")
                  const Label(label: "When to arrive at this address: "),
                if (orderController.currentorder.delivery_type == "scheduled")
                  TextFormField(
                    validator: (value) {
                      if (orderController.currentorder.delivery_type ==
                          "scheduled") {
                        if (value == null || value.isEmpty) {
                          return 'Invalid date';
                        }
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [dateMask],
                    controller: _datecontroller,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () => _selectDateTime(
                          context,
                          _datecontroller,
                          "date",
                        ),
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Date",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            width: 2, color: Colors.black.withOpacity(0.1)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 2, color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            width: 2, color: Colors.black.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 2,
                          color: accentColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                    ),
                  ),
                if (orderController.currentorder.delivery_type == "scheduled")
                  SizedBox(
                    height: 10,
                  ),
                if (orderController.currentorder.delivery_type == "scheduled")
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (orderController.currentorder.delivery_type ==
                                "scheduled") {
                              if (value == null || value.isEmpty) {
                                return 'Invalid time';
                              }
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [timeMask],
                          controller: _fromtimecontroller,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => _selectDateTime(
                                  context, _fromtimecontroller, "time"),
                              icon: const Icon(
                                Icons.av_timer_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your time range",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black38,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(width: 2, color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                width: 2,
                                color: accentColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (orderController.currentorder.delivery_type ==
                                "scheduled") {
                              if (value == null || value.isEmpty) {
                                return 'Invalid time';
                              }
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [timeMask],
                          controller: _totimecontroller,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => _selectDateTime(
                                  context, _totimecontroller, "time"),
                              icon: const Icon(
                                Icons.av_timer_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your time range",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black38,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(width: 2, color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                width: 2,
                                color: accentColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 10,
                ),
                const Label(label: "Address: "),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Invalid address';
                    } else if (value.length < 5) {
                      return 'Address length should be atleast 5 characters long!';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  controller: _addresscontroller,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter your address",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2, color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 2, color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Label(label: "Building Name / Flat No: "),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _buildingcontroller,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter your building name & flat no.",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 2, color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Label(label: "Floor / Wing: "),
                TextFormField(
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  controller: _floorcontroller,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter your floor & wing.",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 2, color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Label(label: "Instructions: "),
                TextFormField(
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  controller: _instructioncontroller,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Enter some instructions",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          width: 2, color: Colors.black.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 2, color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          title: "New Order",
          back: () => Get.to(() => const Home()),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SafeArea(
        child: loading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: accentColor,
                  size: 30,
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
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  ordercontroller.updateType("now");
                                },
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: ordercontroller
                                                .currentorder.delivery_type ==
                                            "now"
                                        ? accentColor
                                        : Colors.white,
                                    border: Border.all(
                                      width: 2,
                                      color: accentColor,
                                    ),
                                  ),
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
                                            "Send Now",
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
                                onTap: () =>
                                    ordercontroller.updateType("scheduled"),
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: ordercontroller
                                                  .currentorder.delivery_type ==
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
                                            "Slot Time",
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
                        ),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
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
                              return Column(
                                children: [
                                  GestureDetector(
                                    child: AddressContainer(
                                        latitude: controller.pickup.latitude,
                                        longitude: controller.pickup.longitude,
                                        key: Key((0).toString()),
                                        title: "Pickup Address",
                                        address: controller.pickup,
                                        index: 0,
                                        subtitle: controller
                                                .pickup.text.isNotEmpty
                                            ? controller.pickup.text
                                            : "Add a pickup address for the courier"),
                                  ),
                                  AddressContainer(
                                    latitude: controller.drop.latitude,
                                    longitude: controller.drop.longitude,
                                    key: Key((1).toString()),
                                    title: "Drop address",
                                    address: controller.drop,
                                    index: 1,
                                    handleClick: _openBottomSheet,
                                  subtitle: controller
                                                .drop.text.isNotEmpty
                                            ? controller.drop.text :
                                        "Add a drop address for the courier",
                                  ),
                                  ...controller.droplocations
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => AddressContainer(
                                          latitude: e.value.latitude,
                                          longitude: e.value.longitude,
                                          key: Key((e.key + 2).toString()),
                                          title: "Drop address",
                                          address: e.value,
                                            subtitle: e.value.text.isNotEmpty
                                            ? e.value.text :
                                              "Add a drop address for the courier",
                                          index: e.key + 2,
                                        ),
                                      )
                                      .toList(),
                                  AddressContainer(
                                    index: -10,
                                    latitude: 0.0,
                                    longitude: 0.0,
                                    key: const Key("Add delivery address"),
                                    title: "Add a delivery address",
                                    address: controller.pickup,
                                    subtitle:
                                        "Add more drop address for the courier",
                                    handleClick: () =>
                                        controller.addNewDropLocation(
                                      controller.initialaddress,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  GestureDetector(
                                    onTap: handlePreFetch,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          2 * 25,
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
                                        child: predictionLoading
                                            ? const Center(
                                                child: SpinKitThreeBounce(
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              )
                                            : Text(
                                                amount == 0.0
                                                    ? "Click here to calculate the estimated fare"
                                                    : "Estimated Amount: ${amount.round()}",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: amount == 0.0
                                                      ? FontWeight.normal
                                                      : FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                        const SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            final AddressController addressController =
                                Get.find();
                            var checks = addressController.droplocations
                                .where((element) {
                              return (element.text.isEmpty ||
                                  element.latitude == 0.0 ||
                                  element.longitude == 0.0 ||
                                  element.address.isEmpty ||
                                  element.phone_number.isEmpty ||
                                  element.name.isEmpty);
                            });
                            if (addressController.pickup.text.isNotEmpty &&
                                addressController.drop.text.isNotEmpty &&
                                checks.isEmpty) {
                              Get.to(() => const OrderForm());
                            } else if (orderController
                                        .currentorder.delivery_type ==
                                    "scheduled" &&
                                orderController.currentorder.pickup.fromtime !=
                                    null &&
                                orderController.currentorder.pickup.totime !=
                                    null &&
                                orderController.currentorder.pickup.date !=
                                    null &&
                                orderController.currentorder.drop.fromtime !=
                                    null &&
                                orderController.currentorder.drop.totime !=
                                    null &&
                                orderController.currentorder.drop.date !=
                                    null) {
                              GetSnackbar.info(
                                "Date time not mentioned",
                              );
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
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
