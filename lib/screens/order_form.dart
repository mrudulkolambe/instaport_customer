import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/bottomnavigationbar.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/screens/shipping_form.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final TextEditingController _parcelcontroller = TextEditingController();
  final TextEditingController _parcelvalue = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();

  OrderController orderController = Get.put(OrderController());
  AddressController addressController = Get.put(AddressController());
  void handlePreFetch() {
    _parcelcontroller.text = orderController.currentorder.package;
    _parcelvalue.text = orderController.currentorder.parcel_value.toString();
    _phonecontroller.text =
        orderController.currentorder.phone_number.toString();
  }

  @override
  void initState() {
    super.initState();
    handlePreFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const CustomAppBar(
          title: "Order Details",
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SafeArea(
        child: GetBuilder<OrderController>(
          init: OrderController(),
          builder: (ordercontroller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 20,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  const Label(label: "Package: "),
                  TextFormField(
                    controller: _parcelcontroller,
                    style:
                        GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                    onChanged: (String value) {
                      ordercontroller.updatePackage(value);
                    },
                    decoration: InputDecoration(
                      hintText: "What are you sending?",
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
                          vertical: 15, horizontal: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _parcelcontroller.text = "Documents";
                            ordercontroller.updatePackage("Documents");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: accentColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Documents",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _parcelcontroller.text = "Food";
                            ordercontroller.updatePackage("Food");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: accentColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Food",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _parcelcontroller.text = "Flowers";
                            ordercontroller.updatePackage("Flowers");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: accentColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Flowers",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _parcelcontroller.text = "Clothes";
                            ordercontroller.updatePackage("Clothes");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: accentColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Clothes",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Label(label: "Parcel value: "),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _parcelvalue,
                    onChanged: (String value) {
                      if (value == "") {
                        ordercontroller.updatePackageValue(0);
                      } else {
                        ordercontroller.updatePackageValue(int.parse(value));
                      }
                    },
                    style:
                        GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Enter the parcel value",
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
                  Text(
                    "Safeguard your valuable items so that you may recover the value in the event of loss or damage during delivery. For this service, we charge a fee of 0.85%+GST of the value you declared above (added to the shipping cost). Up to 50,000 allowed",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Label(label: "Phone number: "),
                  TextFormField(
                    controller: _phonecontroller,
                    onChanged: (String value) {
                      ordercontroller.updatePhoneNumber(value);
                    },
                    keyboardType: TextInputType.phone,
                    style:
                        GoogleFonts.poppins(color: Colors.black, fontSize: 14),
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
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const ShippingForm());
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: accentColor,
                      ),
                      child: Center(
                        child: Text(
                          "Continue",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
