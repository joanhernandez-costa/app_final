import 'dart:convert';
import 'package:tarea_flutter/Game.dart';
import 'package:http/http.dart' as http;
import 'package:tarea_flutter/ScoreRecordTableView.dart';
import 'package:tarea_flutter/Time.dart';

class ApiCalls {
  static const int maxRetries = 3;
  static const String baseUrl = 'https://sinwteyuxnhspcygffkl.supabase.co/rest/v1/games';

  static Future<bool> getGames({int retries = 0}) async {
    Uri uri = Uri.parse('$baseUrl?select=*');
    final headers = {
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbnd0ZXl1eG5oc3BjeWdmZmtsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMzA4OTM1NywiZXhwIjoyMDE4NjY1MzU3fQ.bAAm5hfglfyZOtUe625LQQwU5w9ArXOgeQu6YBqt5jE',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbnd0ZXl1eG5oc3BjeWdmZmtsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMzA4OTM1NywiZXhwIjoyMDE4NjY1MzU3fQ.bAAm5hfglfyZOtUe625LQQwU5w9ArXOgeQu6YBqt5jE'
    };

    print('Obteniendo juegos...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('Partidas obtenidas correctamente.');
        List<Game> newGames = (json.decode(response.body) as List)
          .map((gameJson) => Game.fromJson(gameJson))
          .toList();
        games.clear();
        games.addAll(newGames);
        return true;
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        return await retryGettingGames(retries);
      }
    } catch (e) {
      print('Excepción al obtener partidas: $e');
      return await retryGettingGames(retries);
    }
  }

  

  static Future<void> postGame(Game game, {int retries = 0}) async {
    Uri uri = Uri.parse(baseUrl);
    final headers = { 
      'Content-Type': 'application/json; charset=UTF-8' ,
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbnd0ZXl1eG5oc3BjeWdmZmtsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMzA4OTM1NywiZXhwIjoyMDE4NjY1MzU3fQ.bAAm5hfglfyZOtUe625LQQwU5w9ArXOgeQu6YBqt5jE',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbnd0ZXl1eG5oc3BjeWdmZmtsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwMzA4OTM1NywiZXhwIjoyMDE4NjY1MzU3fQ.bAAm5hfglfyZOtUe625LQQwU5w9ArXOgeQu6YBqt5jE'
    };
    final jsonBody = jsonEncode(game.toJson());

    print('Enviando: $jsonBody');
    
    try {
      final response = await http.post(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 201) {
        print('Partida enviada correctamente.');
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        retryPostingGame(game, retries);
      }
    } catch (e) {
      print('Excepción al enviar partida: $e');
      retryPostingGame(game, retries);
    }
  }

  static void retryPostingGame(Game game, int retries) async {
    if (retries < maxRetries) {
        print('Reintento ${retries + 1} de $maxRetries...');
        await Time.waitForSeconds(2);
        await postGame(game, retries: retries + 1);
      } else {
        print('No se pudo enviar el game después de $maxRetries intentos.');
      }
  }

  static Future<bool> retryGettingGames(int retries) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await Time.waitForSeconds(2);
      return await getGames(retries: retries + 1);
    } else {
      print('No se pudo obtener los juegos después de $maxRetries intentos.');
      return false;
    }
  }
}