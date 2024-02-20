import 'package:intl/intl.dart';

String readTimestamp(int timestamp) {
  var format = DateFormat('d-MMM-yyyy, HH:mm');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return format.format(date);
}

String readTimestampAsDate(int timestamp) {
  var format = DateFormat('d-MMM-yyyy');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return format.format(date);
}

String readTimestampAsTime(int timestamp) {
  var format = DateFormat('HH:mm');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  print(timestamp);
  print(date);
  return format.format(date);
}
