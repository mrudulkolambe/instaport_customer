import 'package:get/state_manager.dart';
import 'package:instaport_customer/models/user_model.dart';

class UserController extends GetxController {
  User user = User(
    fullname: "",
    mobileno: "",
    usecase: "",
    verified: false,
    role: "customer",
    wallet: 0,
  );

  void updateUser(User data) {
    user = data;
    update();
  }
}
