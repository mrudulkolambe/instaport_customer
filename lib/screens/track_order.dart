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
import 'package:url_launcher/url_launcher.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/controllers/app.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:instaport_customer/models/rider_location_model.dart';
import 'package:instaport_customer/services/location_service.dart';

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

    // newgooglemapcontroller.animateCamera(
    //   CameraUpdate.newCameraPosition(
    //     CameraPosition(
    //       target: LatLng(
    //         order.pickup.latitude,
    //         order.pickup.longitude,
    //       ),
    //       zoom: 14.14,
    //     ),
    //   ),
    // );
    final directionData = await LocationService().fetchDirections(
      order.pickup.latitude,
      order.pickup.longitude,
      order.drop.latitude,
      order.drop.longitude,
    );
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
    funcmarkers.add(pickupmarker);
    funcmarkers.add(dropmarker);
    funcpolyline.add(polyline);

    setState(() {
      // _mapKey = UniqueKey();
      _markers = funcmarkers;
      _polylineSet = funcpolyline;
    });
    repositionGoogleMaps(LatLng(order.pickup.latitude, order.pickup.longitude),
        LatLng(order.drop.latitude, order.drop.longitude));
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
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
    newgooglemapcontroller
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
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
      print("This is order data: ${response.body}");

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
      // final snapshot = await ref.child('rider/${data.order.rider!.id}').get();
      // if (snapshot.exists) {
      //   final dynamic snapshotValue = json.encode(snapshot.value);
      //   print(snapshotValue);
      //   if (snapshotValue != null) {
      //     final data = RiderLocation.fromJson(jsonDecode(snapshotValue));
      //     setState(() {
      //       riderLocation = LatLng(data.latitude, data.longitude);
      //     });
      // }
      // } else {
      // print('No data available.');
      // }
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
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    compassEnabled: true,
                    trafficEnabled: true,
                    mapToolbarEnabled: false,
                    key: _mapKey,
                    polylines: _polylineSet,
                    markers: {
                      ..._markers,
                      Marker(
                          markerId: const MarkerId("Rider Location"),
                          position: riderLocation,
                          infoWindow: const InfoWindow(title: "Rider"))
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
                        mainAxisAlignment: MainAxisAlignment.end,
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
                                backgroundColor: MaterialStateColor.resolveWith(
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
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5 - 100,
              child: !loading && order_data.rider == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            "Your parcel is on the way",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const Divider(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        order_data.rider!.image,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      order_data.rider!.fullname,
                                      style: GoogleFonts.poppins(),
                                    )
                                  ],
                                ),
                                if (order_data.status != "delivered")
                                  IconButton(
                                    onPressed: () => _makePhoneCall(
                                        order_data.rider!.mobileno),
                                    icon: const Icon(Icons.call),
                                  )
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
