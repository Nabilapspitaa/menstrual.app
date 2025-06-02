// lib/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_1/models/journal_entry.dart'; // Pastikan path ini benar
import 'package:flutter_application_1/models/menstrual_data.dart'; // Pastikan path ini benar

class LocalStorageService {
  static const String _keyJournalEntries = 'journalEntries';
  static const String _keyMenstrualData = 'menstrualData';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyAuthToken = 'authToken';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await _getPrefs();
    final String? jsonString = prefs.getString(_keyJournalEntries);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => JournalEntry.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final prefs = await _getPrefs();
    final String jsonString = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_keyJournalEntries, jsonString);
  }

  Future<List<MenstrualData>> getMenstrualData() async {
    final prefs = await _getPrefs();
    final String? jsonString = prefs.getString(_keyMenstrualData);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => MenstrualData.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveMenstrualData(List<MenstrualData> data) async {
    final prefs = await _getPrefs();
    final String jsonString = json.encode(data.map((e) => e.toJson()).toList());
    await prefs.setString(_keyMenstrualData, jsonString);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyUserEmail, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUserEmail);
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyAuthToken);
  }

  Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyAuthToken);
  }
}