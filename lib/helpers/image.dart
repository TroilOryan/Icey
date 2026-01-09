import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

class ImageHelper {
  Future<Uint8List?> selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return await image.readAsBytes();
    }

    return null;
  }
}
