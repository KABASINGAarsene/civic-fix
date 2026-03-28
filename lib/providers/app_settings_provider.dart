import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider._(this._preferences) {
    _loadFromStorage();
  }

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
  ];

  static const Map<String, String> _languageLabelToCode = {
    'English': 'en',
    'French': 'fr',
    'Kinyarwanda': 'rw',
  };

  final SharedPreferences _preferences;

  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en';
  bool _notificationsEnabled = true;

  static Future<AppSettingsProvider> create() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettingsProvider._(preferences);
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => Locale(_languageCode);
  bool get notificationsEnabled => _notificationsEnabled;

  String get selectedLanguageLabel {
    return _languageLabelToCode.entries
        .firstWhere(
          (entry) => entry.value == _languageCode,
          orElse: () => const MapEntry('English', 'en'),
        )
        .key;
  }

  List<String> get supportedLanguageLabels {
    return _languageLabelToCode.keys.toList(growable: false);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
    await _preferences.setString(_themeModeKey, _themeMode.name);
  }

  Future<void> toggleThemeMode() {
    return setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setNotificationsEnabled(bool isEnabled) async {
    if (_notificationsEnabled == isEnabled) {
      return;
    }

    _notificationsEnabled = isEnabled;
    notifyListeners();
    await _preferences.setBool(_notificationsEnabledKey, isEnabled);
  }

  Future<void> setLanguageFromLabel(String languageLabel) async {
    final normalizedCode = _languageLabelToCode[languageLabel];
    if (normalizedCode == null || _languageCode == normalizedCode) {
      return;
    }

    _languageCode = normalizedCode;
    notifyListeners();
    await _preferences.setString(_languageCodeKey, _languageCode);
  }

  void _loadFromStorage() {
    final storedThemeMode = _preferences.getString(_themeModeKey);
    final storedLanguageCode = _preferences.getString(_languageCodeKey);
    final storedNotifications = _preferences.getBool(_notificationsEnabledKey);

    _themeMode = _parseThemeMode(storedThemeMode);
    _languageCode = _parseLanguageCode(storedLanguageCode);
    _notificationsEnabled = storedNotifications ?? true;
  }

  ThemeMode _parseThemeMode(String? storedThemeMode) {
    switch (storedThemeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  String _parseLanguageCode(String? storedLanguageCode) {
    if (storedLanguageCode == null || storedLanguageCode.isEmpty) {
      return 'en';
    }

    if (_languageLabelToCode.containsValue(storedLanguageCode)) {
      return storedLanguageCode;
    }

    // Backward compatibility if old value was saved as a label.
    final oldLabelCode = _languageLabelToCode[storedLanguageCode];
    return oldLabelCode ?? 'en';
  }
}
