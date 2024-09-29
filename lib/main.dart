import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaport_customer/components/permissiondialog.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/constants/svgs.dart';
import 'package:instaport_customer/controllers/app.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/screens/home.dart';
import 'package:instaport_customer/screens/login.dart';
import 'package:get_storage/get_storage.dart';
import 'package:instaport_customer/screens/verification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// const apiUrl = "http://192.168.0.105:1000";
const apiUrl = "https://instaport-backend-main.vercel.app";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        builder: FToastBuilder(),
      title: 'Instaport Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: accentColor),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppController appController = Get.put(AppController());
  final UserController userController = Get.put(UserController());

  void getPermissions() async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      _getCurrentLocation();
      print('Location permission granted');
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      print('Location permission denied or permanently denied');
      Get.dialog(const PermissionDialog());
    }
  }

  final _storage = GetStorage();
  @override
  void initState() {
    Future.delayed(
        const Duration(
          seconds: 2,
        ), () {
      _isAuthed();
    });
    // _getCurrentLocation();
    super.initState();
  }

  void _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    appController.updateCurrentPosition(
      CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 14.14),
    );
  }

  Future<void> _isAuthed() async {
    final token = await _storage.read("token");
    getPermissions();
    print("token");
    print(token);
    if (token.toString() == "" || token == null) {
      Get.to(() => const Login());
    } else {
      final data = await http.get(Uri.parse('$apiUrl/user'),
          headers: {'Authorization': 'Bearer $token'});
      final userData = UserDataResponse.fromJson(jsonDecode(data.body));
      userController.updateUser(userData.user);
      if(userData.user.verified){
      Get.to(() => const Home());
      }else{
      Get.to(() => const Verification());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.string(splash_screen),
            const SpinKitFadingCircle(
              color: accentColor,
              size: 40,
            )
          ],
        ),
      ),
    );
  }
}
