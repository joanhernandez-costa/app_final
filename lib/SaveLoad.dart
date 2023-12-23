import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaveLoad {
  static Future<void> saveGenericObject<T>(String key, T object, Function toJson) async {
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

  static Future<void> saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> loadBool(String key, {bool defaultValue = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

}
