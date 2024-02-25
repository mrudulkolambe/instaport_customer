// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/confirm.dart';
import 'package:instaport_customer/controllers/removeBarConfirm.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/models/places_model.dart';
import 'package:instaport_customer/models/price_model.dart';
import 'package:instaport_customer/screens/track_order.dart';
import 'package:instaport_customer/services/location_service.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:instaport_customer/utils/validator.dart';
import 'package:uuid/uuid.dart';

class EditOrderDetails extends StatefulWidget {
  final Orders order;

  const EditOrderDetails({super.key, required this.order});

  @override
  State<EditOrderDetails> createState() => _EditOrderDetailsState();
}

final storage = GetStorage();

class _EditOrderDetailsState extends State<EditOrderDetails> {
  Orders? order;
  Key _columnkey = UniqueKey();
  double oldAmount = 0.0;
  List<bool> _isOpen = [];
  final TextEditingController _phonenumbercontroller = TextEditingController();
  final TextEditingController _parcelvaluecontroller = TextEditingController();
  final TextEditingController _packagecontroller = TextEditingController();
  List<Address> address = [];
  bool ignoring = false;
  bool loading = true;
  final FocusNode _focusNode = FocusNode();
  List<Place> places = [];
  bool updateLoading = false;
  Address? paymentAddress;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  final List<String> items = [
    '0-1 kg',
    '1-5 kg',
    '5-10 kg',
    '10-15 kg',
    '15-20 kg'
  ];
  String dropdownValue = '0-1 kg';
  void fetchData() async {
    try {
      final token = await storage.read("token");
      if (token != null) {
        String url = '$apiUrl/order/customer_app/${widget.order.id}';
        final response = await http
            .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
        final data = OrderResponse.fromJson(json.decode(response.body));
        setState(() {
          _phonenumbercontroller.text = data.order.phone_number;
          _parcelvaluecontroller.text = data.order.parcel_value.toString();
          _packagecontroller.text = data.order.package;
          loading = false;
          order = data.order;
          _columnkey = UniqueKey();
          dropdownValue = data.order.parcel_weight;
          _dropdownkey = UniqueKey();
          oldAmount = data.order.amount;
          address.add(data.order.pickup);
          address.add(data.order.drop);
          address.addAll(data.order.droplocations);
          paymentAddress = data.order.payment_address;
        });
      } else {}
    } catch (e) {}
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        updateLoading = true;
      });
      final ConfirmController confirmController = Get.put(ConfirmController());
      final token = await storage.read("token");
      var amount = await handlePreFetch();
      bool result = await confirmController.showConfirmDialog(
          oldAmount, amount, order!.payment_method);
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      };
      var request = http.Request('PATCH', Uri.parse('$apiUrl/order/customer/'));
      var mAddress = List.from(address, growable: true);
      mAddress.removeAt(0);
      mAddress.removeAt(0);
      if (order!.payment_method == "cod") {
        request.body = json.encode({
          "_id": order!.id,
          "pickup": address.first,
          "drop": address[1],
          "droplocations": mAddress.isEmpty ? [] : mAddress,
          "parcel_weight": dropdownValue,
          "phone_number": _phonenumbercontroller.text,
          "package": _packagecontroller.text,
          "parcel_value": _parcelvaluecontroller.text,
          "amount": amount,
          'hold': oldAmount - amount,
          'payment_address': paymentAddress
        });
      } else {
        request.body = json.encode({
          "_id": order!.id,
          "pickup": address.first,
          "drop": address[1],
          "droplocations": mAddress.isEmpty ? [] : mAddress,
          "parcel_weight": dropdownValue,
          "phone_number": _phonenumbercontroller.text,
          "package": _packagecontroller.text,
          "parcel_value": _parcelvaluecontroller.text,
          "amount": amount,
          'hold': oldAmount - amount
        });
      }
      request.headers.addAll(headers);
      if (result) {
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          var data = await response.stream.bytesToString();
          var json = jsonDecode(data);
          FirebaseDatabase.instance.ref('/orders/${order!.id}').update(
            {"modified": "data", "order": json["order"]},
          );
          Get.back();
          ToastManager.showToast("${json["message"]}");
        } else {
          ToastManager.showToast("${response.reasonPhrase}");
        }
      }
      setState(() {
        updateLoading = false;
      });
    } else {
      ToastManager.showToast("Form incompletely filled!");
      setState(() {
        updateLoading = false;
      });
    }
  }

  Key _dropdownkey = UniqueKey();

  Future<double> handlePreFetch() async {
    double totalDistance = 0;
    double totalAmount = 0;
    var response = await http.get(Uri.parse("$apiUrl/price/get"));
    final data = PriceManipulationResponse.fromJson(jsonDecode(response.body));
    List<Address> mAddress = List.from(address, growable: true);
    mAddress.removeAt(0);
    mAddress.removeAt(0);
    var distanceMain = await LocationService().fetchDistance(
      address[0].latitude,
      address[0].longitude,
      address[1].latitude,
      address[1].longitude,
    );
    totalDistance = (distanceMain.rows[0].elements[0].distance.value / 1000);
    totalAmount = (distanceMain.rows[0].elements[0].distance.value / 1000) *
        data.priceManipulation.perKilometerCharge;
    if (mAddress.isNotEmpty) {
      for (int i = 0; i < mAddress.length; i++) {
        double srcLat, srcLng, destLat, destLng;
        if (i == 0) {
          srcLat = address[1].latitude;
          srcLng = address[1].longitude;
          destLat = mAddress[i].latitude;
          destLng = mAddress[i].longitude;
        } else {
          srcLat = mAddress[i - 1].latitude;
          srcLng = mAddress[i - 1].longitude;
          destLat = mAddress[i].latitude;
          destLng = mAddress[i].longitude;
        }
        var locationData = await LocationService()
            .fetchDistance(srcLat, srcLng, destLat, destLng);
        totalDistance += locationData.rows[0].elements[0].distance.value / 1000;
        totalAmount +=
            (locationData.rows[0].elements[0].distance.value / 1000) *
                data.priceManipulation.additionalPerKilometerCharge;
      }
    }
    if (totalDistance <= 1.0) {
      var finalAmount =
          order!.parcel_weight == items[0] || order!.parcel_weight == items[1]
              ? data.priceManipulation.baseOrderCharges
              : order!.parcel_weight == items[2]
                  ? data.priceManipulation.baseOrderCharges + 50
                  : order!.parcel_weight == items[3]
                      ? data.priceManipulation.baseOrderCharges + 100
                      : data.priceManipulation.baseOrderCharges + 150;
      return finalAmount;
    } else {
      var finalAmount = order!.parcel_weight == items[0] ||
              order!.parcel_weight == items[1]
          ? totalAmount + data.priceManipulation.baseOrderCharges
          : order!.parcel_weight == items[2]
              ? totalAmount + 50 + data.priceManipulation.baseOrderCharges
              : order!.parcel_weight == items[3]
                  ? totalAmount + 100 + data.priceManipulation.baseOrderCharges
                  : totalAmount + 150 + data.priceManipulation.baseOrderCharges;
      return finalAmount;
    }
  }

  void handleRemove(int index) async {
    final RemoveConfirm confirmController = Get.put(RemoveConfirm());
    bool result = await confirmController.showRemoveConfirmDialog();
    if (result) {
      setState(() {
        if (paymentAddress != null &&
            address[index].key == paymentAddress!.key && order!.payment_method == "cod") {
              paymentAddress = address[1];
          address.removeAt(index);
        } else {
          address.removeAt(index);
        }
      });
    } else {
      print("Event Cancelled");
    }
  }

  var uuid = const Uuid();
  void handleAdd() {
    Address initialAddress = Address(
      text: "",
      latitude: 0.0,
      longitude: 0.0,
      building_and_flat: "",
      floor_and_wing: "",
      instructions: "",
      phone_number: "",
      address: "",
      name: "",
      key: "",
    );
    String key = uuid.v1();
    initialAddress.key = key;
    setState(() {
      address.add(initialAddress);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        title: CustomAppBar(
          title: "Edit #${widget.order.id.substring(18)}",
          back: () => Get.to(() => TrackOrder(data: widget.order)),
        ),
      ),
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                key: _columnkey,
                children: [
                  Column(children: [
                    const Label(label: "Weight: "),
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
                                key: _dropdownkey,
                                isExpanded: true,
                                value: dropdownValue,
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
                                onChanged: widget.order.orderStatus.length >= 2
                                    ? null
                                    : (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue!;
                                          order!.parcel_weight = newValue;
                                        });
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
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Label(label: "Phone Number: "),
                    TextFormField(
                      validator: (value) => validatePhoneNumber(value!),
                      inputFormatters: [phoneNumberMask],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      controller: _phonenumbercontroller,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter your phone number",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.red),
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
                    const Label(label: "Parcel Value: "),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _parcelvaluecontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter your parcel value",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.red),
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
                    const Label(label: "Package: "),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      enabled:
                          order != null ? order!.orderStatus.length < 2 : true,
                      controller: _packagecontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Invalid value';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter your package",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 2, color: Colors.red),
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
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  ...address.asMap().entries.map((e) {
                    _isOpen.add(false);
                    var check = order!.orderStatus.where(
                      (element) {
                        return element.key == e.value.key;
                      },
                    );
                    return Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: accentColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            style: ListTileStyle.list,
                            title: Text(
                              e.key == 0 ? "Pickup" : "Drop ${e.key}",
                            ),
                            subtitle: Text(e.value.text.length > 25
                                ? "${e.value.text.substring(0, 25)}..."
                                : e.value.text),
                            titleTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            subtitleTextStyle: GoogleFonts.poppins(
                              color: Colors.black,
                            ),
                            onTap: () {
                              setState(() {
                                _isOpen[e.key] = !_isOpen[e.key];
                              });
                            },
                            trailing: Icon(
                              _isOpen[e.key]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _isOpen[e.key]
                              ? order!.delivery_type == "scheduled"
                                  ? 900.0
                                  : 700.0
                              : 0.0,
                          curve: Curves.easeInOut,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isOpen[e.key] ? 1.0 : 0.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 10,
                              ),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  const Label(
                                                      label: "Google Map: "),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Invalid location';
                                                      }
                                                      return null;
                                                    },
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    enabled: check.isEmpty,
                                                    initialValue: e.value.text,
                                                    onChanged: check.isEmpty
                                                        ? (String value) async {
                                                            final data =
                                                                await LocationService()
                                                                    .fetchPlaces(
                                                                        value);
                                                            setState(() {
                                                              places = data;
                                                            });
                                                          }
                                                        : null,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Search for places...",
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black38),
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 2,
                                                          color: Colors.red,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            width: 2,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1)),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            width: 2,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1)),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                                width: 2,
                                                                color:
                                                                    accentColor),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 15,
                                                              horizontal: 15),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (places.isNotEmpty)
                                                Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 80,
                                                    ),
                                                    Container(
                                                      height: 300,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            places.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.2),
                                                                  width: 2,
                                                                ),
                                                              ),
                                                            ),
                                                            child: ListTile(
                                                              iconColor:
                                                                  accentColor,
                                                              title: Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .location_on_rounded,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Text(
                                                                        places[index]
                                                                            .description,
                                                                        maxLines:
                                                                            1,
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              onTap: () async {
                                                                final data =
                                                                    await LocationService()
                                                                        .fetchPlaceDetails(
                                                                  places[index]
                                                                      .placeId,
                                                                );
                                                                if (_focusNode
                                                                    .hasFocus) {
                                                                  _focusNode
                                                                      .unfocus();
                                                                }
                                                                setState(() {
                                                                  var items =
                                                                      address;
                                                                  items[e.key]
                                                                      .text = places[
                                                                          index]
                                                                      .description;
                                                                  items[e.key]
                                                                          .latitude =
                                                                      data.latitude;
                                                                  items[e.key]
                                                                          .longitude =
                                                                      data.longitude;
                                                                  address =
                                                                      items;
                                                                  places = [];
                                                                  _formKey =
                                                                      GlobalKey<
                                                                          FormState>();
                                                                });
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Label(label: "Name: "),
                                      TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        enabled: check.isEmpty,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].name = value;
                                            address = items;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].name = value;
                                            address = items;
                                          });
                                        },
                                        initialValue: e.value.name,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Invalid name';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.name,
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
                                            borderSide: const BorderSide(
                                                width: 2, color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                width: 2, color: accentColor),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 15),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Label(label: "Phone Number: "),
                                      TextFormField(
                                        validator: (value) =>
                                            validatePhoneNumber(value!),
                                        inputFormatters: [phoneNumberMask],
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        enabled: check.isEmpty,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].phone_number = value;
                                            address = items;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].phone_number = value;
                                            address = items;
                                          });
                                        },
                                        initialValue: e.value.phone_number,
                                        keyboardType: TextInputType.phone,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "Enter your phone number",
                                          hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black38),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 2, color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                width: 2, color: accentColor),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 15),
                                        ),
                                      ),
                                      if (order!.delivery_type == "scheduled")
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (order!.delivery_type == "scheduled")
                                        const Label(
                                            label:
                                                "When to arrive at this address: "),
                                      if (order!.delivery_type == "scheduled")
                                        TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          enabled: check.isEmpty,
                                          onFieldSubmitted: (value) {
                                            setState(() {
                                              var items = address;
                                              items[e.key].date = value;
                                              address = items;
                                            });
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              var items = address;
                                              items[e.key].date = value;
                                              address = items;
                                            });
                                          },
                                          initialValue: e.value.date,
                                          validator: (value) {
                                            if (order!.delivery_type ==
                                                "scheduled") {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Invalid date';
                                              }
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.datetime,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "Date",
                                            hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black38,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  width: 2,
                                                  color: Colors.black
                                                      .withOpacity(0.1)),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 2, color: Colors.red),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  width: 2,
                                                  color: Colors.black
                                                      .withOpacity(0.1)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 2,
                                                color: accentColor,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 15,
                                            ),
                                          ),
                                        ),
                                      if (order!.delivery_type == "scheduled")
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (order!.delivery_type == "scheduled")
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                enabled: check.isEmpty,
                                                onFieldSubmitted: (value) {
                                                  setState(() {
                                                    var items = address;
                                                    items[e.key].fromtime =
                                                        value;
                                                    address = items;
                                                  });
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    var items = address;
                                                    items[e.key].fromtime =
                                                        value;
                                                    address = items;
                                                  });
                                                },
                                                initialValue: e.value.fromtime,
                                                validator: (value) {
                                                  if (order!.delivery_type ==
                                                      "scheduled") {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Invalid time';
                                                    }
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.datetime,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  hintText:
                                                      "Enter your time range",
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black38,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                        width: 2,
                                                        color: Colors.black
                                                            .withOpacity(0.1)),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            width: 2,
                                                            color: Colors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                        width: 2,
                                                        color: Colors.black
                                                            .withOpacity(0.1)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 2,
                                                      color: accentColor,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                enabled: check.isEmpty,
                                                onFieldSubmitted: (value) {
                                                  setState(() {
                                                    var items = address;
                                                    items[e.key].totime = value;
                                                    address = items;
                                                  });
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    var items = address;
                                                    items[e.key].totime = value;
                                                    address = items;
                                                  });
                                                },
                                                initialValue: e.value.totime,
                                                validator: (value) {
                                                  if (order!.delivery_type ==
                                                      "scheduled") {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Invalid time';
                                                    }
                                                  }
                                                  return null;
                                                },
                                                keyboardType:
                                                    TextInputType.datetime,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  hintText:
                                                      "Enter your time range",
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black38,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                        width: 2,
                                                        color: Colors.black
                                                            .withOpacity(0.1)),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            width: 2,
                                                            color: Colors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                        width: 2,
                                                        color: Colors.black
                                                            .withOpacity(0.1)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 2,
                                                      color: accentColor,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        enabled: check.isEmpty,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].address = value;
                                            address = items;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].address = value;
                                            address = items;
                                          });
                                        },
                                        initialValue: e.value.address,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Invalid address';
                                          } else if (value.length < 5) {
                                            return 'Address length should be atleast 5 characters long!';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.text,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "Enter your address",
                                          hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black38),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 2, color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                width: 2, color: accentColor),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 15),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Label(
                                          label: "Building Name / Flat No: "),
                                      TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        enabled: check.isEmpty,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].building_and_flat =
                                                value;
                                            address = items;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].building_and_flat =
                                                value;
                                            address = items;
                                          });
                                        },
                                        initialValue: e.value.building_and_flat,
                                        keyboardType: TextInputType.text,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText:
                                              "Enter your building name & flat no.",
                                          hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black38),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                width: 2, color: accentColor),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 15),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Label(label: "Floor / Wing: "),
                                      TextFormField(
                                        enabled: check.isEmpty,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].floor_and_wing = value;
                                            address = items;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].floor_and_wing = value;
                                            address = items;
                                          });
                                        },
                                        initialValue: e.value.floor_and_wing,
                                        keyboardType: TextInputType.text,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "Enter your floor & wing.",
                                          hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black38),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                width: 2, color: accentColor),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        enabled: check.isEmpty,
                                        onFieldSubmitted: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].instructions = value;
                                            address = items;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            var items = address;
                                            items[e.key].instructions = value;
                                            address = items;
                                          });
                                        },
                                        initialValue: e.value.instructions,
                                        keyboardType: TextInputType.text,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: "Enter some instructions",
                                          hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black38),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              width: 2,
                                              color: accentColor,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 15,
                                            horizontal: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (e.key != 0 &&
                                          e.key != 1 &&
                                          check.isEmpty)
                                        GestureDetector(
                                          onTap: () => handleRemove(e.key),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 15,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Remove",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Colors.grey[300],
                          indent: 0,
                          endIndent: 0,
                        ),
                      ],
                    );
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => order!.status == "cancelled"
                        ? ToastManager.showToast(
                            "You cannot add drop addresses after cancellation!")
                        : order!.status == "delivered"
                            ? ToastManager.showToast(
                                "You cannot add drop addresses when the order is completed")
                            : handleAdd(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 2,
                          color: accentColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Add address",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: submitForm,
                    child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width - 2 * 25,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: updateLoading
                              ? const SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  "Update Order",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                  )
                ],
              ),
            ),
          ),
          if (loading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  color: accentColor,
                ),
              ),
            )
        ]),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
