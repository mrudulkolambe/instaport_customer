class CloudinaryUpload {
  String assetId;
  String publicId;
  String url;
  String secureUrl;
  String folder;

  CloudinaryUpload({
    required this.assetId,
    required this.publicId,
    required this.url,
    required this.secureUrl,
    required this.folder,
  });
  factory CloudinaryUpload.fromJson(dynamic json) {
    final assetId = json["asset_id"] as String;
    final publicId = json["public_id"] as String;
    final url = json["url"] as String;
    final secureUrl = json["secure_url"] as String;
    final folder = json["folder"] as String;
    return CloudinaryUpload(
      assetId: assetId,
      publicId: publicId,
      url: url,
      secureUrl: secureUrl,
      folder: folder,
    );
  }
}
