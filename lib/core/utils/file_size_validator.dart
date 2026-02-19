class FileSizeValidator {
  const FileSizeValidator._();

  static bool isWithinLimit(int bytes, {int maxMb = 5}) =>
      bytes <= maxMb * 1024 * 1024;
}
