import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_final/Time.dart';

class ApiCalls {
  static const int maxRetries = 3;
  static const String baseUrl = 'https://nkmqlnfejowcintlfspl.supabase.co';

  static Future<bool> getAllItems<T>({int retries = 0, required T Function(Map<String, dynamic>) fromJson}) async {
    Uri uri = Uri.parse('$baseUrl?select=*');
    final headers = {
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5rbXFsbmZlam93Y2ludGxmc3BsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY5NjMxNzM3NiwiZXhwIjoyMDExODkzMzc2fQ.nFOJiBzM2VYJ_aEpv6WoPhtMBjdIiAZtcR1ckkLC6gQ',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5rbXFsbmZlam93Y2ludGxmc3BsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY5NjMxNzM3NiwiZXhwIjoyMDExODkzMzc2fQ.nFOJiBzM2VYJ_aEpv6WoPhtMBjdIiAZtcR1ckkLC6gQ'
    };

    print('Obteniendo elementos...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('Elementos obtenidos correctamente.');
        List<T> items = (json.decode(response.body) as List)
          .map((itemJson) => fromJson(itemJson as Map<String, dynamic>))
          .toList();
        
        // Hacer algo con items.
        print(items);

        return true;
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        return await retryGettingItems(retries, fromJson);
      }
    } catch (e) {
      print('Excepción al obtener partidas: $e');
      return await retryGettingItems(retries, fromJson);
    }
  }

  static Future<void> postItem<T>(T item, {int retries = 0, required Map<String, dynamic> Function(T) toJson}) async {
    Uri uri = Uri.parse(baseUrl);
    final headers = { 
      'Content-Type': 'application/json; charset=UTF-8' ,
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbnd0ZXl1eG5oc3BjeWdmZmtsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMzA4OTM1NywiZXhwIjoyMDE4NjY1MzU3fQ.bAAm5hfglfyZOtUe625LQQwU5w9ArXOgeQu6YBqt5jE',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbnd0ZXl1eG5oc3BjeWdmZmtsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMzA4OTM1NywiZXhwIjoyMDE4NjY1MzU3fQ.bAAm5hfglfyZOtUe625LQQwU5w9ArXOgeQu6YBqt5jE'
    };
    final jsonBody = jsonEncode(toJson(item));

    print('Enviando: $jsonBody');
    
    try {
      final response = await http.post(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 201) {
        print('Partida enviada correctamente.');
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
      print('No se pudo enviar el game después de $maxRetries intentos.');
    }
  }

  static Future<bool> retryGettingItems<T>(int retries, T Function(Map<String, dynamic>) fromJson) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await Time.waitForSeconds(2);
      return await getAllItems(retries: retries + 1, fromJson: fromJson);
    } else {
      print('No se pudo obtener los juegos después de $maxRetries intentos.');
      return false;
    }
  }
}