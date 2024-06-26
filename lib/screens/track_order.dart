// ignore_for_file: empty_catches, non_constant_identifier_names, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaport_customer/components/address_details.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/models/price_model.dart';
import 'package:instaport_customer/screens/edit_order.dart';
import 'package:instaport_customer/screens/home.dart';
import 'package:instaport_customer/utils/timeformatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/controllers/app.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:instaport_customer/models/rider_location_model.dart';
import 'package:instaport_customer/services/location_service.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:get_storage/get_storage.dart';

class TrackOrder extends StatefulWidget {
  final Orders data;
  const TrackOrder({super.key, required this.data});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  final storage = GetStorage();
  Set<Marker> _markers = {};
  BitmapDescriptor trackIcon = BitmapDescriptor.defaultMarker;
  Set<Polyline> _polylineSet = {};
  final AppController appController = Get.put(AppController());
  bool loading = false;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  late GoogleMapController newgooglemapcontroller;
  List<LatLng> pLineCoordinatedList = [];
  final Key _mapKey = UniqueKey();
  LatLng riderLocation = const LatLng(0.0, 0.0);
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _databaseListener;
  double sheetHeight = 350.0;
  double cancelOrderSheetHeight = 0;
  Timer? _timer;
  final TextEditingController _reason = TextEditingController();
  PriceManipulation? price;
  List<Column> droplocationslists = [];

  void handlePriceFetch() async {
    var response = await http.get(Uri.parse("$apiUrl/price/get"));
    final data = PriceManipulationResponse.fromJson(jsonDecode(response.body));
    setState(() {
      price = data.priceManipulation;
    });
  }

  Orders order_data = Orders(
    distances: [],
    pickup: Address(
      text: "",
      latitude: 0.0,
      longitude: 0.0,
      building_and_flat: "",
      floor_and_wing: "",
      key: "",
      instructions: "",
      phone_number: "",
      address: "",
      name: "",
    ),
    orderStatus: [],
    drop: Address(
      text: "",
      latitude: 0.0,
      longitude: 0.0,
      key: "",
      building_and_flat: "",
      floor_and_wing: "",
      instructions: "",
      phone_number: "",
      address: "",
      name: "",
    ),
    droplocations: [],
    id: "",
    delivery_type: "",
    parcel_weight: "",
    phone_number: "",
    notify_sms: false,
    courier_bag: false,
    vehicle: "",
    status: "",
    payment_method: "",
    customer: "",
    package: "",
    time_stamp: 0,
    parcel_value: 0,
    amount: 0,
  );

  void markersAndPolylines(Orders order) async {
    Set<Marker> funcmarkers = {};
    Set<Polyline> funcpolyline = {};
    final directionData = await LocationService().fetchDirections(
      order.pickup.latitude,
      order.pickup.longitude,
      order.drop.latitude,
      order.drop.longitude,
      order.droplocations,
    );

    Marker pickupmarker = Marker(
      markerId: MarkerId(order.pickup.text),
      position: LatLng(
        order.pickup.latitude,
        order.pickup.longitude,
      ),
    );
    Marker dropmarker = Marker(
      markerId: MarkerId(order.drop.text),
      position: LatLng(
        order.drop.latitude,
        order.drop.longitude,
      ),
    );

    Set<Marker> defaultMarkerSet = {
      pickupmarker,
      dropmarker,
    };
    var droplocationmarkers = List.from(order.droplocations).map((e) {
      return Marker(
        markerId: MarkerId(e.address),
        infoWindow: const InfoWindow(title: "Drop Point"),
        position: LatLng(
          e.latitude,
          e.longitude,
        ),
      );
    }).toSet();

    funcmarkers = {...defaultMarkerSet, ...droplocationmarkers};
    PolylinePoints pPoints = PolylinePoints();

    List<PointLatLng> decodePolylinePointsResult =
        pPoints.decodePolyline(directionData.e_points!);
    pLineCoordinatedList.clear();

    if (decodePolylinePointsResult.isNotEmpty) {
      for (var pointLatLng in decodePolylinePointsResult) {
        pLineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    Polyline polyline = Polyline(
      polylineId: const PolylineId("main"),
      color: Colors.black,
      jointType: JointType.round,
      endCap: Cap.roundCap,
      geodesic: true,
      width: 5,
      points: pLineCoordinatedList,
    );
    _polylineSet.clear();
    funcpolyline.add(polyline);

    try {
      setState(() {
        _markers = funcmarkers;
        _polylineSet = funcpolyline;
      });
      repositionGoogleMaps(
        LatLng(order.pickup.latitude, order.pickup.longitude),
        LatLng(order.drop.latitude, order.drop.longitude),
      );
    } catch (e) {}
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _whatsapp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void repositionGoogleMaps(LatLng src, LatLng dest) {
    LatLngBounds boundsLatLng;
    if (src.latitude > dest.latitude && src.longitude > dest.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
          dest.latitude,
          dest.longitude,
        ),
        northeast: LatLng(
          src.latitude,
          src.longitude,
        ),
      );
    } else if (src.longitude > dest.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
          src.latitude,
          dest.longitude,
        ),
        northeast: LatLng(
          dest.latitude,
          src.longitude,
        ),
      );
    } else if (src.latitude > dest.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
          dest.latitude,
          src.longitude,
        ),
        northeast: LatLng(
          src.latitude,
          dest.longitude,
        ),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
          src.latitude,
          src.longitude,
        ),
        northeast: LatLng(
          dest.latitude,
          dest.longitude,
        ),
      );
    }
    newgooglemapcontroller.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );
  }

  Future<void> getOrderById() async {
    final token = await storage.read("token");
    if (token != null) {
      String url = '$apiUrl/order/customer_app/${widget.data.id}';
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      final data = OrderResponse.fromJson(json.decode(response.body));
      var items = List.from(data.order.droplocations).asMap().entries.map((e) {
        return Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            AddressDetailsScreen(
              key: Key((e.key + 2).toString()),
              address: e.value,
              title: "Drop Point",
              scheduled: data.order.delivery_type != "now",
              paymentAddress: data.order.payment_address,
              time: data.order.time_stamp,
              orderStatus: data.order.orderStatus,
              index: e.key + 2,
              type: data.order.payment_method,
              amount: data.order.amount,
              status: data.order.status,
            ),
          ],
        );
      }).toList();
        markersAndPolylines(data.order);
      setState(() {
        droplocationslists = items;
        order_data = data.order;
      });
      try {
        if (data.order.rider != null && data.order.status != "delivered") {
          _databaseListener = ref
              .child('rider/${widget.data.rider!.id}')
              .onValue
              .listen((DatabaseEvent event) {
            final data = event.snapshot.value;
            final dynamic snapshotValue = json.encode(data);
            if (snapshotValue != null) {
              final data = RiderLocation.fromJson(jsonDecode(snapshotValue));
              setState(() {
                riderLocation = LatLng(data.latitude, data.longitude);
              });
            }
          });
        } else {
          // ToastManager.showToast('Error');
        }
      } catch (e) {
        print(e);
      }
    } else {}
  }

  Future<void> getOrderByIdContinue() async {
    final token = await storage.read("token");
    try {
      if (token != null) {
        String url = '$apiUrl/order/customer_app/${widget.data.id}';
        final response = await http
            .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
        final data = OrderResponse.fromJson(json.decode(response.body));
        setState(() {
          order_data = data.order;
        });
      } else {}
    } catch (e) {}
  }

  void withdrawOrder() async {
    try {
      if (_reason.text.isNotEmpty) {
        final token = await storage.read("token");
        var headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        };
        var request = http.Request(
          'PATCH',
          Uri.parse("$apiUrl/order/cancel/${widget.data.id}"),
        );
        request.body = json.encode({
          "reason": _reason.text,
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          FirebaseDatabase.instance.ref('/orders/${widget.data.id}').update(
            {"modified": "cancel"},
          );
          ToastManager.showToast("Order cancelled");
          Get.to(() => const Home());
        } else {
          ToastManager.showToast("Error: ${response.reasonPhrase}");
        }
      }
    } catch (e) {}
  }

  final FocusNode _reasonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeMap();
    getOrderById();
    // _customMarker();
    if (order_data.status != "cancelled") {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        getOrderByIdContinue();
      });
    }
  }

  void _initializeMap() async {
    newgooglemapcontroller = await _mapControllerCompleter.future;
  }

  void _customMarker() async {
    final track = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)),
        'assets/map/map-pin-drop.png');
    setState(() {
      trackIcon = track;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    newgooglemapcontroller.dispose();
    if (order_data.rider != null) {
      ref.onValue.drain();
      _databaseListener.cancel();
    }
    super.dispose();
  }

  void cancelConfirm() {
    if (order_data.orderStatus.length > 1) {
      Get.dialog(Dialog(
        insetPadding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 15.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Error",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "You cannot cancel the picked order",
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              loading
                  ? const SpinKitFadingCircle(
                      color: accentColor,
                      size: 20,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 2, color: accentColor),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              child: Center(
                                child: Text(
                                  "Okay",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
            ],
          ),
        ),
      ));
    } else {
      FocusScope.of(context).requestFocus(_reasonFocus);
      setState(() {
        cancelOrderSheetHeight = MediaQuery.of(context).size.height - 30;
      });
    }
  }

  Future<BitmapDescriptor> _customIcon() async {
    return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)), 'assets/my_icon.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 40,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      GoogleMap(
                        compassEnabled: true,
                        mapToolbarEnabled: false,
                        key: _mapKey,
                        polylines: _polylineSet,
                        markers: {
                          ..._markers,
                          if (order_data.status != "delivered")
                            Marker(
                              markerId: const MarkerId("Rider Location"),
                              position: riderLocation,
                              infoWindow: const InfoWindow(title: "Rider"),
                              icon: trackIcon,
                            ),
                        },
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            order_data.pickup.latitude,
                            order_data.pickup.longitude,
                          ),
                          zoom: 14.14,
                        ),
                        zoomControlsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          if (!_mapControllerCompleter.isCompleted) {
                            _mapControllerCompleter.complete(controller);
                            newgooglemapcontroller = controller;
                            // getOrderById();
                          }
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  repositionGoogleMaps(
                                    LatLng(order_data.pickup.latitude,
                                        order_data.pickup.longitude),
                                    LatLng(
                                      order_data.drop.latitude,
                                      order_data.drop.longitude,
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                    (states) => accentColor,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.location_on_rounded,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  _initializeMap();
                                  getOrderById();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                    (states) => accentColor,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.replay_outlined,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if (order_data.id.isNotEmpty &&
                    order_data.status != "cancelled")
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          sheetHeight -= details.primaryDelta!;
                          sheetHeight = sheetHeight.clamp(
                            45.0,
                            MediaQuery.of(context).size.height - 30,
                          );
                        });
                      },
                      onVerticalDragEnd: (details) {
                        if (sheetHeight < 200.0) {
                          sheetHeight = 45.0;
                        } else if (sheetHeight > 200.0 && sheetHeight < 350) {
                          sheetHeight = 350.0;
                        } else if (sheetHeight > 350) {
                          sheetHeight = MediaQuery.of(context).size.height - 45;
                        }
                      },
                      child: Material(
                        elevation: 10,
                        child: Container(
                          height: sheetHeight,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 30.0,
                                color: Colors.grey[200],
                                child: Center(
                                    child: Container(
                                  height: 3,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                )),
                              ),
                              SizedBox(
                                height: sheetHeight - 30,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Rs. ${(order_data.amount).toPrecision(2).toString()}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "#${order_data.id.substring(18)}",
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Weight: ",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            order_data.parcel_weight,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Parcel: ",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            order_data.package,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Payment: ",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            order_data.payment_method,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Time: ",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            readTimestamp(
                                                order_data.time_stamp),
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (!loading && order_data.rider != null)
                                        Text(
                                          order_data.orderStatus.isEmpty
                                              ? "Rider is on the way for pickup"
                                              : order_data.orderStatus.length ==
                                                      1
                                                  ? "Rider is on the way for pickup"
                                                  : order_data.orderStatus
                                                              .length <
                                                          4 +
                                                              order_data
                                                                  .droplocations
                                                                  .length
                                                      ? "Parcel is on the way"
                                                      : "Parcel Delivered",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (order_data.status != "delivered" &&
                                          order_data.status != "cancelled")
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => Get.to(
                                                  () => EditOrderDetails(
                                                    order: order_data,
                                                  ),
                                                ),
                                                child: Container(
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: accentColor,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Edit",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: order_data.status ==
                                                        "delivered"
                                                    ? () {}
                                                    : cancelConfirm,
                                                child: Container(
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: accentColor,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Cancel",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (order_data.status != "delivered")
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (order_data.status !=
                                                  "delivered" &&
                                              order_data.rider != null)
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: order_data.rider ==
                                                            null
                                                        ? const CircularProgressIndicator()
                                                        : order_data.rider!
                                                                    .image ==
                                                                ""
                                                            ? Container(
                                                                color: accentColor
                                                                    .withOpacity(
                                                                        0.5),
                                                                height: 50,
                                                                width: 50,
                                                              )
                                                            : Image.network(
                                                                order_data
                                                                    .rider!
                                                                    .image,
                                                                height: 50,
                                                                width: 50,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  print(error);
                                                                  return const Text(
                                                                      "Error");
                                                                },
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        order_data.rider == null
                                                            ? "Fetching..."
                                                            : order_data.rider!
                                                                .fullname,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        softWrap: false,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (order_data.rider !=
                                                          null)
                                                        Text(
                                                          "#${order_data.rider!.id.substring(18)}",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          if (order_data.status !=
                                                  "delivered" &&
                                              order_data.rider != null)
                                            IconButton(
                                              onPressed: () => _makePhoneCall(
                                                  order_data.rider!.mobileno),
                                              icon: const Icon(Icons.call),
                                            ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          if (order_data.status !=
                                                  "delivered" &&
                                              order_data.rider != null)
                                            IconButton(
                                              onPressed: () => _whatsapp(
                                                  order_data.rider!.mobileno),
                                              icon: const Icon(Icons.message),
                                            )
                                        ],
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      AddressDetailsScreen(
                                        address: order_data.pickup,
                                        title: "Pickup",
                                        scheduled:
                                            order_data.delivery_type != "now",
                                        paymentAddress:
                                            order_data.payment_address,
                                        time: order_data.time_stamp,
                                        orderStatus: order_data.orderStatus,
                                        index: 0,
                                        amount: order_data.amount,
                                        type: order_data.payment_method,
                                        status: order_data.status,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      const Divider(),
                                      AddressDetailsScreen(
                                        address: order_data.drop,
                                        title: "Drop",
                                        scheduled:
                                            order_data.delivery_type != "now",
                                        paymentAddress:
                                            order_data.payment_address,
                                        time: order_data.time_stamp,
                                        orderStatus: order_data.orderStatus,
                                        index: 1,
                                        type: order_data.payment_method,
                                        amount: order_data.amount,
                                        status: order_data.status,
                                      ),
                                      ...droplocationslists.map((Column item) {
                                        return item;
                                      }).toList(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      if (order_data.orderStatus.isEmpty &&
                                          order_data.rider != null)
                                        Text(
                                          "On Rider is on the way for pickup",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (order_data.rider == null)
                                        Text(
                                          "Looking for nearby riders",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (order_data.orderStatus.isNotEmpty)
                                        ...order_data.orderStatus
                                            .asMap()
                                            .entries
                                            .map(
                                              (e) => Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .radio_button_checked,
                                                            color: accentColor,
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          if (e.key !=
                                                              order_data
                                                                      .orderStatus
                                                                      .length -
                                                                  1)
                                                            const DottedLine(
                                                              direction:
                                                                  Axis.vertical,
                                                              lineLength: 45,
                                                              lineThickness:
                                                                  2.0,
                                                              dashLength: 5.0,
                                                              dashColor:
                                                                  Colors.black,
                                                              dashRadius: 4.0,
                                                              dashGapLength:
                                                                  3.0,
                                                              dashGapColor: Colors
                                                                  .transparent,
                                                              dashGapRadius:
                                                                  0.0,
                                                            ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 15,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .size
                                                                        .width -
                                                                    50 -
                                                                    30 -
                                                                    15,
                                                                child: Text(
                                                                  e.key == 0
                                                                      ? "Pickup Started"
                                                                      : e.key ==
                                                                              1
                                                                          ? "Parcel Pickup Up"
                                                                          : e.key <= order_data.orderStatus.length - 1 && e.key > 1 && e.value.message != "Delivered"
                                                                              ? "Parcel Dropped"
                                                                              : "Order completed",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .size
                                                                        .width -
                                                                    50 -
                                                                    30 -
                                                                    10,
                                                                child: Text(
                                                                  e.value
                                                                      .message,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .size
                                                                        .width -
                                                                    50 -
                                                                    30 -
                                                                    10,
                                                                child: Text(
                                                                  readTimestamp(e
                                                                      .value
                                                                      .timestamp),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onVerticalDragDown: (details) {},
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        cancelOrderSheetHeight -= details.primaryDelta!;
                        cancelOrderSheetHeight = cancelOrderSheetHeight.clamp(
                            40, MediaQuery.of(context).size.height - 100);
                      });
                    },
                    onVerticalDragEnd: (details) {
                      cancelOrderSheetHeight = 40.0;
                    },
                    child: Material(
                      elevation: 8.0,
                      child: SingleChildScrollView(
                        child: Container(
                          height: cancelOrderSheetHeight,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 30.0,
                                color: Colors.grey[300],
                              ),
                              Expanded(
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Confirm",
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Are you sure you want to cancel the order?",
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ],
                                        ),
                                        if (order_data.orderStatus.isNotEmpty)
                                          Row(
                                            children: [
                                              Text(
                                                "You will be charged ${price == null ? 00 : price!.cancellationCharges}Rs",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            Text(
                                              "Order amount will be added to your holdings",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Label(
                                            label: "Cancellation Reason: "),
                                        TextFormField(
                                          focusNode: _reasonFocus,
                                          controller: _reason,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          keyboardType: TextInputType.text,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          minLines: 6,
                                          maxLines: 7,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Invalid text';
                                            } else if (value.length < 5) {
                                              return 'Reason length should be atleast 5 characters long!';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText:
                                                "Enter your cancellation reason",
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
                                                    horizontal: 15),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: withdrawOrder,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: accentColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 2,
                                                        color:
                                                            Colors.transparent),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 12,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Proceed",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  setState(() {
                                                    cancelOrderSheetHeight = 0;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 2,
                                                        color: accentColor),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 12,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Cancel",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: accentColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
