import 'dart:convert';
import 'package:http/http.dart' as http;

class DirectionsService {
  static const String apiKey = 'AIzaSyCQb159dbqJypdIO1a1o0v_mNgM5eFqVAo';

  Future<String> getDirections(double startLat, double startLng, double endLat, double endLng) async {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$apiKey'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['routes'][0]['overview_polyline']['points'];
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
