import 'package:image_picker/image_picker.dart';

class PickImage {
  const PickImage._();

  static Future<XFile?> fromGallery() async {
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }
}
