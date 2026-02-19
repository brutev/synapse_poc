class RegExValidation {
  const RegExValidation._();

  static bool match(String value, String pattern) =>
      RegExp(pattern).hasMatch(value);
}
