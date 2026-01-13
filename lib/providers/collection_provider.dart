import 'package:flutter/foundation.dart';
import 'package:sample_app/config/supa_base_config.dart';
import '../models/collection.dart';
import '../models/quote.dart';

class CollectionsProvider with ChangeNotifier {
  List<Collection> _collections = [];
  Map<String, List<Quote>> _collectionQuotes = {};
  bool _isLoading = false;
  String? _error;

  List<Collection> get collections => List.unmodifiable(_collections);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all collections for current user
  Future<void> loadCollections() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      _collections = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load collections with quote count
      final response = await SupabaseConfig.client
          .from('collections')
          .select('''
            *,
            collection_items(count)
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _collections = (response as List).map((item) {
        final collectionData = Map<String, dynamic>.from(item);
        final count = item['collection_items'] != null 
            ? (item['collection_items'] as List).length 
            : 0;
        collectionData['quote_count'] = count;
        return Collection.fromJson(collectionData);
      }).toList();
    } catch (e) {
      _error = 'Failed to load collections';
      debugPrint('Error loading collections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new collection
  Future<Collection?> createCollection({
    required String name,
    String? description,
  }) async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      _error = 'Please sign in to create collections';
      notifyListeners();
      return null;
    }

    try {
      final response = await SupabaseConfig.collections
          .insert({
            'user_id': user.id,
            'name': name,
            'description': description,
          })
          .select()
          .single();

      final newCollection = Collection.fromJson(response);
      _collections.insert(0, newCollection);
      notifyListeners();
      return newCollection;
    } catch (e) {
      _error = 'Failed to create collection';
      debugPrint('Error creating collection: $e');
      notifyListeners();
      return null;
    }
  }

  // Update collection
  Future<bool> updateCollection(String collectionId, {
    String? name,
    String? description,
  }) async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return false;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await SupabaseConfig.collections
          .update(updates)
          .eq('id', collectionId)
          .eq('user_id', user.id);

      // Update local collection
      final index = _collections.indexWhere((c) => c.id == collectionId);
      if (index != -1) {
        _collections[index] = _collections[index].copyWith(
          name: name,
          description: description,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update collection';
      debugPrint('Error updating collection: $e');
      notifyListeners();
      return false;
    }
  }

  // Delete collection
  Future<bool> deleteCollection(String collectionId) async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return false;

    try {
      await SupabaseConfig.collections
          .delete()
          .eq('id', collectionId)
          .eq('user_id', user.id);

      _collections.removeWhere((c) => c.id == collectionId);
      _collectionQuotes.remove(collectionId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete collection';
      debugPrint('Error deleting collection: $e');
      notifyListeners();
      return false;
    }
  }

  // Load quotes in a collection
  Future<List<Quote>> loadCollectionQuotes(String collectionId) async {
    try {
      final response = await SupabaseConfig.collectionItems
          .select('quote_id, quotes(*)')
          .eq('collection_id', collectionId)
          .order('added_at', ascending: false);

      final quotes = (response as List)
          .map((item) => Quote.fromJson(item['quotes']))
          .toList();

      _collectionQuotes[collectionId] = quotes;
      notifyListeners();
      return quotes;
    } catch (e) {
      debugPrint('Error loading collection quotes: $e');
      return [];
    }
  }

  // Add quote to collection
  Future<bool> addQuoteToCollection(String collectionId, Quote quote) async {
    try {
      await SupabaseConfig.collectionItems.insert({
        'collection_id': collectionId,
        'quote_id': quote.id,
      });

      // Update local cache
      if (_collectionQuotes.containsKey(collectionId)) {
        _collectionQuotes[collectionId]!.insert(0, quote);
      }

      // Update quote count
      final index = _collections.indexWhere((c) => c.id == collectionId);
      if (index != -1) {
        _collections[index] = _collections[index].copyWith(
          quoteCount: _collections[index].quoteCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add quote to collection';
      debugPrint('Error adding quote to collection: $e');
      notifyListeners();
      return false;
    }
  }

  // Remove quote from collection
  Future<bool> removeQuoteFromCollection(String collectionId, String quoteId) async {
    try {
      await SupabaseConfig.collectionItems
          .delete()
          .eq('collection_id', collectionId)
          .eq('quote_id', quoteId);

      // Update local cache
      if (_collectionQuotes.containsKey(collectionId)) {
        _collectionQuotes[collectionId]!.removeWhere((q) => q.id == quoteId);
      }

      // Update quote count
      final index = _collections.indexWhere((c) => c.id == collectionId);
      if (index != -1) {
        _collections[index] = _collections[index].copyWith(
          quoteCount: _collections[index].quoteCount - 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove quote from collection';
      debugPrint('Error removing quote from collection: $e');
      notifyListeners();
      return false;
    }
  }

  // Check if quote is in collection
  Future<bool> isQuoteInCollection(String collectionId, String quoteId) async {
    try {
      final response = await SupabaseConfig.collectionItems
          .select('id')
          .eq('collection_id', collectionId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking if quote is in collection: $e');
      return false;
    }
  }

  // Get cached quotes for a collection
  List<Quote>? getCachedCollectionQuotes(String collectionId) {
    return _collectionQuotes[collectionId];
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}