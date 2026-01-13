import 'package:flutter/material.dart';

class Quote {
  final String id;
  final String text;
  final String author;
  final String category;  // Added category field
  final DateTime? createdAt;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,  // Required parameter
    this.createdAt,
  });

  // Create from Supabase response
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? '',
      text: json['text'] ?? json['q'] ?? '',
      author: json['author'] ?? json['a'] ?? 'Unknown',
      category: json['category'] ?? 'Wisdom',  // Default to Wisdom if missing
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'author': author,
        'category': category,  // Include category in JSON
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  // Create a copy with modifications
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,  // Include in copyWith
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Quote(id: $id, text: $text, author: $author, category: $category)';
}

// Available categories
class QuoteCategory {
  static const String motivation = 'Motivation';
  static const String love = 'Love';
  static const String success = 'Success';
  static const String wisdom = 'Wisdom';
  static const String humor = 'Humor';

  static const List<String> all = [
    motivation,
    love,
    success,
    wisdom,
    humor,
  ];

  static String getEmoji(String category) {
    switch (category) {
      case motivation:
        return '💪';
      case love:
        return '❤️';
      case success:
        return '🏆';
      case wisdom:
        return '🧠';
      case humor:
        return '😄';
      default:
        return '💭';
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case motivation:
        return const Color(0xFFFF6B6B);
      case love:
        return const Color(0xFFE91E63);
      case success:
        return const Color(0xFFFFC107);
      case wisdom:
        return const Color(0xFF2196F3);
      case humor:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}