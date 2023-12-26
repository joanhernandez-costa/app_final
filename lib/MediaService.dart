import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:app_final/ApiCalls.dart';

class MediaService {
  static Future<void> pickImage(Function(String? url) onImageSelected) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String? url = await ApiCalls.uploadFileToStorage(File(pickedFile.path), basename(pickedFile.path));
      onImageSelected(url);
    }
  }
}