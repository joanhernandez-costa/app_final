import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaveLoad {
  static Future<void> saveGeneric<T>(String key, T object, Function toJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(toJson(object));
    await prefs.setString(key, jsonString);
  }

  static Future<T?> loadGenericObject<T>(String key, Function fromJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return fromJson(json.decode(jsonString));
  }

  static Future<void> saveNum(String key, num value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      throw Exception("El valor numérico no es ni int ni double");
    }
  }

  static Future<num?> loadNum(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      if (prefs.get(key) is int) {
        return prefs.getInt(key);
      } else if (prefs.get(key) is double) {
        return prefs.getDouble(key);
      }
    }
    return 0; // Devuelve 0 si la clave no existe
  }

  static Future<void> saveUserName(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> loadUserName(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
