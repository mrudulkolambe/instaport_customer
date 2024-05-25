import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/screens/login.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:instaport_customer/utils/validator.dart';
import 'package:http/http.dart' as http;

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String type = "individual";
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 35.0,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontSize: 32),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          type = "individual";
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          border: const Border(
                              bottom: BorderSide(width: 1, color: Colors.black),
                              left: BorderSide(width: 1, color: Colors.black),
                              top: BorderSide(width: 1, color: Colors.black),
                              right:
                                  BorderSide(width: 0.5, color: Colors.black)),
                          color:
                              type == "individual" ? accentColor : Colors.white,
                        ),
                        child: Center(
                            child: Text(
                          "For Individuals",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          type = "business";
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: const Border(
                              bottom: BorderSide(width: 1, color: Colors.black),
                              right: BorderSide(width: 1, color: Colors.black),
                              top: BorderSide(width: 1, color: Colors.black),
                              left:
                                  BorderSide(width: 0.5, color: Colors.black)),
                          color:
                              type == "business" ? accentColor : Colors.white,
                        ),
                        child: Center(
                            child: Text(
                          "For Business",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    Column(
                      children: [
                        const Label(label: "Full Name: "),
                        TextFormField(
                          controller: _namecontroller,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          validator: (value) {
                            if (value!.length < 2) {
                              return "Invalid Name";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: "Enter your full name",
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
                              borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1),
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
                              horizontal: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Label(label: "Phone Number: "),
                        TextFormField(
                          controller: _phonecontroller,
                          validator: (value) => validatePhoneNumber(value!),
                          inputFormatters: [phoneNumberMask],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.black.withOpacity(0.1),
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
                              horizontal: 15,
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
                            color: Colors.black,
                            fontSize: 13,
                          ),
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
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.black.withOpacity(0.1),
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
                              horizontal: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
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
                                      const String url = '$apiUrl/user/signup';
                                      try {
                                        final response = await http.post(
                                          Uri.parse(url),
                                          headers: {
                                            'Content-Type': 'application/json'
                                          },
                                          body: jsonEncode({
                                            'mobileno': _phonecontroller.text,
                                            'password':
                                                _passwordController.text,
                                            'fullname': _namecontroller.text,
                                            'usecase': type,
                                          }),
                                        );
                                        final data = SignInResponse.fromJson(
                                            json.decode(response.body));
                                        ToastManager.showToast(data.message);
                                        setState(() {
                                          loading = false;
                                        });
                                        if (data.error) {
                                          print(data.message);
                                        } else {
                                          Get.to(() => const Login());
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
                                  child: Text(
                                    "Sign Up",
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
                              "Already have an account? ",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(() => const Login()),
                              child: Text(
                                "Login",
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
      ),
    );
  }
}
