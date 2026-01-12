
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;

  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationHourKey = 'notification_hour';
  static const String _notificationMinuteKey = 'notification_minute';
  static const String _themeModeKey = 'theme_mode';

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
        // Schedule notification
        _scheduleNotification();
      } else {
        // Cancel notification
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
        // Reschedule notification with new time
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

  void _scheduleNotification() {
    // TODO: Implement notification scheduling using flutter_local_notifications
    // This is a placeholder for the actual implementation
    debugPrint('Scheduling notification for ${_notificationTime.format(null as BuildContext)}');
  }

  void _cancelNotification() {
    // TODO: Implement notification cancellation
    // This is a placeholder for the actual implementation
    debugPrint('Cancelling notifications');
  }
}