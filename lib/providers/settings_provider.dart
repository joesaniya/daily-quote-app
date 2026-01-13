import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  ThemeMode _themeMode = ThemeMode.system;
  String _fontSize = 'medium';
  String _accentColor = 'purple';
  bool _widgetEnabled = false;
  bool _isLoading = false;

  final NotificationService _notificationService = NotificationService();

  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  ThemeMode get themeMode => _themeMode;
  String get fontSize => _fontSize;
  String get accentColor => _accentColor;
  bool get widgetEnabled => _widgetEnabled;
  bool get isLoading => _isLoading;

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationHourKey = 'notification_hour';
  static const String _notificationMinuteKey = 'notification_minute';
  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _accentColorKey = 'accent_color';
  static const String _widgetEnabledKey = 'widget_enabled';

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.initialize();

      final prefs = await SharedPreferences.getInstance();

      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? false;

      final hour = prefs.getInt(_notificationHourKey) ?? 8;
      final minute = prefs.getInt(_notificationMinuteKey) ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);

      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];

      _fontSize = prefs.getString(_fontSizeKey) ?? 'medium';
      _accentColor = prefs.getString(_accentColorKey) ?? 'purple';

      _widgetEnabled = prefs.getBool(_widgetEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      // Request permissions first
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        debugPrint('Notification permissions denied');
        return;
      }
    }

    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      if (enabled) {
        await _scheduleNotification();
      } else {
        await _notificationService.cancelAllNotifications();
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
        await _scheduleNotification();
      }
    } catch (e) {
      debugPrint('Error saving notification time: $e');
    }
  }

  Future<void> _scheduleNotification() async {
    await _notificationService.scheduleDailyQuoteNotification(
      hour: _notificationTime.hour,
      minute: _notificationTime.minute,
    );
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

  Future<void> setWidgetEnabled(bool enabled) async {
    _widgetEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_widgetEnabledKey, enabled);

      if (!enabled) {
        // Clear widget data
        // Home widget clearing will be best-effort (platform-specific)
      }
    } catch (e) {
      debugPrint('Error saving widget setting: $e');
    }
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

  // Test notification
  Future<void> testNotification() async {
    await _notificationService.showInstantNotification(
      title: 'Test Notification 💭',
      body:
          '"The only way to do great work is to love what you do." — Steve Jobs',
    );
  }
}
