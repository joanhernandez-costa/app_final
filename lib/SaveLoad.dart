import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaveLoad {
  static Future<void> saveGenericObject<T extends ObjectWithJson>(String key, T object) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(object.toJson());
    await prefs.setString(key, jsonString);
    print('saved correctly: $jsonString');
  }

  static Future<T?> loadGenericObject<T>(String key, Function fromJson) async {
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

  static Future<bool> loadBool(String key, {bool defaultValue = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

}

abstract class ObjectWithJson<T> {
  Map<String, dynamic> toJson();
}


