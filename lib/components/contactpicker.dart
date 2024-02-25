import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:instaport_customer/utils/toast_manager.dart';

class ContactPickerWidget extends StatefulWidget {
  final TextEditingController textcontroller;

  const ContactPickerWidget({super.key, required this.textcontroller});

  @override
  State<ContactPickerWidget> createState() => _ContactPickerWidgetState();
}

class _ContactPickerWidgetState extends State<ContactPickerWidget> {
  void handlePermission() async {
    bool permissionGranted = await FlutterContacts.requestPermission();
    if (permissionGranted) {
      Contact? selectedContact = await FlutterContacts.openExternalPick();
      if (selectedContact != null) {
        widget.textcontroller.text = selectedContact.phones[0].normalizedNumber
                .startsWith("+91")
            ? "+91 ${selectedContact.phones[0].normalizedNumber.substring(3, 8)} ${selectedContact.phones[0].normalizedNumber.substring(8, 13)}"
            : "+91 ${selectedContact.phones[0].normalizedNumber.substring(0, 5)} ${selectedContact.phones[0].normalizedNumber.substring(5, 10)}";
      } else {
        widget.textcontroller.text = "";
      }
    } else {
      ToastManager.showToast("Permission denied!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: handlePermission,
      icon: const Icon(
        Icons.contacts_outlined,
        size: 20,
        // color: accentColor,
        weight: 1,
      ),
    );
  }
}
