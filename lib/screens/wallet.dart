// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/components/transaction_card.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/constants/svgs.dart';
import 'package:instaport_customer/controllers/user.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/transaction_model.dart';
import 'package:instaport_customer/models/user_model.dart';
import 'package:instaport_customer/screens/home.dart';
import 'package:instaport_customer/screens/wallet_topup.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final UserController userController = Get.put(UserController());

  final _storage = GetStorage();
  List<Transaction> transactions = [];
  late Timer _timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    handleFetch(true);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      handleFetch(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void handleFetch(bool load) async {
    setState(() {
      if (load) {
        loading = true;
      } else {
        loading = false;
      }
    });
    final token = await _storage.read("token");
    final userdata = await http.get(Uri.parse('$apiUrl/user'),
        headers: {'Authorization': 'Bearer $token'});
    userController
        .updateUser(UserDataResponse.fromJson(jsonDecode(userdata.body)).user);
    final response = await http.get(
        Uri.parse("$apiUrl/customer-transactions/get"),
        headers: {'Authorization': 'Bearer $token'});
    TransactionResponse transactionResponse =
        TransactionResponse.fromJson(jsonDecode(response.body));
    setState(() {
      loading = false;
      transactions = transactionResponse.transactions;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          title: "My Wallet",
          back: () => Get.to(() => const Home()),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              GetBuilder<UserController>(
                  init: UserController(),
                  builder: (usercontroller) {
                    return Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width - 50,
                      decoration: BoxDecoration(
                        color: accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10.0,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(255, 226, 76, 0.65),
                            accentColor,
                            Color.fromRGBO(247, 192, 0, 1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Main Balance",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "₹${usercontroller.user.wallet.toPrecision(2)}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final token =
                                            await _storage.read("token");
                                        Get.to(() => WalletTopup(
                                              url:
                                                  "https://instaport-transactions.vercel.app/?token=$token",
                                            ));
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50 -
                                                45,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 10,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Top Up",
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Latest Transactions",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              loading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 300 - 150,
                      width: MediaQuery.of(context).size.width - 50,
                      child: const Center(
                        child: SpinKitFadingCircle(
                          color: accentColor,
                          size: 25,
                        ),
                      ),
                    )
                  : transactions.isEmpty
                      ? SizedBox(
                          height:
                              MediaQuery.of(context).size.height - 300 - 150,
                          width: MediaQuery.of(context).size.width - 50,
                          child: Center(
                            child: SvgPicture.string(noDataFoundSVG),
                          ),
                        )
                      : SizedBox(
                          height:
                              MediaQuery.of(context).size.height - 300 - 150,
                          width: MediaQuery.of(context).size.width - 50,
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) => TransactionCard(
                              data: transactions[index],
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                            itemCount: transactions.length,
                          ),
                        )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
