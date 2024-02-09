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
import 'package:instaport_customer/api/orders.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/utils/timeformatter.dart';
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

class TrackOrder extends StatefulWidget {
  final Orders data;
  const TrackOrder({super.key, required this.data});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  Set<Marker> _markers = {};
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
  Orders order_data = Orders(
    pickup: Address(
      text: "",
      latitude: 0.0,
      longitude: 0.0,
      building_and_flat: "",
      floor_and_wing: "",
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
    final directionData = await LocationService().fetchDirections(
        order.pickup.latitude,
        order.pickup.longitude,
        order.drop.latitude,
        order.drop.longitude,
        order.droplocations);
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

    setState(() {
      _markers = funcmarkers;
      _polylineSet = funcpolyline;
    });
    repositionGoogleMaps(
      LatLng(order.pickup.latitude, order.pickup.longitude),
      LatLng(order.drop.latitude, order.drop.longitude),
    );
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
      // setState(() {
      //   loading = true;
      // });
      String url = '$apiUrl/order/customer_app/${widget.data.id}';
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      final data = OrderResponse.fromJson(json.decode(response.body));

      markersAndPolylines(data.order);
      setState(() {
        order_data = data.order;
      });
      if (data.order.rider != null) {
        _databaseListener = ref
            .child('rider/${data.order.rider!.id}')
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
        print("this is not correct");
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
    // _getCurrentLocation();
    getOrderById();
  }

  void _initializeMap() async {
    newgooglemapcontroller = await _mapControllerCompleter.future;
  }

  @override
  void dispose() {
    newgooglemapcontroller.dispose();
    if (order_data.rider != null) {
      ref.onValue.drain();
      _databaseListener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          title: "Tracking #${widget.data.id.toString().substring(18)}",
          back: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 95,
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
                          Marker(
                            markerId: const MarkerId("Rider Location"),
                            position: riderLocation,
                            infoWindow: const InfoWindow(title: "Rider"),
                          )
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: IconButton(
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
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if (order_data.id.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          sheetHeight -= details.primaryDelta!;
                          sheetHeight = sheetHeight.clamp(
                            30.0,
                            MediaQuery.of(context).size.height - 100,
                          );
                        });
                      },
                      onVerticalDragEnd: (details) {
                        if (sheetHeight < 200.0) {
                          sheetHeight = 30.0;
                        } else if (sheetHeight > 200.0 && sheetHeight < 350) {
                          sheetHeight = 350.0;
                        } else if (sheetHeight > 350) {
                          sheetHeight =
                              MediaQuery.of(context).size.height - 100;
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
                                child: !loading && order_data.rider == null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SpinKitThreeBounce(
                                              size: 20,
                                              color: accentColor,
                                            ),
                                            Text(
                                              "Looking for riders.",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              order_data.orderStatus.isEmpty
                                                  ? "Waiting for Rider to confirm"
                                                  : order_data.orderStatus
                                                              .length ==
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
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16),
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 25.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        child: Image.network(
                                                          order_data
                                                              .rider!.image,
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
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
                                                            order_data.rider!
                                                                .fullname,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            "#${order_data.rider!.id.substring(18)}",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  if (order_data.status !=
                                                      "delivered")
                                                    IconButton(
                                                      onPressed: () =>
                                                          _makePhoneCall(
                                                              order_data.rider!
                                                                  .mobileno),
                                                      icon: const Icon(
                                                          Icons.call),
                                                    ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  if (order_data.status !=
                                                      "delivered")
                                                    IconButton(
                                                      onPressed: () =>
                                                          _whatsapp(order_data
                                                              .rider!.mobileno),
                                                      icon: const Icon(
                                                          Icons.message),
                                                    )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            if (order_data.orderStatus.isEmpty)
                                              Text(
                                                "Waiting for rider to confirm",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            if (order_data
                                                .orderStatus.isNotEmpty)
                                              ...order_data.orderStatus
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (e) => Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 25.0,
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .radio_button_checked,
                                                                    color:
                                                                        accentColor,
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
                                                                      lineLength:
                                                                          45,
                                                                      lineThickness:
                                                                          2.0,
                                                                      dashLength:
                                                                          5.0,
                                                                      dashColor:
                                                                          Colors
                                                                              .black,
                                                                      dashRadius:
                                                                          4.0,
                                                                      dashGapLength:
                                                                          3.0,
                                                                      dashGapColor:
                                                                          Colors
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
                                                                        width: MediaQuery.of(
                                                                              context,
                                                                            ).size.width -
                                                                            50 -
                                                                            30 -
                                                                            15,
                                                                        child:
                                                                            Text(
                                                                          e.key == 0
                                                                              ? "Pickup Started"
                                                                              : e.key == 1
                                                                                  ? "Parcel Pickup Up"
                                                                                  : e.key < order_data.orderStatus.length - 1 && e.key > 1
                                                                                      ? "Parcel Dropped"
                                                                                      : "Order completed",
                                                                          style:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          softWrap:
                                                                              false,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(
                                                                              context,
                                                                            ).size.width -
                                                                            50 -
                                                                            30 -
                                                                            10,
                                                                        child:
                                                                            Text(
                                                                          e.value
                                                                              .message,
                                                                          style:
                                                                              GoogleFonts.poppins(
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          softWrap:
                                                                              false,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(
                                                                              context,
                                                                            ).size.width -
                                                                            50 -
                                                                            30 -
                                                                            10,
                                                                        child:
                                                                            Text(
                                                                          readTimestamp(e
                                                                              .value
                                                                              .timestamp),
                                                                          style:
                                                                              GoogleFonts.poppins(
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
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
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
