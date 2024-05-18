// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/models/Favorite.dart';
import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/models/RestaurantDetail.dart';
import 'package:app_final/models/RestaurantHours.dart';
import 'package:app_final/models/Review.dart';
import 'package:app_final/models/UserData.dart';
import 'package:app_final/models/WeatherData.dart';
import 'package:app_final/screens/RestaurantDetailScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:app_final/services/TimeService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Número máximo de intentos para la lógica de reintentos.
  static const int maxRetries = 3;
  // URL base de la API de Supabase, obtenida de las variables de entorno.
  static final String baseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  // Token del usuario para la autorización, puede ser null si no está autenticado.
  static String? userToken;

  /// Función para obtener todos los elementos de una tabla específica.
  // 'T' es el tipo de dato (modelo) que se espera obtener.
  // 'fromJson' es la función que convierte el mapa JSON en una instancia de 'T'.
  static Future<List<T>> getAllItems<T>(
      {int retries = 0,
      required T Function(Map<String, dynamic>) fromJson}) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';

    Uri uri = Uri.parse('$baseUrl$tableUrl?select=*');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print('Obteniendo $T...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<T> items = (json.decode(response.body) as List)
            .map((itemJson) => fromJson(itemJson as Map<String, dynamic>))
            .toList();
        print('$T obtenidos correctamente.');
        return items;
      } else {
        print(
            'Error: ${response.statusCode}. Respuesta: ${response.reasonPhrase}');
        return await retryGettingItems(retries, fromJson);
      }
    } catch (e) {
      print('Excepción al obtener $T: $e');
      return await retryGettingItems(retries, fromJson);
    }
  }

  // Función para obtener un elemento específico de una tabla por su identificador.
  static Future<T?> getItem<T>(
      String itemId, T Function(Map<String, dynamic>) fromJson) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';
    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$itemId');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY']}',
    };

    print('Obteniendo $T...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('$T obtenido correctamente. Respuesta: ${response.body}');
        final data = jsonDecode(response.body);
        return data.length <= 0 ? null : fromJson(data[0]);
      } else {
        throw Exception(
            'Error al obtener $T: ${response.statusCode}. Respuesta: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Inserta un registro en una tabla cualquiera. Especificar tipo 'T'. (Solo acepta tipos que tengan una tabla en SupaBase)
  static Future<void> postItem<T>(T item,
      {int retries = 0,
      required Map<String, dynamic> Function(T) toJson}) async {
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
        print('$T enviado correctamente. ${response.body}');
      } else {
        print(
            'Error: ${response.statusCode}. Respuesta: ${response.reasonPhrase}');
        retryPostingItem(item, toJson, retries);
      }
    } catch (e) {
      print('Excepción al enviar $T: $e');
      retryPostingItem(item, toJson, retries);
    }
  }

  // Método para actualizar un registro genérico de una tabla genérica.
  static Future<void> updateItem<T>(T updatedItem, String updatedItemId) async {
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
        print(
            'Error al actualizar $T: ${response.statusCode}. Respuesta: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al actualizar $T: $e');
    }
  }

  // Función para eliminar un elemento específico de una tabla por su identificador.
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
        throw Exception(
            'Error al eliminar $T: ${response.statusCode}. Respuesta: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al eliminar $T: $e');
    }
  }

  // Reintento de conexión Post a tabla genérica.
  static void retryPostingItem<T>(
      T item, Map<String, dynamic> Function(T) toJson, int retries) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await TimeService.waitForSeconds(2);
      await postItem(item, retries: retries + 1, toJson: toJson);
    } else {
      print('No se pudo enviar el elemento después de $maxRetries intentos.');
    }
  }

  // Reintento de conexión Get a tabla genérica.
  static Future<List<T>> retryGettingItems<T>(
      int retries, T Function(Map<String, dynamic>) fromJson) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await TimeService.waitForSeconds(2);
      return await getAllItems(retries: retries + 1, fromJson: fromJson);
    } else {
      print(
          'No se pudo obtener los elementos después de $maxRetries intentos.');
      List<T> emptyList = [];
      return emptyList;
    }
  }

  static Future<void> getFavoriteRestaurants(String user_id) async {
    Uri uri = Uri.parse(
        '$baseUrl/rest/v1/favorite_restaurants_view?favorite_user_id=eq.$user_id');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print('Obteniendo restaurantes favoritos...');

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        List<RestaurantData> favoriteRestaurants =
            (json.decode(response.body) as List)
                .map((itemJson) =>
                    RestaurantData.fromJson(itemJson as Map<String, dynamic>))
                .toList();
        Favorite.favoriteRestaurants = favoriteRestaurants;
        print('Restaurantes de usuario $user_id obtenidos correctamente');
      } else {
        throw Exception(
            'Error al cargar restaurantes favoritos. ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<UserReview>?> getUserReviews(String restaurant_id) async {
    Uri uri = Uri.parse(
        '$baseUrl/rest/v1/user_reviews?review_restaurant_id=eq.$restaurant_id');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print(
        'Obteniendo reseñas de restaurante: $restaurant_id y información de usuarios.');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        List<UserReview> userReviews = jsonData.map((jsonItem) {
          var reviewData = jsonItem['review_user']['review'];
          var userData = jsonItem['review_user']['user'];

          Review review = Review.fromJson(reviewData);
          AppUser user = AppUser.fromJson(userData);

          return UserReview(review, user);
        }).toList();

        print('UserReview obtenidos correctamente.');
        return userReviews.isEmpty ? null : userReviews;
      } else {
        throw Exception('Error al obtener reseñas: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserData?> fromAppUser(String user_id) async {
    Uri uri = Uri.parse('$baseUrl/rest/v1/user_data?user_id=eq.$user_id');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print('Obteniendo UserData de $user_id');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        var userDataJson = json.decode(response.body);
        UserData userData = UserData.fromJson(userDataJson[0]);

        print('UserData de $user_id obtenido correctamente');
        return userData;
      } else {
        throw Exception('Error al obtener reseñas: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<WeatherData>?> getWeather(
      DateTime localTime, LatLng position) async {
    const String baseWeatherUrl =
        'https://api.openweathermap.org/data/3.0/onecall';
    String params =
        '?lat=${position.latitude}&lon=${position.longitude}&exclude=minutely,hourly&units=metric&appid=${dotenv.env['OPENWEATHERMAP_API_KEY']}&lang=es';

    print(
        'Obteniendo informe meteorológico de [${position.latitude}, ${position.longitude}] a las $localTime');

    try {
      final response = await http.get(Uri.parse(baseWeatherUrl + params));

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        List<WeatherData> forecasts =
            WeatherData.fromDailyJson(decodedResponse['daily'], position);
        print('Informe meteorológico obtenido correctamente.');
        return forecasts;
      } else {
        throw Exception(
            'Error al obtener informe meteorológico: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Mapea: tipo 'T' => URL de la tabla que almacena T en la base de datos y el nombre de su clave primaria.
  static const Map<Type, Map<String, String>> typeToTableData = {
    AppUser: {'url': '/rest/v1/users', 'primaryKey': 'user_id'},
    UserData: {'url': '/rest/v1/user_data', 'primaryKey': 'user_data_id'},
    RestaurantData: {
      'url': '/rest/v1/all_restaurant_data_view',
      'primaryKey': ''
    },
    Restaurant: {'url': '/rest/v1/restaurant', 'primaryKey': 'restaurant_id'},
    RestaurantDetail: {
      'url': '/rest/v1/restaurant_details',
      'primaryKey': 'restaurant_id'
    },
    RestaurantHours: {
      'url': '/rest/v1/restaurant_hours',
      'primaryKey': 'restaurant_id'
    },
    Review: {'url': '/rest/v1/reviews', 'primaryKey': 'review_id'},
    Favorite: {'url': '/rest/v1/favorites', 'primaryKey': 'favorite_id'},
  };
}
