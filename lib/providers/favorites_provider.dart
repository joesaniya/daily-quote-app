
import 'package:flutter/foundation.dart';
import 'package:sample_app/config/supa_base_config.dart';
import '../models/quote.dart';

class FavoritesProvider with ChangeNotifier {
  List<Quote> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Quote> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoritesCount => _favorites.length;

  // Load favorites from Supabase
  Future<void> loadFavorites() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      _favorites = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.userFavorites
          .select('quote_id, quotes(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _favorites = (response as List)
          .map((item) => Quote.fromJson(item['quotes']))
          .toList();
    } catch (e) {
      _error = 'Failed to load favorites';
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if a quote is favorited
  bool isFavorite(String quoteId) {
    return _favorites.any((q) => q.id == quoteId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Quote quote) async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      _error = 'Please sign in to save favorites';
      notifyListeners();
      return;
    }

    try {
      if (isFavorite(quote.id)) {
        await removeFavorite(quote.id);
      } else {
        await addFavorite(quote);
      }
    } catch (e) {
      _error = 'Failed to update favorite';
      debugPrint('Error toggling favorite: $e');
      notifyListeners();
    }
  }

  // Add to favorites
  Future<void> addFavorite(Quote quote) async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      _error = 'Please sign in to save favorites';
      notifyListeners();
      return;
    }

    try {
      await SupabaseConfig.userFavorites.insert({
        'user_id': user.id,
        'quote_id': quote.id,
      });

      _favorites.insert(0, quote);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add favorite';
      debugPrint('Error adding favorite: $e');
      notifyListeners();
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String quoteId) async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return;

    try {
      await SupabaseConfig.userFavorites
          .delete()
          .eq('user_id', user.id)
          .eq('quote_id', quoteId);

      _favorites.removeWhere((q) => q.id == quoteId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove favorite';
      debugPrint('Error removing favorite: $e');
      notifyListeners();
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return;

    try {
      await SupabaseConfig.userFavorites
          .delete()
          .eq('user_id', user.id);

      _favorites.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear favorites';
      debugPrint('Error clearing favorites: $e');
      notifyListeners();
    }
  }

  // Search favorites
  List<Quote> searchFavorites(String query) {
    if (query.isEmpty) return _favorites;

    final lowerQuery = query.toLowerCase();
    return _favorites.where((quote) {
      return quote.text.toLowerCase().contains(lowerQuery) ||
          quote.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get favorites by category
  List<Quote> getFavoritesByCategory(String category) {
    return _favorites.where((quote) => quote.category == category).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
/*import 'package:flutter/foundation.dart';
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
*/