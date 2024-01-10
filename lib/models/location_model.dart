// class DistanceAPIResponse {
//   List<String> destination_addresses;
//   List<String> origin_addresses;
//   String status;
//   List data;

//   DistanceAPIResponse({
//     required this.destination_addresses,
//     required this.origin_addresses,
//     required this.token,
//   });

//   factory DistanceAPIResponse.fromJson(dynamic json) {
//     final error = json['error'] as bool;
//     final message = json['message'] as String;
//     final token = json['token'] as String;
//     return DistanceAPIResponse(
//       error: error,
//       message: message,
//       token: token,
//     );
//   }
// }

class DistanceApiResponse {
  List<String> destinationAddresses;
  List<String> originAddresses;
  List<RowElem> rows;
  String status;

  DistanceApiResponse({
    required this.destinationAddresses,
    required this.originAddresses,
    required this.rows,
    required this.status,
  });

  factory DistanceApiResponse.fromJson(dynamic json) {
    final destinationAddressList =
        List.from(json["destination_addresses"]).map((e) {
      return e.toString();
    }).toList();
    final originAddressList = List.from(json["origin_addresses"]).map((e) {
      return e.toString();
    }).toList();
    final rowList = List.from(json["rows"]).map((e) {
      return RowElem.fromJson(e);
    }).toList();
    final destinationAddresses = destinationAddressList;
    final originAddresses = originAddressList;
    final rows = rowList;
    final status = json['status'] as String;

    return DistanceApiResponse(
      destinationAddresses: destinationAddresses,
      originAddresses: originAddresses,
      rows: rows,
      status: status,
    );
  }
}

class RowElem {
  List<Element> elements;

  RowElem({
    required this.elements,
  });

  factory RowElem.fromJson(dynamic json) {
    final elements = List.from(json["elements"]).map((e) {
      return Element.fromJson(e);
    }).toList();

    return RowElem(
      elements: elements,
    );
  }
}

class Element {
  Distance distance;
  Distance duration;
  String status;

  Element({
    required this.distance,
    required this.duration,
    required this.status,
  });

  factory Element.fromJson(dynamic json) {
    final distance = Distance.fromJson(json['distance']);
    final duration = Distance.fromJson(json['duration']);
    final status = json['status'] as String;

    return Element(
      distance: distance,
      duration: duration,
      status: status,
    );
  }
}

class Distance {
  String text;
  double value;

  Distance({
    required this.text,
    required this.value,
  });

  factory Distance.fromJson(dynamic json) {
    final text = json['text'] as String;
    final double value = json['value'] + 0.0;

    return Distance(
      text: text,
      value: value,
    );
  }
}
