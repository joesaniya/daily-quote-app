
import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../services/favorites_manager.dart';

class FavoritesProvider with ChangeNotifier {
  List<Quote> _favorites = [];
  bool _isLoading = false;

  List<Quote> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  int get favoritesCount => _favorites.length;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await FavoritesManager.getFavorites();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String quoteId) {
    return _favorites.any((q) => q.id == quoteId);
  }

  Future<void> toggleFavorite(Quote quote) async {
    try {
      await FavoritesManager.toggleFavorite(quote);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> addFavorite(Quote quote) async {
    try {
      await FavoritesManager.addFavorite(quote);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String quoteId) async {
    try {
      await FavoritesManager.removeFavorite(quoteId);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await FavoritesManager.clearAllFavorites();
      await loadFavorites();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }
}
