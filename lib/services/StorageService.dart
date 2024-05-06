import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  // Guarda en preferencias un objeto genérico (Debe tener obligatoriamente un método toJson implementado).
  static Future<void> saveGeneric<T>(String key, T object,
      Map<String, dynamic> Function(T object) toJson) async {
    final SharedPreferences prefs = await _preferences;
    String jsonString = json.encode(toJson(object));
    await prefs.setString(key, jsonString);
    print('saved correctly: $jsonString');
  }

  // Carga desde preferencias un objeto genérico (Debe tener obligatoriamente un método fromJson implementado).
  static Future<T?> loadGeneric<T>(String key, Function fromJson) async {
    final SharedPreferences prefs = await _preferences;
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    print('loaded correctly $jsonString');
    return fromJson(json.decode(jsonString));
  }

  static Future<void> saveBool(String key, bool value) async {
    final SharedPreferences prefs = await _preferences;
    await prefs.setBool(key, value);
  }

  static Future<bool?> loadBool(String key) async {
    final SharedPreferences prefs = await _preferences;
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> saveString(String key, String value) async {
    final SharedPreferences prefs = await _preferences;
    return prefs.setString(key, value);
  }

  static Future<String?> loadString(String key) async {
    final SharedPreferences prefs = await _preferences;
    return prefs.getString(key) ?? 'false';
  }

  // Guarda un valor float en preferencias
  static Future<bool> saveFloat(String key, double value) async {
    final SharedPreferences prefs = await _preferences;
    return await prefs.setDouble(key, value);
  }

  // Carga un valor float desde preferencias
  static Future<double?> loadFloat(String key) async {
    final SharedPreferences prefs = await _preferences;
    return prefs.getDouble(key);
  }

  // Borra todo lo que haya almacenado en preferencias.
  static Future<void> resetPreferences() async {
    final SharedPreferences prefs = await _preferences;
    await prefs.clear();
  }
}
