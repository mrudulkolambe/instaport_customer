String? validatePhoneNumber(String value) {
  if (value.isEmpty) {
    return 'Phone number is required';
  }
  if (value.length < 15) {
    return 'Enter a valid phone number';
  }
  return null;
}
