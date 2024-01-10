String capitalize({required String text}) {
  String capitalizedString =
      text[0].toUpperCase() + text.substring(1).toLowerCase();
  return capitalizedString;
}
