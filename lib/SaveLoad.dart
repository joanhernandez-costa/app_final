
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaveLoad {
  static Future<void> saveGeneric<T>(String key, T object, Map<String, dynamic> Function(T object) toJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(toJson(object));
    await prefs.setString(key, jsonString);
    print('saved correctly: $jsonString');
  }

  static Future<T?> loadGeneric<T>(String key, Function fromJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    print('loaded correctly $jsonString');
    return fromJson(json.decode(jsonString));
  }

  static Future<void> saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> loadBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> saveString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<String> loadString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? 'false';
  }

}


