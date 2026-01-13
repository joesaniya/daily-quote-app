import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  ThemeMode _themeMode = ThemeMode.system;
  String _fontSize = 'medium';
  String _accentColor = 'purple';
  bool _isLoading = false;

  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  ThemeMode get themeMode => _themeMode;
  String get fontSize => _fontSize;
  String get accentColor => _accentColor;
  bool get isLoading => _isLoading;

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationHourKey = 'notification_hour';
  static const String _notificationMinuteKey = 'notification_minute';
  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _accentColorKey = 'accent_color';

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? false;

      final hour = prefs.getInt(_notificationHourKey) ?? 8;
      final minute = prefs.getInt(_notificationMinuteKey) ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);

      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];

      _fontSize = prefs.getString(_fontSizeKey) ?? 'medium';
      _accentColor = prefs.getString(_accentColorKey) ?? 'purple';
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      if (enabled) {
        _scheduleNotification();
      } else {
        _cancelNotification();
      }
    } catch (e) {
      debugPrint('Error saving notification setting: $e');
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_notificationHourKey, time.hour);
      await prefs.setInt(_notificationMinuteKey, time.minute);

      if (_notificationsEnabled) {
        _scheduleNotification();
      }
    } catch (e) {
      debugPrint('Error saving notification time: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontSizeKey, size);
    } catch (e) {
      debugPrint('Error saving font size: $e');
    }
  }

  Future<void> setAccentColor(String color) async {
    _accentColor = color;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accentColorKey, color);
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }

  void _scheduleNotification() {
    // TODO: Implement notification scheduling using flutter_local_notifications
    debugPrint(
      'Scheduling notification for ${_notificationTime.hour}:${_notificationTime.minute}',
    );
  }

  void _cancelNotification() {
    // TODO: Implement notification cancellation
    debugPrint('Cancelling notifications');
  }

  // Font size helpers
  double getFontScale() {
    switch (_fontSize) {
      case 'small':
        return 0.9;
      case 'large':
        return 1.1;
      case 'medium':
      default:
        return 1.0;
    }
  }

  // Accent color helpers
  Color getAccentColorValue() {
    switch (_accentColor) {
      case 'blue':
        return const Color(0xFF2196F3);
      case 'green':
        return const Color(0xFF4CAF50);
      case 'orange':
        return const Color(0xFFFF9800);
      case 'purple':
      default:
        return const Color(0xFF6B4EFF);
    }
  }
}
