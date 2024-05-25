import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/direction_response_model.dart';
import 'package:instaport_customer/models/location_model.dart';
import 'package:instaport_customer/models/places_model.dart';

class LocationService {
  static String key = "AIzaSyDz11oR0kxuuNQFW9RqQYJ5NnOsfi_OGZ4";

  Future<List<Place>> fetchPlaces(String input) async {
    final String endpoint =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$key&components=country:in';
    print(endpoint);
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final predictions =
          jsonDecode(response.body)['predictions'] as List<dynamic>;
      List<Place> places = predictions.map((prediction) {
        return Place.fromJson(prediction);
      }).toList();
      return places;
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<LocationData> fetchPlaceDetails(String placeId) async {
    final String detailsEndpoint =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,formatted_address&key=$key';
    final response = await http.get(Uri.parse(detailsEndpoint));
    if (response.statusCode == 200) {
      final result = json.decode(response.body)['result'];
      final location = result['geometry']['location'];
      return LocationData.fromJson(location);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<String> fetchAddress(LatLng latlng) async {
    final String detailsEndpoint =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latlng.latitude},${latlng.longitude}&key=$key';
    final response = await http.get(Uri.parse(detailsEndpoint));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result["status"] == "REQUEST_DENIED" || result["status"] == "ZERO_RESULTS") {
        return "";
      } else {
        return result["results"][0]["formatted_address"];
      }
    } else {
      return "";
    }
  }

  Future<DistanceApiResponse> fetchDistance(
      double srclat, double srclng, double destlat, double destlng) async {
    String pickupEncoded = '$srclat,$srclng';
    String dropEncoded = '$destlat,$destlng';
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$pickupEncoded&origins=$dropEncoded&key=$key';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = DistanceApiResponse.fromJson(jsonDecode(response.body));
      return data;
    } else {
      throw Exception('Failed to load data from Distance Matrix API');
    }
  }

  Future<DirectionDetailsInfo> fetchDirections(double srclat, double srclng,
      double destlat, double destlng, List<Address> droplocations) async {
    String endpoint = "";
    try {
      if (droplocations.isEmpty) {
        endpoint =
            'https://maps.googleapis.com/maps/api/directions/json?origin=$srclat,$srclng&destination=$destlat,$destlng&key=$key';
      } else {
        final List<String> waypoints = [];
        waypoints.add('$destlat,$destlng');
        for (var i = 0; i < droplocations.length; i++) {
          waypoints.add(
              '${droplocations[i].latitude},${droplocations[i].longitude}');
        }
        waypoints.removeLast();
        var waypointsString = waypoints.join('|');
        endpoint =
            'https://maps.googleapis.com/maps/api/directions/json?origin=$srclat,$srclng&destination=${droplocations.last.latitude},${droplocations.last.longitude}&waypoints=optimize:true|$waypointsString&key=$key';
      }
      var response = await http.get(Uri.parse(endpoint));
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        DirectionDetailsInfo directionInfo = DirectionDetailsInfo();
        directionInfo.e_points =
            data["routes"][0]["overview_polyline"]["points"];
        directionInfo.distance_text =
            data["routes"][0]["legs"][0]["distance"]["text"];
        directionInfo.distance_value =
            data["routes"][0]["legs"][0]["distance"]["value"] + 0.0;
        directionInfo.duration_value =
            data["routes"][0]["legs"][0]["duration"]["value"] + 0.0;
        directionInfo.duration_text =
            data["routes"][0]["legs"][0]["duration"]["text"];
        return directionInfo;
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      throw Exception("Error This: $e");
    }
  }
}
