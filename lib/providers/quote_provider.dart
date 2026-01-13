

import 'package:flutter/foundation.dart';
import 'package:sample_app/config/supa_base_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sample_app/services/notification_service.dart';
import 'package:sample_app/services/widget_service.dart';
import '../models/quote.dart';

class QuoteProvider with ChangeNotifier {
  List<Quote> _quotes = [];
  Quote? _currentQuote;
  Quote? _dailyQuote;
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  List<Quote> get quotes => List.unmodifiable(_quotes);
  Quote? get currentQuote => _currentQuote;
  Quote? get dailyQuote => _dailyQuote;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load quotes with pagination
  Future<void> loadQuotes({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _quotes.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate pagination
      final offset = _currentPage * _pageSize;
      final limit = offset + _pageSize - 1;

      // Build query - chain filters BEFORE ordering and pagination
      var query = SupabaseConfig.quotes.select();

      // Apply category filter
      if (_selectedCategory != null) {
        query = query.eq('category', _selectedCategory!);
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        query = query.or(
          'text.ilike.%$_searchQuery%,author.ilike.%$_searchQuery%',
        );
      }

      // Apply ordering and pagination LAST
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, limit);

      final newQuotes = (response as List)
          .map((json) => Quote.fromJson(json))
          .toList();

      if (newQuotes.length < _pageSize) {
        _hasMore = false;
      }

      _quotes.addAll(newQuotes);
      _currentPage++;

      // Set current quote if empty
      if (_currentQuote == null && _quotes.isNotEmpty) {
        _currentQuote = _quotes.first;
      }
    } catch (e) {
      _error = 'Failed to load quotes';
      debugPrint('Error loading quotes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load a random quote
  Future<void> loadRandomQuote() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get total count using count option in select
      final countResponse = await SupabaseConfig.quotes
          .select('id')
          .count(CountOption.exact);

      final count = countResponse.count;

      if (count == 0) {
        _error = 'No quotes available';
        return;
      }

      // Get random offset (better random distribution)
      final random = DateTime.now().millisecondsSinceEpoch % count;

      final response = await SupabaseConfig.quotes
          .select()
          .range(random, random)
          .single();

      _currentQuote = Quote.fromJson(response);
    } catch (e) {
      _error = 'Failed to load quote';
      debugPrint('Error loading random quote: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load daily quote
  Future<void> loadDailyQuote() async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if daily quote exists for today
      final dailyQuoteResponse = await SupabaseConfig.dailyQuotes
          .select('quote_id, quotes(*)')
          .eq('date', dateStr)
          .maybeSingle();

      if (dailyQuoteResponse != null) {
        final quoteData = dailyQuoteResponse['quotes'];
        _dailyQuote = Quote.fromJson(quoteData);

        // Schedule notification for today's quote if notifications are enabled
        try {
          final notificationService = NotificationService();
          await notificationService.scheduleNotificationForQuote(
            quoteId: _dailyQuote!.id,
            quoteText: _dailyQuote!.text,
            author: _dailyQuote!.author,
          );
        } catch (e) {
          debugPrint(
            'Error scheduling notification for existing daily quote: $e',
          );
        }

        // Update home screen widget with today's quote (best-effort)
        try {
          final widgetService = WidgetService();
          await widgetService.updateDailyQuoteWidget(
            quoteId: _dailyQuote!.id,
            quoteText: _dailyQuote!.text,
            author: _dailyQuote!.author,
          );
        } catch (e) {
          debugPrint('Error updating widget for existing daily quote: $e');
        }
      } else {
        // Generate new daily quote
        await _generateDailyQuote(dateStr);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily quote: $e');
    }
  }

  Future<void> _generateDailyQuote(String dateStr) async {
    try {
      // Get total count
      final countResponse = await SupabaseConfig.quotes
          .select('id')
          .count(CountOption.exact);

      final count = countResponse.count;
      if (count == 0) return;

      // Use day of year for consistent daily quote
      final randomOffset = DateTime.now().day % count;

      final quoteResponse = await SupabaseConfig.quotes
          .select()
          .range(randomOffset, randomOffset)
          .single();

      final quote = Quote.fromJson(quoteResponse);

      // Save as daily quote only if user is authenticated
      final currentUser = SupabaseConfig.auth.currentUser;
      if (currentUser != null) {
        try {
          await SupabaseConfig.dailyQuotes.insert({
            'quote_id': quote.id,
            'date': dateStr,
          });
        } catch (e) {
          debugPrint(
            'Error saving daily quote to DB (RLS may be blocking): $e',
          );
        }
      } else {
        debugPrint('Skipping saving daily quote to DB: no authenticated user.');
      }

      _dailyQuote = quote;

      // Schedule notification for this generated daily quote
      try {
        final notificationService = NotificationService();
        await notificationService.scheduleNotificationForQuote(
          quoteId: quote.id,
          quoteText: quote.text,
          author: quote.author,
        );
      } catch (e) {
        debugPrint(
          'Error scheduling notification for generated daily quote: $e',
        );
      }

      // Update widget as well
      try {
        final widgetService = WidgetService();
        await widgetService.updateDailyQuoteWidget(
          quoteId: quote.id,
          quoteText: quote.text,
          author: quote.author,
        );
      } catch (e) {
        debugPrint('Error updating widget for generated daily quote: $e');
      }
    } catch (e) {
      debugPrint('Error generating daily quote: $e');
    }
  }

  // Load quotes by category
  Future<void> loadByCategory(String category) async {
    _selectedCategory = category;
    _currentPage = 0;
    _quotes.clear();
    _hasMore = true;
    await loadQuotes();
  }

  // Search quotes
  Future<void> searchQuotes(String query) async {
    _searchQuery = query;
    _currentPage = 0;
    _quotes.clear();
    _hasMore = true;
    await loadQuotes();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _currentPage = 0;
    _quotes.clear();
    _hasMore = true;
    notifyListeners();
  }

  // Get quote by ID
  Future<Quote?> getQuoteById(String quoteId) async {
    try {
      final response = await SupabaseConfig.quotes
          .select()
          .eq('id', quoteId)
          .single();

      return Quote.fromJson(response);
    } catch (e) {
      debugPrint('Error getting quote by ID: $e');
      return null;
    }
  }

  // Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! ☀️';
    if (hour < 17) return 'Good afternoon! 🌤️';
    return 'Good evening! 🌙';
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

