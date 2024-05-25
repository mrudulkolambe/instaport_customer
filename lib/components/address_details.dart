// ignore_for_file: deprecated_member_use, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/order_model.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/app.dart';
import 'package:instaport_customer/utils/timeformatter.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressDetailsScreen extends StatefulWidget {
  final Address address;
  final String title;
  final int time;
  final int index;
  final bool scheduled;
  final List<OrderStatus> orderStatus;
  final Address? paymentAddress;
  final String type;
  final String status;
  final double amount;

  const AddressDetailsScreen({
    super.key,
    required this.address,
    required this.title,
    required this.time,
    required this.orderStatus,
    required this.scheduled,
    required this.index,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentAddress,
  });

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchUrl(LatLng src, LatLng dest) async {
    final String url =
        "https://www.google.com/maps/dir/?api=1&origin=${src.latitude},${src.longitude}&destination=${dest.latitude},${dest.longitude}&travelmode=motorcycle&avoid=tolls&units=imperial&language=en&departure_time=now";
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  AppController appController = Get.put(AppController());
  final int minute = 60000;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.orderStatus.where(
              (element) {
                return element.key == widget.address.key;
              },
            ).isNotEmpty
                ? const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                  )
                : Text(
                    "${widget.index + 1}.",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(
              width: 4,
            ),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name: ",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.address.name,
              style: GoogleFonts.poppins(),
              softWrap: true,
            )
          ],
        ),
        const SizedBox(
          height: 3,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Map: ",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
            ),
            SelectableText(
              onTap: () => _launchUrl(
                LatLng(appController.currentposition.value.target.latitude,
                    appController.currentposition.value.target.longitude),
                LatLng(widget.address.latitude, widget.address.longitude),
              ),
              widget.address.text,
              style: GoogleFonts.poppins(),
              // softWrap: true,
            )
          ],
        ),
        const SizedBox(
          height: 3,
        ),
        if (widget.status != "delivered")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone Number: ",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              GestureDetector(
                onTap: () => _makePhoneCall(
                  widget.address.phone_number,
                ),
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  width: MediaQuery.of(context).size.width - 2 * 25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: accentColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.call_rounded,
                        color: accentColor,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      SelectableText(
                        widget.address.phone_number,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(
          height: 3,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Address: ",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
            ),
            SelectableText(
              widget.address.address,
              style: GoogleFonts.poppins(),
            )
          ],
        ),
        if (widget.address.building_and_flat.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                "Building / Flat: ",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SelectableText(
                widget.address.building_and_flat,
                style: GoogleFonts.poppins(),
              )
            ],
          ),
        if (widget.address.floor_and_wing.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                "Floor / Wing: ",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SelectableText(
                widget.address.floor_and_wing,
                style: GoogleFonts.poppins(),
              )
            ],
          ),
        if (widget.scheduled)
          const SizedBox(
            height: 5,
          ),
        if (widget.scheduled)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "When to arrive at address: ",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
                softWrap: true,
              ),
              Text(
                "${widget.address.date} : From: ${widget.address.fromtime} - To: ${widget.address.totime}",
                style: GoogleFonts.poppins(),
                softWrap: true,
              )
            ],
          ),
        if (!widget.scheduled)
          const SizedBox(
            height: 5,
          ),
        if (!widget.scheduled)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Time: ",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                ),
                softWrap: true,
              ),
              Text(
                widget.title == "Pickup"
                    ? "From: ${readTimestampAsTime(widget.time)} - To: ${readTimestampAsTime(widget.time + 45 * minute)}"
                    : "From: ${readTimestampAsTime(
                        widget.time + 45 * minute,
                      )} - To: ${readTimestampAsTime(
                        widget.time + 60 * minute * widget.index + 45 * minute,
                      )}",
                style: GoogleFonts.poppins(),
                softWrap: true,
              )
            ],
          ),
        if (widget.status != "delivered")
          const SizedBox(
            height: 5,
          ),
        const SizedBox(
          height: 5,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Instructions: ",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
              softWrap: true,
            ),
            Text(
              widget.address.instructions,
              style: GoogleFonts.poppins(),
              softWrap: true,
            )
          ],
        ),
        // if (widget.type == "cod" &&
        //     widget.paymentAddress != null &&
        //     widget.address.key == widget.paymentAddress!.key)
        //   Text(
        //     "Collect Rs. ${widget.amount.toPrecision(2)} from here.",
        //     style: GoogleFonts.poppins(
        //       fontSize: 14,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
      ],
    );
  }
}
