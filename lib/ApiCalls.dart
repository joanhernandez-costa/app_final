import 'dart:convert';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/User.dart';
import 'package:http/http.dart' as http;
import 'package:app_final/Time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiCalls {
  static const int maxRetries = 3;
  static final String baseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static String? userToken;

  static Future<String> loadUserToken() async{
    return await SaveLoad.loadString("user_token");
  }

  static void updateUserToken(String token) {
    userToken = token;
    print(userToken);
  }

  static Future<List<T>> getAllItems<T>({int retries = 0, required T Function(Map<String, dynamic>) fromJson}) async {
    String tableUrl = _typeToTableUrl[T] ?? '';
    Uri uri = Uri.parse('$baseUrl/$tableUrl?select=*');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print('Obteniendo elementos...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('Elementos obtenidos correctamente. ${response.body}');
        List<T> items = (json.decode(response.body) as List)
          .map((itemJson) => fromJson(itemJson as Map<String, dynamic>))
          .toList();
        return items;
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        return await retryGettingItems(retries, fromJson);
      }
    } catch (e) {
      print('Excepción al obtener partidas: $e');
      return await retryGettingItems(retries, fromJson);
    }
  }

  static Future<AppUser?> getUserWithMail(String mail) async {
    Uri uri = Uri.parse('$baseUrl/rest/v1/users?select=*&mail=eq.$mail');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };
    
    print('Obteniendo usuario con correo: $mail');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return AppUser.fromJson(data[0]);
        }
      }
      print('Error: ${response.statusCode}. Respuesta: ${response.body}');
      return null;
    } catch (e) {
      print('Excepción en la petición GET: $e');
      return null;
    }
  }

  static Future<void> postItem<T>(T item, {int retries = 0, required Map<String, dynamic> Function(T) toJson}) async {
    String tableUrl = _typeToTableUrl[T] ?? '';
    Uri uri = Uri.parse('$baseUrl$tableUrl');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${userToken ?? dotenv.env['SUPABASE_SUPERKEY']}',
    };
    final jsonBody = jsonEncode(toJson(item));

    print('Enviando: $jsonBody');
    
    try {
      final response = await http.post(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 201) {
        print('Elemento enviado correctamente. ${response.body}');
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        retryPostingItem(item, toJson, retries);
      }
    } catch (e) {
      print('Excepción al enviar partida: $e');
      retryPostingItem(item, toJson, retries);
    }
  }

  static void retryPostingItem<T>(T item, Map<String, dynamic> Function(T) toJson, int retries) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await Time.waitForSeconds(2);
      await postItem(item, retries: retries + 1, toJson: toJson);
    } else {
      print('No se pudo enviar el elemento después de $maxRetries intentos.');
    }
  }

  static Future<List<T>> retryGettingItems<T>(int retries, T Function(Map<String, dynamic>) fromJson) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await Time.waitForSeconds(2);
      return await getAllItems(retries: retries + 1, fromJson: fromJson);
    } else {
      print('No se pudo obtener los elementos después de $maxRetries intentos.');
      List<T> emptyList = [];
      return emptyList;
    }
  }

  static const Map<Type, String> _typeToTableUrl = {
    AppUser: 'rest/v1/users',
    
  };
}

