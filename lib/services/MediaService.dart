import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaService {
  // Abre el navegador de archivos del dispositivo usado y devuelve el File elegido, lo recorta, lo comprime y lo sube.
  static Future<String?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('Archivo seleccionado válido');
      
      String? url = await uploadFileToStorage(File(pickedFile.path), basename(pickedFile.path));
      return url;
    }
    return null;
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