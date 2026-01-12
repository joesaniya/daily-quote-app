
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class FavoritesManager {
  static const String _key = 'favorite_quotes';

  static Future<List<Quote>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_key);

      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((item) => Quote.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      return [];
    }
  }

  static Future<void> saveFavorites(List<Quote> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String favoritesJson = json.encode(
        favorites.map((quote) => quote.toJson()).toList(),
      );
      await prefs.setString(_key, favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  static Future<bool> isFavorite(String quoteId) async {
    final favorites = await getFavorites();
    return favorites.any((q) => q.id == quoteId);
  }

  static Future<void> addFavorite(Quote quote) async {
    final favorites = await getFavorites();
    if (!favorites.any((q) => q.id == quote.id)) {
      favorites.add(quote);
      await saveFavorites(favorites);
    }
  }

  static Future<void> removeFavorite(String quoteId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((q) => q.id == quoteId);
    await saveFavorites(favorites);
  }

  static Future<void> toggleFavorite(Quote quote) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((q) => q.id == quote.id);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(quote);
    }

    await saveFavorites(favorites);
  }

  static Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }
}