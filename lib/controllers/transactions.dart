import 'package:get/state_manager.dart';
import 'package:instaport_customer/models/transaction_model.dart';

class TransactionController extends GetxController {
  List<Transaction> transactions = [];

  void update123(List<Transaction> data) {
    transactions = data;
    update();
  }
}
