import 'package:get/get.dart';
import 'package:instaport_customer/models/address_model.dart';

class AddressController extends GetxController {
  var initialaddress = Address(
    text: "",
    latitude: 0.0,
    longitude: 0.0,
    building_and_flat: "",
    floor_and_wing: "",
    instructions: "",
    phone_number: "",
    address: "",
    name: "",
    key: ""
  );
  var pickup = Address(
    text: "",
    latitude: 0.0,
    longitude: 0.0,
    building_and_flat: "",
    floor_and_wing: "",
    instructions: "",
    phone_number: "",
    address: "",
    name: "",
    key: ""
  );
  var drop = Address(
    text: "",
    latitude: 0.0,
    longitude: 0.0,
    building_and_flat: "",
    floor_and_wing: "",
    instructions: "",
    phone_number: "",
    address: "",
    name: "",
    key: ""
  );

  List<Address> droplocations = [];

  void updateDropLocation(int index, Address updatedLocation) {
    droplocations[index] = updatedLocation;
    update();
  }

  void updateDropLocationArray(List<Address> updatedLocations) {
    droplocations = updatedLocations;
    update();
  }

  void addNewDropLocation(Address address) {
    droplocations.add(address);
    update();
  }

  void removeDropLocation(int index) {
    final AddressController addressController = Get.find();
    if (index >= 0 && index < addressController.droplocations.length) {
      addressController.droplocations.removeAt(index);
      update();
    }
  }

  void updateAddress(String type, Address data) {
    if (type == "pickup") {
      pickup = data;
    } else if (type == "drop") {
      drop = data;
    }
    update();
  }

  void resetfields() {
    pickup = initialaddress;
    drop = initialaddress;
    droplocations = [];
    update();
  }
}

// void updateModel({
//     String? text,
//     double? latitude,
//     double? longitude,
//     String? building,
//     String? floor,
//     String? flatno,
//     String? instructions,
//     String? phone_number,
//   }) {
//     pickup.value.building = building ?? pickup.value.building;
//     pickup.value.latitude = latitude ?? pickup.value.latitude;
//     pickup.value.longitude = longitude ?? pickup.value.longitude;
//     pickup.value.floor = floor ?? pickup.value.floor;
//     pickup.value.text = text ?? pickup.value.text;
//     pickup.value.flatno = flatno ?? pickup.value.flatno;
//     pickup.value.instructions = instructions ?? pickup.value.instructions;
//     pickup.value.phone_number = phone_number ?? pickup.value.phone_number;
//     update();
//   }