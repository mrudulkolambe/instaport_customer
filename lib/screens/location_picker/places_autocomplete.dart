// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/app.dart';
import 'package:instaport_customer/models/places_model.dart';
import 'package:instaport_customer/screens/location_picker/location_picker.dart';
import 'package:instaport_customer/services/location_service.dart';

class PlacesAutoComplete extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String text;
  final int index;
  const PlacesAutoComplete({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.text,
    required this.index,
  });

  @override
  State<PlacesAutoComplete> createState() => _PlacesAutoCompleteState();
}

class _PlacesAutoCompleteState extends State<PlacesAutoComplete> {
  final TextEditingController _controller = TextEditingController();
  late GoogleMapController _googleMapController;
  List<Place> places = [];
  AppController appcontroller = Get.put(AppController());
  AddressController addressController = Get.put(AddressController());
  double lat = 0.0;
  double lng = 0.0;
  bool loading = true;
  bool placesLoading = true;
  bool bySearch = false;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
  }

  // @override
  // @mustCallSuper
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (widget.text.isNotEmpty) {
  //     _googleMapController.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //           target: LatLng(
  //             widget.latitude,
  //             widget.longitude,
  //           ),
  //           zoom: 14,
  //         ),
  //       ),
  //     );
  //   }
  // }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _onCameraIdle(double fetchLat, double fetchLng) async {
    setState(() {
      placesLoading = true;
    });
    var address =
        await LocationService().fetchAddress(LatLng(fetchLat, fetchLat));
    _controller.text = address;
    setState(() {
      lat = fetchLat;
      lng = fetchLng;
      loading = false;
      placesLoading = false;
      places = [];
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GetBuilder<AppController>(
          init: AppController(),
          builder: (appcrl) {
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 80,
                          child: GoogleMap(
                            liteModeEnabled: true,
                            zoomControlsEnabled: true,
                            markers: Set<Marker>.of(markers.values),
                            onCameraIdle: () {
                              // TODO: logic written for finding location or place details using latitude and longitude while draging the map.
                              // if (!bySearch) {
                              //   Future.delayed(const Duration(seconds: 1));
                              //   _onCameraIdle(
                              //     lat,
                              //     lng,
                              //   );
                              //   setState(() {
                              //     bySearch = false;
                              //   });
                              // }
                            },
                            onCameraMove: (position) {
                              setState(() {
                                lat = position.target.latitude;
                                lng = position.target.longitude;
                              });
                            },
                            onMapCreated: (controller) {
                              setState(() {
                                _googleMapController = controller;
                                if (widget.latitude != 0.0 &&
                                    widget.longitude != 0.0) {
                                  _controller.text = widget.text;
                                  _googleMapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(
                                          widget.latitude,
                                          widget.longitude,
                                        ),
                                        zoom: 14,
                                      ),
                                    ),
                                  );
                                } else {
                                  _googleMapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(
                                          appcrl.currentposition.value.target
                                              .latitude,
                                          appcrl.currentposition.value.target
                                              .longitude,
                                        ),
                                        zoom: 14,
                                      ),
                                    ),
                                  );
                                }
                              });
                              if (widget.text == "" ||
                                  widget.latitude == 0.0 ||
                                  widget.longitude == 0.0) {
                                Future.delayed(const Duration(seconds: 1));
                                _onCameraIdle(
                                  appcrl.currentposition.value.target.latitude,
                                  appcrl.currentposition.value.target.longitude,
                                );
                              } else {
                                _controller.text = widget.text;
                              }
                            },
                            initialCameraPosition: appcrl.currentposition.value,
                          ),
                        ),
                      ],
                    ),
                    Center(
                        child: Icon(
                      Icons.location_on_rounded,
                      size: 30,
                      color: Colors.red[600],
                    )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _focusNode,
                          controller: _controller,
                          onChanged: (String value) async {
                            if (_debounce?.isActive ?? false)
                              _debounce!.cancel();
                            _debounce = Timer(const Duration(milliseconds: 500),
                                () async {
                              final data = await LocationService()
                                  .fetchPlaces(_controller.text);
                              setState(() {
                                places = data;
                              });
                            });
                          },
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () => _controller.text = "",
                                icon: const Icon(Icons.clear_rounded)),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Search for places...",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black38),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 2, color: Colors.black26),
                            ),
                            border: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 2, color: Colors.black26),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 2, color: Colors.black26),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        places.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: places.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        iconColor: accentColor,
                                        title: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  places[index].description,
                                                  maxLines: 1,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        onTap: () async {
                                          final data = await LocationService()
                                              .fetchPlaceDetails(
                                            places[index].placeId,
                                          );
                                          _googleMapController.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: LatLng(
                                                  data.latitude,
                                                  data.longitude,
                                                ),
                                                zoom: 14,
                                              ),
                                            ),
                                          );
                                          _controller.text =
                                              places[index].description;
                                          if (_focusNode.hasFocus) {
                                            _focusNode.unfocus();
                                          }
                                          setState(() {
                                            lat = data.latitude;
                                            lng = data.longitude;
                                            bySearch = true;
                                            places = [];
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: IconButton(
                                onPressed: () {},
                                icon: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                placesLoading && _controller.text.isNotEmpty
                                    ? ()
                                    : Get.to(
                                        () => LocationPicker(
                                          latitude: lat,
                                          longitude: lng,
                                          text: _controller.text,
                                          index: widget.index,
                                        ),
                                      );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: placesLoading
                                      ? accentColor.withOpacity(0.7)
                                      : accentColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Continue",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      appcontroller.currentposition.value.target
                                          .latitude,
                                      appcontroller.currentposition.value.target
                                          .longitude,
                                    ),
                                    zoom: 14,
                                  ),
                                ),
                              ),
                              icon: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
