import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuoteProvider with ChangeNotifier {
  Quote? _currentQuote;
  bool _isLoading = false;
  String? _error;

  Quote? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRandomQuote() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentQuote = await QuoteService.fetchRandomQuote();
    } catch (e) {
      _error = 'Failed to load quote';
      debugPrint('Error loading quote: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! ☀️';
    if (hour < 17) return 'Good afternoon! 🌤️';
    return 'Good evening! 🌙';
  }
}
