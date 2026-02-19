class FileExtensionUtils {
  const FileExtensionUtils._();

  static String extension(String path) => path.split('.').last;
}
