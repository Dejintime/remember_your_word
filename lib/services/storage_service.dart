import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // 保存字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  // 获取字符串
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  // 保存JSON对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }

  // 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // 保存JSON列表
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }

  // 获取JSON列表
  List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  // 获取布尔值
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  // 保存整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  // 获取整数
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  // 保存浮点数
  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  // 获取浮点数
  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }

  // 删除键值对
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // 清空所有数据
  Future<bool> clear() async {
    return await _prefs!.clear();
  }

  // 检查键是否存在
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }

  // 获取所有键
  Set<String> getKeys() {
    return _prefs!.getKeys();
  }
}
