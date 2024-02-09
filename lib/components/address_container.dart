import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/screens/location_picker/places_autocomplete.dart';

class AddressContainer extends StatefulWidget {
  final int? index;
  final Address address;
  final String title;
  final String subtitle;
  final Function? handleClick;
  const AddressContainer({super.key, this.index, required this.address, required this.title, required this.subtitle, this.handleClick});

  @override
  State<AddressContainer> createState() => _AddressContainerState();
}

class _AddressContainerState extends State<AddressContainer> {
  @override
  Widget build(BuildContext context) {
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
                  widget.index == null ? "+" : (widget.index! + 1).toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if(widget.index != null )  Container(
              height: widget.address.text == "" ? 77.5 : widget.address.text.length > 35 ? 105 : 77.5 ,
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
              if(widget.index != null) {
                Get.to(
                () => PlacesAutoComplete(
                  latitude: widget.address.latitude,
                  longitude: widget.address.longitude,
                  text: widget.address.text,
                  index: widget.index!,
                ),
              );
              }else{
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
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.index != null && widget.address.text.isNotEmpty
                          ? widget.address.text
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
  }
}
