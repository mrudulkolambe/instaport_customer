import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/cloudinary_upload.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:instaport_customer/utils/validator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:instaport_customer/utils/image_modifier.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

enum FileSource {
  path,
  bytes,
}

class _EditProfileState extends State<EditProfile> {
  final _storage = GetStorage();
  final UserController userController = Get.put(UserController());
  final TextEditingController _fullnamecontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  bool loading = false;
  bool uploading = false;
  String image = "";

  @override
  void initState() {
    super.initState();
    handlePrefetch();
  }

  Future<bool> requestGalleryPermission() async {
    setState(() {
      uploading = true;
    });
    if (await Permission.storage.request().isGranted) {
      return true; // Permission already granted
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  final cloudinary = Cloudinary.unsignedConfig(
    cloudName: "dwd2fznsk",
  );

  Future<void> uploadToCloudinary(File imageFile) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/dwd2fznsk/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'pmoqxm8k'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response1 = await request.send();
    if (response1.statusCode == 200) {
      final responseData = await response1.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      var data = CloudinaryUpload.fromJson(jsonMap);
      setState(() {
        image = data.secureUrl;
      });
      var response = await cloudinary.unsignedUpload(
          uploadPreset: "pmoqxm8k", file: imageFile.path);
      setState(() {
        image = response.secureUrl == null ? "" : response.secureUrl!;
      });
      handleSave();
    } else {}
  }

  FileSource fileSource = FileSource.path;
  void onUploadSourceChanged(FileSource? value) =>
      setState(() => fileSource = value!);

  Future<void> getImage() async {
    bool permissionGranted = await requestGalleryPermission();
    if (permissionGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File pickedImageFile = File(image.path);
        int sizeInBytes = await pickedImageFile.length();
        double sizeInMB = sizeInBytes / (1024 * 1024);
        if (sizeInMB <= 5.0) {
          uploadToCloudinary(pickedImageFile);
        } else {
          File resizedImage =
              await resizeImage(File(image.path), maxSize: 1 * 1024 * 1024);
          uploadToCloudinary(resizedImage);
          ToastManager.showToast('Image size should be less than 1MB');
          setState(() {
            uploading = false;
          });
        }
      } else {
        setState(() {
          uploading = false;
        });
      }
    } else {
      setState(() {
        uploading = false;
      });
      openAppSettings();
      ToastManager.showToast('Permission to access gallery denied');
    }
    return;
  }

  void handleSave() async {
    setState(() {
      loading = true;
    });
    final token = await _storage.read("token");
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      };
      var request = http.Request('PATCH', Uri.parse('$apiUrl/user/update'));
      request.body = json.encode({
        "fullname": _fullnamecontroller.text,
        "mobileno": _phonecontroller.text,
        "image": image
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var profileData = UserDataResponse.fromJson(jsonDecode(data));
        userController.updateUser(profileData.user);
        ToastManager.showToast(profileData.message);
      } else {
        ToastManager.showToast(response.reasonPhrase!);
      }
      setState(() {
        uploading = false;
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void handlePrefetch() async {
    var token = await _storage.read("token");
    var response = await http.get(
      Uri.parse("$apiUrl/user/"),
      headers: {"Authorization": "Bearer $token"},
    );
    var user = UserDataResponse.fromJson(jsonDecode(response.body)).user;
    userController.updateUser(user);
    _fullnamecontroller.text = user.fullname;
    _phonecontroller.text = user.mobileno;
    image = user.image;
    setState(() {
      image = user.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          title: "Edit Profile",
          back: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          child: GetBuilder<UserController>(
              init: UserController(),
              builder: (usercontroller) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: getImage,
                              child: image != ""
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        image,
                                      ),
                                      radius: 70,
                                    )
                                  : Container(
                                      height: 140,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 4,
                                          color: accentColor,
                                        ),
                                        borderRadius: BorderRadius.circular(70),
                                      ),
                                    ),
                            ),
                            if (uploading)
                              Container(
                                height: 140,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                child: const CircularProgressIndicator(
                                  strokeCap: StrokeCap.butt,
                                  color: accentColor,
                                ),
                              )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          "Fullname: ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      controller: _fullnamecontroller,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black38),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 2, color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 2, color: accentColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Phone number: ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      validator: (value) => validatePhoneNumber(value!),
                      inputFormatters: [phoneNumberMask],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _phonecontroller,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your phone number",
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black38),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 2, color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 2, color: accentColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: handleSave,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          color: accentColor,
                          border: Border.all(
                            width: 2,
                            color: accentColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 25,
                          ),
                          child: Center(
                            child: loading
                                ? const SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    "Save",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                );
              }),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
