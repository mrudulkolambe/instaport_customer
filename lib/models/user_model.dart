class SignInResponse {
  bool error;
  String message;
  String token;

  SignInResponse({
    required this.error,
    required this.message,
    required this.token,
  });

  factory SignInResponse.fromJson(dynamic json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final token = json['token'] as String;
    return SignInResponse(
      error: error,
      message: message,
      token: token,
    );
  }
}

class UserDataResponse {
  bool error;
  String message;
  User user;

  UserDataResponse({
    required this.error,
    required this.message,
    required this.user,
  });

  factory UserDataResponse.fromJson(dynamic json) {
    final error = json['error'] as bool;
    final message = json['message'] as String;
    final user = User.fromJson(json['user']);
    return UserDataResponse(

      error: error,
      message: message,
      user: user,
    );
  }
}

class User {
  String fullname;
  String mobileno;
  String usecase;
  bool verified;
  String role;
  double wallet;

  User({
    required this.fullname,
    required this.mobileno,
    required this.usecase,
    required this.verified,
    required this.role,
    required this.wallet,
  });

  factory User.fromJson(dynamic json) {
    final fullname = json['fullname'] as String;
    final mobileno = json['mobileno'] as String;
    final usecase = json['usecase'] as String;
    final verified = json['verified'] as bool;
    final role = json['role'] as String;
    final wallet = json['wallet'] + 0.0;
    return User(
      fullname: fullname,
      mobileno: mobileno,
      usecase: usecase,
      verified: verified,
      role: role,
      wallet: wallet,
    );
  }
}
