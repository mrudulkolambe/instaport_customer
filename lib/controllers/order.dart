import 'package:get/state_manager.dart';
import 'package:instaport_customer/controllers/address.dart';
import 'package:instaport_customer/models/address_model.dart';
import 'package:instaport_customer/models/order_model.dart';

AddressController addressController = AddressController();

class OrderController extends GetxController {
  var pastOrders = <Orders>[];

  var initialorder = Orders(
    pickup: addressController.pickup,
    drop: addressController.drop,
    id: "",
    delivery_type: "now",
    parcel_weight: "0-1 kg",
    phone_number: "",
    notify_sms: false,
    courier_bag: false,
    vehicle: "scooty",
    status: "new",
    payment_method: "cod",
    customer: "",
    package: "",
    time_stamp: 0,
    parcel_value: 0,
    amount: 0.0,
  );

  var currentorder = Orders(
    pickup: addressController.pickup,
    drop: addressController.drop,
    id: "",
    delivery_type: "now",
    parcel_weight: "0-1 kg",
    phone_number: "",
    notify_sms: false,
    courier_bag: false,
    vehicle: "scooty",
    status: "new",
    payment_method: "cod",
    customer: "",
    package: "",
    time_stamp: 0,
    parcel_value: 0,
    amount: 0.0,
  );

  void updateCurrentOrder(Orders data) {
    currentorder = data;
    update();
  }

  void updateOrders(List<Orders> orders) {
    pastOrders = orders;
    update();
  }

  void updateType(String type) {
    currentorder.delivery_type = type;
    update();
  }
  void updateWeight(String weight) {
    currentorder.parcel_weight = weight;
    update();
  }

  void updatePackage(String package) {
    currentorder.package = package;
    update();
  }

  void updatePackageValue(int value) {
    currentorder.parcel_value = value;
    update();
  }

  void updatePhoneNumber(String number) {
    currentorder.phone_number = number;
    update();
  }

  void updateVehicle(String vehicle) {
    currentorder.vehicle = vehicle;
    update();
  }

  void updateAmount(double amount) {
    currentorder.amount = amount;
    update();
  }

  void updateAddress(int type, Address address) {
    if (type == 0) {
      currentorder.pickup = address;
    } else if (type == 1) {
      currentorder.drop = address;
    }
    update();
  }

  void resetFields(){
    currentorder = initialorder;
    update();
  }
}
