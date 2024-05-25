import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaport_customer/components/contactpicker.dart';
import 'package:instaport_customer/components/label.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/main.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/places_model.dart';
import 'package:instaport_customer/screens/location_picker/places_autocomplete.dart';
import 'package:instaport_customer/services/location_service.dart';
import 'package:instaport_customer/utils/mask_fomatter.dart';
import 'package:instaport_customer/utils/timeformatter.dart';
import 'package:instaport_customer/utils/toast_manager.dart';
import 'package:instaport_customer/utils/validator.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:instaport_customer/screens/location_picker/location_picker.dart';

class AddressContainer extends StatefulWidget {
  final int index;
  final Address address;
  final String title;
  final String subtitle;
  final Function? handleClick;
  final double latitude;
  final double longitude;

  const AddressContainer({
    super.key,
    required this.index,
    required this.address,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.subtitle,
    this.handleClick,
  });

  @override
  State<AddressContainer> createState() => _AddressContainerState();
}

final Duration _debounceDuration = Duration(milliseconds: 500);

class _AddressContainerState extends State<AddressContainer> {
  AddressController addressController = AddressController();
  OrderController orderController = OrderController();

  final _debouncer = Debouncer(delay: _debounceDuration);

  void handlePreFetch() {
    if (widget.index == 0 &&
        widget.latitude != 0.0 &&
        widget.longitude != 0.0) {
      setState(() {
        _textcontroller.text = addressController.pickup.text;
        _phonecontroller.text = addressController.pickup.phone_number;
        _instructioncontroller.text = addressController.pickup.instructions;
        _addresscontroller.text = addressController.pickup.address;
        _buildingcontroller.text = addressController.pickup.building_and_flat;
        _floorcontroller.text = addressController.pickup.floor_and_wing;
        _namecontroller.text = addressController.pickup.name;
        _datecontroller.text = addressController.pickup.date ?? "";
        _fromtimecontroller.text = addressController.pickup.fromtime ?? "";
        _totimecontroller.text = addressController.pickup.totime ?? "";
      });
    } else if (widget.index == 1  &&
        widget.latitude != 0.0 &&
        widget.longitude != 0.0) {
      setState(() {
        _textcontroller.text = addressController.drop.text;
        _phonecontroller.text = addressController.drop.phone_number;
        _instructioncontroller.text = addressController.drop.instructions;
        _addresscontroller.text = addressController.drop.address;
        _buildingcontroller.text = addressController.drop.building_and_flat;
        _floorcontroller.text = addressController.drop.floor_and_wing;
        _namecontroller.text = addressController.drop.name;
        _datecontroller.text = addressController.drop.date ?? "";
        _fromtimecontroller.text = addressController.drop.fromtime ?? "";
        _totimecontroller.text = addressController.drop.totime ?? "";
      });
    } else if (widget.index >= 2  &&
        widget.latitude != 0.0 &&
        widget.longitude != 0.0) {
      _textcontroller.text =
          addressController.droplocations[widget.index - 2].text;
      _phonecontroller.text =
          addressController.droplocations[widget.index - 2].phone_number;
      _instructioncontroller.text =
          addressController.droplocations[widget.index - 2].instructions;
      _addresscontroller.text =
          addressController.droplocations[widget.index - 2].address;
      _buildingcontroller.text =
          addressController.droplocations[widget.index - 2].building_and_flat;
      _floorcontroller.text =
          addressController.droplocations[widget.index - 2].floor_and_wing;
      _namecontroller.text =
          addressController.droplocations[widget.index - 2].name;
      _datecontroller.text =
          addressController.droplocations[widget.index - 2].date ?? "";
      _fromtimecontroller.text =
          addressController.droplocations[widget.index - 2].fromtime ?? "";
      _totimecontroller.text =
          addressController.droplocations[widget.index - 2].totime ?? "";
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textcontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _instructioncontroller = TextEditingController();
  final TextEditingController _buildingcontroller = TextEditingController();
  final TextEditingController _floorcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _fromtimecontroller = TextEditingController();
  final TextEditingController _totimecontroller = TextEditingController();
  @override
  void dispose() {
    _datetimefocusnode.dispose();
    super.dispose();
  }

  void _removeFocus() {
    _datetimefocusnode.unfocus();
  }

  final FocusNode _datetimefocusnode = FocusNode();

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller,
    String type,
  ) async {
    DateTime selectedDateTime = DateTime.now();
    if (type == "date") {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        setState(() {
          controller.text =
              readTimestampAsDate(pickedDate.millisecondsSinceEpoch);
        });
      }
    } else if (type == "time") {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.inputOnly,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          controller.text =
              readTimestampAsTime(selectedDateTime.millisecondsSinceEpoch);
        });
      }
    }
  }

  List<Place> places = [];

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            physics: const BouncingScrollPhysics(),
            child: StatefulBuilder(builder: (context, setStateBuilder) {
              return Stack(children: [
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Label(label: "Google Address: "),
                          TextFormField(
                            onChanged: (value) async {
                              final data =
                                  await LocationService().fetchPlaces(value);
                              setStateBuilder(() {
                                places = data;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Invalid input';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            controller: _textcontroller,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: "Search your address",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.explore_outlined,
                                  color: Colors.black,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
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
                                    width: 2, color: Colors.red),
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
                            validator: (value) => validatePhoneNumber(value!),
                            inputFormatters: [phoneNumberMask],
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _phonecontroller,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: ContactPickerWidget(
                                textcontroller: _phonecontroller,
                              ),
                              fillColor: Colors.white,
                              filled: true,
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
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
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
                          if (orderController.currentorder.delivery_type ==
                              "scheduled")
                            const SizedBox(
                              height: 10,
                            ),
                          if (orderController.currentorder.delivery_type ==
                              "scheduled")
                            const Label(
                                label: "When to arrive at this address: "),
                          if (orderController.currentorder.delivery_type ==
                              "scheduled")
                            TextFormField(
                              validator: (value) {
                                if (orderController
                                        .currentorder.delivery_type ==
                                    "scheduled") {
                                  if (value == null || value.isEmpty) {
                                    return 'Invalid date';
                                  }
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [dateMask],
                              controller: _datecontroller,
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () => _selectDateTime(
                                    context,
                                    _datecontroller,
                                    "date",
                                  ),
                                  icon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Date",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.black.withOpacity(0.1)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.red),
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
                          if (orderController.currentorder.delivery_type ==
                              "scheduled")
                            const SizedBox(
                              height: 10,
                            ),
                          if (orderController.currentorder.delivery_type ==
                              "scheduled")
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (orderController
                                              .currentorder.delivery_type ==
                                          "scheduled") {
                                        if (value == null || value.isEmpty) {
                                          return 'Invalid time';
                                        }
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputFormatters: [timeMask],
                                    controller: _fromtimecontroller,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        onPressed: () => _selectDateTime(
                                            context,
                                            _fromtimecontroller,
                                            "time"),
                                        icon: const Icon(
                                          Icons.av_timer_rounded,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: "Enter your time range",
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black38,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            width: 2,
                                            color:
                                                Colors.black.withOpacity(0.1)),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 2, color: Colors.red),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            width: 2,
                                            color:
                                                Colors.black.withOpacity(0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color: accentColor,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (orderController
                                              .currentorder.delivery_type ==
                                          "scheduled") {
                                        if (value == null || value.isEmpty) {
                                          return 'Invalid time';
                                        }
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    inputFormatters: [timeMask],
                                    controller: _totimecontroller,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        onPressed: () => _selectDateTime(
                                            context, _totimecontroller, "time"),
                                        icon: const Icon(
                                          Icons.av_timer_rounded,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: "Enter your time range",
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black38,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            width: 2,
                                            color:
                                                Colors.black.withOpacity(0.1)),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 2, color: Colors.red),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            width: 2,
                                            color:
                                                Colors.black.withOpacity(0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color: accentColor,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Label(label: "Address: "),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Invalid address';
                              } else if (value.length < 5) {
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
                                    width: 2, color: Colors.red),
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
                                vertical: 15,
                                horizontal: 15,
                              ),
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
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                onTap: handleNext,
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: accentColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Submit",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (places.isNotEmpty)
                  ...places.map((e) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      child: ListTile(
                        iconColor: accentColor,
                        title: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  e.description,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () async {
                          final data =
                              await LocationService().fetchPlaceDetails(
                            e.placeId,
                          );
                          setStateBuilder(() {
                            latLng = LatLng(data.latitude, data.longitude);
                            _textcontroller.text = e.description;
                            places = [];
                          });
                        },
                      ),
                    );
                  }).toList(),
              ]);
            }),
          ),
        );
      },
    ).then((value) {});
  }

  LatLng latLng = LatLng(0.0, 0.0);
  void handleNext() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill the form')),
      );
    } else {
      print(_textcontroller.text);
      print(latLng.latitude);
      print(latLng.longitude);
      var uuid = const Uuid();
      String key = uuid.v1();
      var data = Address(
        text: _textcontroller.text,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        building_and_flat: _buildingcontroller.text,
        floor_and_wing: _floorcontroller.text,
        instructions: _instructioncontroller.text,
        phone_number: _phonecontroller.text,
        address: _addresscontroller.text,
        name: _namecontroller.text,
        date: _datecontroller.text,
        fromtime: _fromtimecontroller.text,
        totime: _totimecontroller.text,
        key: key,
      );
      orderController.updateAddress(widget.index, data);
      if (widget.index == 0) {
        addressController.updateAddress("pickup", data);
      } else if (widget.index == 1) {
        addressController.updateAddress("drop", data);
      } else {
        addressController.updateDropLocation(widget.index - 2, data);
      }
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(
        init: AddressController(),
        builder: (controller) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        widget.index < 0 ? "+" : (widget.index + 1).toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (widget.index >= 0)
                    Container(
                      height: widget.address.text == ""
                          ? 77.5
                          : widget.address.text.length > 35
                              ? 105
                              : 77.5,
                      width: 2,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (widget.index >= 0) {
                      Get.to(
                        () => LocationPicker(
                          index: widget.index,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          text: widget.subtitle ==   "Add a drop address for the courier" ? "" : widget.subtitle,
                        ),
                      );
                    } else {
                      widget.handleClick!();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      border: Border.all(
                        width: 2,
                        color: accentColor,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.index >= 2)
                                GestureDetector(
                                  onTap: () {
                                    controller.removeDropLocation(widget.index - 2);
                                  },
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.index >= 0 && _textcontroller.text.isNotEmpty
                                ? _textcontroller.text
                                : widget.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }
}
