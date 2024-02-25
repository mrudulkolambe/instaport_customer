import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/screens/create_account.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/screens/home.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:instaport_customer/utils/validator.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _storage = GetStorage();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Text(
                    "Sign In",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Container(
              //       width: (MediaQuery.of(context).size.width - 50) / 2,
              //       height: 50,
              //       decoration: const BoxDecoration(
              //         borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(10),
              //           bottomLeft: Radius.circular(10),
              //         ),
              //         border: Border(
              //             bottom: BorderSide(width: 1, color: Colors.black),
              //             left: BorderSide(width: 1, color: Colors.black),
              //             top: BorderSide(width: 1, color: Colors.black),
              //             right: BorderSide(width: 0.5, color: Colors.black)),
              //         color: accentColor,
              //       ),
              //       child: Center(
              //           child: Text(
              //         "For Individuals",
              //         style: GoogleFonts.poppins(
              //           color: Colors.black,
              //           fontSize: 13,
              //         ),
              //       )),
              //     ),
              //     Container(
              //       width: (MediaQuery.of(context).size.width - 50) / 2,
              //       height: 50,
              //       decoration: const BoxDecoration(
              //         borderRadius: BorderRadius.only(
              //           topRight: Radius.circular(10),
              //           bottomRight: Radius.circular(10),
              //         ),
              //         border: Border(
              //           bottom: BorderSide(width: 1, color: Colors.black),
              //           right: BorderSide(width: 1, color: Colors.black),
              //           top: BorderSide(width: 1, color: Colors.black),
              //           left: BorderSide(width: 0.5, color: Colors.black),
              //         ),
              //         color: accentColor,
              //       ),
              //       child: Center(
              //         child: Text(
              //           "For Business",
              //           style: GoogleFonts.poppins(
              //             color: Colors.black,
              //             fontSize: 13,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 30,
              // ),
              Column(
                children: [
                  Column(
                    children: [
                      const Label(label: "Phone Number: "),
                      TextFormField(
                        validator: (value) => validatePhoneNumber(value!),
                        inputFormatters: [phoneNumberMask],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter your phone number",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                width: 2, color: Colors.black26),
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
                      const Label(label: "Password: "),
                      TextFormField(
                        controller: _passwordController,
                        style: GoogleFonts.poppins(
                            color: Colors.black, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Enter your Password",
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
                            borderSide: const BorderSide(
                              width: 2,
                              color: Colors.black26,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              width: 2,
                              color: accentColor,
                            ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Forget Password?",
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                            onTap: loading
                                ? null
                                : () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    const String url = '$apiUrl/user/signin';
                                    try {
                                      final response = await http.post(
                                        Uri.parse(url),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: jsonEncode({
                                          'mobileno': _phoneController.text,
                                          'password': _passwordController.text,
                                        }),
                                      );
                                      final data = SignInResponse.fromJson(
                                          json.decode(response.body));
                                      ToastManager.showToast(data.message);
                                      if (data.error) {
                                      } else {
                                        _storage.write("token", data.token);
                                        Get.to(() => const Home());
                                      }
                                      // ignore: empty_catches
                                    } catch (error) {}
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: accentColor,
                              ),
                              child: Center(
                                child: loading
                                    ? const SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 15,
                                      )
                                    : Text(
                                        "Sign In",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.to(() => const CreateAccount()),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.poppins(
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
