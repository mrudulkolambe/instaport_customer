import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

Future<File> resizeImage(File imageFile, {required int maxSize}) async {
  img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
  if (image == null) {
    throw Exception('Failed to decode image');
  }

  int width = image.width;
  int height = image.height;
  double ratio = 1.0;

  if (image.length > maxSize) {
    ratio = maxSize / image.length;
    width = (width * ratio).round();
    height = (height * ratio).round();
  }

  img.Image resizedImage = img.copyResize(image, width: width, height: height);

  List<int> resizedBytes = img.encodeJpg(resizedImage, quality: 100);
  return File.fromRawPath(Uint8List.fromList(resizedBytes));
}
