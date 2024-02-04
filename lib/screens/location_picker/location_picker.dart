import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/components/contactpicker.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/screens/new_order.dart';

class LocationPicker extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String text;
  final int index;

  const LocationPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.text,
    required this.index,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  AddressController addressController = Get.put(AddressController());
  OrderController orderController = Get.put(OrderController());
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _instructioncontroller = TextEditingController();
  final TextEditingController _buildingcontroller = TextEditingController();
  final TextEditingController _floorcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void handleNext() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill the form')),
      );
    } else {
      var data = Address(
        text: widget.text,
        latitude: widget.latitude,
        longitude: widget.longitude,
        building_and_flat: _buildingcontroller.text,
        floor_and_wing: _floorcontroller.text,
        instructions: _instructioncontroller.text,
        phone_number: _phonecontroller.text,
        address: _addresscontroller.text,
        name: _namecontroller.text,
      );
      orderController.updateAddress(widget.index, data);
      if (widget.index == 0) {
        addressController.updateAddress("pickup", data);
      } else if (widget.index == 1) {
        addressController.updateAddress("drop", data);
      }
      Get.to(() => const Neworder());
    }
  }

  void handlePreFetch() {
    if (widget.index == 0 &&
        widget.latitude != 0.0 &&
        widget.longitude != 0.0) {
      setState(() {
        _phonecontroller.text = addressController.pickup.phone_number;
        _instructioncontroller.text = addressController.pickup.instructions;
        _addresscontroller.text = addressController.pickup.address;
        _buildingcontroller.text = addressController.pickup.building_and_flat;
        _floorcontroller.text = addressController.pickup.floor_and_wing;
        _namecontroller.text = addressController.pickup.name;
      });
    } else if (widget.index == 1) {
      setState(() {
        _phonecontroller.text = addressController.drop.phone_number;
        _instructioncontroller.text = addressController.drop.instructions;
        _addresscontroller.text = addressController.drop.address;
        _buildingcontroller.text = addressController.drop.building_and_flat;
        _floorcontroller.text = addressController.drop.floor_and_wing;
        _namecontroller.text = addressController.pickup.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    handlePreFetch();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const CustomAppBar(
            title: "Details",
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Label(label: "Name: "),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid name';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.name,
                          controller: _namecontroller,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your name",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black38,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Colors.red
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 2, color: accentColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Label(label: "Phone Number: "),
                        TextFormField(
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 10) {
                              return 'Invalid phone number';
                            }
                            return null;
                          },
                          controller: _phonecontroller,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: ContactPickerWidget(textcontroller: _phonecontroller),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your phone number",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black38),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Colors.red
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 2, color: accentColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Label(label: "Instructions: "),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          controller: _instructioncontroller,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter some instructions",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black38),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 2, color: accentColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Label(label: "Address: "),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid address';
                            }else if(value.length < 5){
                              return 'Address length should be atleast 5 characters long!';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          controller: _addresscontroller,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your address",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black38),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Colors.red
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 2, color: accentColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Label(label: "Building Name / Flat No: "),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _buildingcontroller,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your building name & flat no.",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black38),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 2, color: accentColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Label(label: "Floor / Wing: "),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          controller: _floorcontroller,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter your floor & wing.",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.black38),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.black.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  width: 2, color: accentColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: handleNext,
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: accentColor,
                        ),
                        child: Center(
                          child: Text(
                            "Next",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
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
