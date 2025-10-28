import 'dart:convert';

import 'package:advanced_mobile_programming_app/app/models/user.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final _users = <User>[];

  static late SharedPreferences _prefs;

  static bool hasInitialized = false;

  Future<List<User>> getUsers() async {
    if (!hasInitialized) {
      await initialize();
    }

    return List.unmodifiable(_users);
  }

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final savedUsers = _prefs.getString('users');

    if (savedUsers != null) {
      final jsonData = jsonDecode(savedUsers);

      List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[];
      try {
        jsonList = List<Map<String, dynamic>>.from(jsonData);
      } catch (_) {}

      _users.clear();
      _users.addAll(jsonList.map((e) => User.fromJson(e)).toList());
    } else {
      final jsonFromAsset = await rootBundle.loadString('assets/user.json');

      final result = <User>[];

      if (jsonFromAsset.isNotEmpty) {
        final jsonData = jsonDecode(jsonFromAsset);

        List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[];
        try {
          jsonList = List<Map<String, dynamic>>.from(jsonData);
        } catch (_) {}

        result.addAll(jsonList.map<User>((e) => User.fromJson(e)).toList());
      }

      _users.clear();
      _users.addAll(result);
    }

    hasInitialized = true;
  }

  static _saveCurrentUsers() async {
    final jsonData = _users.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonData);
    await _prefs.setString('users', jsonString);
  }

  Future<void> addUser(User user) async {
    user.validate();

    _users.add(user);
    await _saveCurrentUsers();
  }

  Future<void> updateUser(User user) async {
    user.validate();

    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      throw 'Pengguna dengan ID ${user.id} tidak ditemukan.';
    }

    _users[index] = user;
    await _saveCurrentUsers();
  }

  Future<void> deleteUser(num id) async {
    final index = _users.indexWhere((u) => u.id == id);

    if (index == -1) {
      throw 'Pengguna dengan ID $id tidak ditemukan.';
    }

    _users.removeAt(index);
    await _saveCurrentUsers();
  }
}
