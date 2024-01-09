import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MediaService {
  // Abre el navegador de archivos del dispositivo usado y devuelve el File elegido, lo recorta, lo comprime y lo sube.
  static Future<String?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('Archivo seleccionado válido');
      CroppedFile? _croppedFile = await cropImage(File(pickedFile.path));
      
      if (_croppedFile != null) {
        print('Archivo recortado');
        File? compressedFile = await compressFile(File(_croppedFile.path));

        if (compressedFile != null) {
          print('Archivo comprimido');
          String? url = await uploadFileToStorage(compressedFile, basename(pickedFile.path));
          return url;
        }
      }
    }
    return null;
  }

  // Comprime un archivo de imagen
  static Future<File?> compressFile(File file) async {
    final filePath = file.absolute.path;
    final targetPath = '${filePath.substring(0, filePath.lastIndexOf('.'))}_compressed.jpg';
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80, //Porcentaje de calidad respecto a la imagen original. Mantiene 80% de la calidad.
    );
    return compressedImage;
  }

  // Coge la imagen seleccionada y la encuadra en un preset
  static Future<CroppedFile?> cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recorta la imagen',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recorta la imagen',
        ),
      ],
    );
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