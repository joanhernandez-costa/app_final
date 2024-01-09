import 'dart:convert';
import 'package:app_final/models/AppUser.dart';
import 'package:http/http.dart' as http;
import 'package:app_final/services/TimeService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const int maxRetries = 3;
  static final String baseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static String? userToken;

  // Lee todos los registros de una tabla cualquiera, especificar tipo 'T'. (Solo acepta tipos que tengan una tabla en SupaBase).
  static Future<List<T>> getAllItems<T>({int retries = 0, required T Function(Map<String, dynamic>) fromJson}) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';

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

  // Lee un registro genérico a partir de su identificador.
  static Future<T?> getItem<T>(String itemId, T Function(Map<String, dynamic>) fromJson) async {    
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';
    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$itemId');
    
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer $userToken',
    };

    print('Obteniendo $T...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('$T obtenido correctamente. Respuesta: ${response.body}');
        final data = jsonDecode(response.body);
        return data.length <= 0 ? null : fromJson(data[0]);   
      } else {
        throw Exception('Error al obtener $T: ${response.statusCode}. Respuesta: ${response.body}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> deleteItem<T>(String itemId) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';
    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$itemId');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer $userToken',
    };

    print('Eliminando $T...');

    try {
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('$T eliminado correctamente.');
      } else {
        throw Exception('Error al eliminar $T: ${response.statusCode}. Respuesta: ${response.body}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Inserta un registro en una tabla cualquiera. Especificar tipo 'T'. (Solo acepta tipos que tengan una tabla en SupaBase)
  static Future<void> postItem<T>(T item, {int retries = 0, required Map<String, dynamic> Function(T) toJson}) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';

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

  // Reintento de conexión Post a tabla genérica.
  static void retryPostingItem<T>(T item, Map<String, dynamic> Function(T) toJson, int retries) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await TimeService.waitForSeconds(2);
      await postItem(item, retries: retries + 1, toJson: toJson);
    } else {
      print('No se pudo enviar el elemento después de $maxRetries intentos.');
    }
  }

  // Reintento de conexión Get a tabla genérica.
  static Future<List<T>> retryGettingItems<T>(int retries, T Function(Map<String, dynamic>) fromJson) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await TimeService.waitForSeconds(2);
      return await getAllItems(retries: retries + 1, fromJson: fromJson);
    } else {
      print('No se pudo obtener los elementos después de $maxRetries intentos.');
      List<T> emptyList = [];
      return emptyList;
    }
  }

  // Método para actualizar un registro genérico de una tabla genérica.
  static Future<void> updateElement<T>(T updatedItem, String updatedItemId) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';

    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$updatedItemId');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer $userToken',
    };
    final jsonBody = jsonEncode(updatedItem);

    print('Actualizando $T a: $jsonBody');

    try {
      final response = await http.patch(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('$T actualizado correctamente.');
      } else {
        print('Error al actualizar $T: ${response.statusCode}. Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Excepción al actualizar $T: $e');
    }
  }

  // Mapea: tipo 'T' => URL de la tabla que almacena T en la base de datos y el nombre de su clave primaria.
  static const Map<Type, Map<String, String>> typeToTableData = {
    AppUser: {
      'url': '/rest/v1/users',
      'primaryKey': 'user_id'
    },
    // Añadir más tipos aquí
  };
}

