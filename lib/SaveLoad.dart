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

}
