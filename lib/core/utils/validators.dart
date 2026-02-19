class Validators {
  const Validators._();

  static bool isRequired(String? value) =>
      value != null && value.trim().isNotEmpty;
}
