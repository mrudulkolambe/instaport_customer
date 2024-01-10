class Transaction {
  double amount;
  int timestamp;
  String status;
  String payment_method;
  String id;
  bool debit;
  String type;

  Transaction(
      {required this.amount,
      required this.timestamp,
      required this.status,
      required this.payment_method,
      required this.id,
      required this.debit,
      required this.type});

  factory Transaction.fromJson(dynamic json) {
    final amount = json['amount'] + 0.0;
    final timestamp = json['timestamp'] as int;
    final status = json['status'] as String;
    final payment_method = json['payment_method_type'] as String;
    final id = json['_id'] as String;
    final debit = json['debit'] as bool;
    final type = json['type'] as String;

    return Transaction(
      amount: amount,
      timestamp: timestamp,
      status: status,
      payment_method: payment_method,
      id: id,
      debit: debit,
      type: type
    );
  }
  // factory Transaction.fromJson(dynamic json) {
  //   final items =
  //       List.from(json["order"]).map((e) => Orders.fromJson(e)).toList();
  //   final error = json['error'] as bool;
  //   final message = json['message'] as String;
  //   final orders = items;
  //   return PastOrderResponse(error: error, message: message, orders: orders);
  // }
}

class TransactionResponse {
  bool error;
  String message;
  List<Transaction> transactions;

  TransactionResponse({
    required this.error,
    required this.message,
    required this.transactions,
  });

  factory TransactionResponse.fromJson(dynamic json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final transactions = List.from(json["transactions"])
        .map((e) => Transaction.fromJson(e))
        .toList();

    return TransactionResponse(
      error: error,
      message: message,
      transactions: transactions,
    );
  }
}
