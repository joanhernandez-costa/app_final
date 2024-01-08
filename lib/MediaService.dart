import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaService {
  static Future<void> pickImage(Function(String? url) onImageSelected) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String? url = await uploadFileToStorage(File(pickedFile.path), basename(pickedFile.path));
      onImageSelected(url);
    }
  }

  // Método para subir archivos a Supabase Storage
  static Future<String?> uploadFileToStorage(File file, String path) async {
    String fileName = basename(path);
    final storageResponse = await Supabase.instance.client.storage
        .from('app_final_bucket')
        .upload(fileName, file);
    if (storageResponse.isNotEmpty) {
      // Retorna la URL pública del archivo subido
      return Supabase.instance.client.storage
          .from('app_final_bucket')
          .getPublicUrl(path);
    } else {
      print('Error al subir archivo: $storageResponse');
      return null;
    }
  }
}