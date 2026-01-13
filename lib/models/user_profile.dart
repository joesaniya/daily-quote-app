import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final ThemeMode themeMode;
  final String fontSize;
  final String accentColor;
  final TimeOfDay notificationTime;
  final bool notificationsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.themeMode = ThemeMode.system,
    this.fontSize = 'medium',
    this.accentColor = 'purple',
    this.notificationTime = const TimeOfDay(hour: 8, minute: 0),
    this.notificationsEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse theme mode
    ThemeMode theme = ThemeMode.system;
    final themeModeStr = json['theme_mode'] as String?;
    if (themeModeStr == 'light') {
      theme = ThemeMode.light;
    } else if (themeModeStr == 'dark') {
      theme = ThemeMode.dark;
    }

    // Parse notification time
    TimeOfDay notifTime = const TimeOfDay(hour: 8, minute: 0);
    final timeStr = json['notification_time'] as String?;
    if (timeStr != null) {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        notifTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    return UserProfile(
      id: json['id'] ?? '',
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      themeMode: theme,
      fontSize: json['font_size'] ?? 'medium',
      accentColor: json['accent_color'] ?? 'purple',
      notificationTime: notifTime,
      notificationsEnabled: json['notifications_enabled'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String themeModeStr = 'system';
    if (themeMode == ThemeMode.light) {
      themeModeStr = 'light';
    } else if (themeMode == ThemeMode.dark) {
      themeModeStr = 'dark';
    }

    final timeStr = '${notificationTime.hour.toString().padLeft(2, '0')}:'
        '${notificationTime.minute.toString().padLeft(2, '0')}:00';

    return {
      'id': id,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'theme_mode': themeModeStr,
      'font_size': fontSize,
      'accent_color': accentColor,
      'notification_time': timeStr,
      'notifications_enabled': notificationsEnabled,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    ThemeMode? themeMode,
    String? fontSize,
    String? accentColor,
    TimeOfDay? notificationTime,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      accentColor: accentColor ?? this.accentColor,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'UserProfile(id: $id, displayName: $displayName)';
}

// Font size options
class FontSize {
  static const String small = 'small';
  static const String medium = 'medium';
  static const String large = 'large';

  static double getValue(String size) {
    switch (size) {
      case small:
        return 0.9;
      case large:
        return 1.1;
      case medium:
      default:
        return 1.0;
    }
  }
}

// Accent color options
class AccentColor {
  static const String purple = 'purple';
  static const String blue = 'blue';
  static const String green = 'green';
  static const String orange = 'orange';

  static Color getColor(String colorName) {
    switch (colorName) {
      case blue:
        return const Color(0xFF2196F3);
      case green:
        return const Color(0xFF4CAF50);
      case orange:
        return const Color(0xFFFF9800);
      case purple:
      default:
        return const Color(0xFF6B4EFF);
    }
  }
}