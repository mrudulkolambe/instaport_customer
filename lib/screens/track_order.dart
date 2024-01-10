// ignore_for_file: empty_catches, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaport_customer/api/orders.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/controllers/app.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/order_model.dart';
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

  Future<CameraPosition> _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return CameraPosition(
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: 14.14,
    );
  }

  Orders order_data = Orders(
    pickup: Address(
      text: "",
      latitude: 0.0,
      longitude: 0.0,
      building: "",
      flatno: "",
      floor: "",
      instructions: "",
      phone_number: "",
      address: "",
      zipcode: "",
    ),
    drop: Address(
      text: "",
      latitude: 0.0,
      longitude: 0.0,
      building: "",
      flatno: "",
      floor: "",
      instructions: "",
      phone_number: "",
      address: "",
      zipcode: "",
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
    print("Token: $token");
    if (token != null) {
      // setState(() {
      //   loading = true;
      // });
      String url = '$apiUrl/order/customer_app/${widget.data.id}';
      try {
        print("data.message");
        final response = await http
            .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
        final data = OrderResponse.fromJson(json.decode(response.body));
        if (data.error) {
          print(data.message);
        } else {
          setState(() {
            print(data.order.amount);
            order_data = data.order;
          });
          markersAndPolylines(data.order);
        }
      } catch (error) {
        print(error);
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
    getOrderById();
    // _getCurrentLocation();
  }

  void _initializeMap() async {
    newgooglemapcontroller = await _mapControllerCompleter.future;
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
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    key: _mapKey,
                    polylines: _polylineSet,
                    markers: _markers,
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
                        getOrderById();
                      }
                      newgooglemapcontroller = controller;
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
                                    LatLng(order_data.drop.latitude,
                                        order_data.drop.longitude));
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
              height: MediaQuery.of(context).size.height * 0.34,
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
                  : Container(
                      height: 20,
                      width: 20,
                      color: accentColor,
                    ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
