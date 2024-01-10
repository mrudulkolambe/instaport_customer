import 'package:get/state_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppController extends GetxController {
  var currentposition = const CameraPosition(
    target: LatLng(
      37.42796133580664,
      -122.085749655962,
    ),
    zoom: 14.4746,
  ).obs;

  void updateCurrentPosition(CameraPosition position) {
    currentposition.value = position;
  }
}
