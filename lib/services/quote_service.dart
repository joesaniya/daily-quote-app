import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _apiUrl = 'https://zenquotes.io/api/random';

  static final List<Quote> _fallbackQuotes = [
    Quote(
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      id: '1',
      category: 'Motivation', // ✅ Added category
    ),
    Quote(
      text: 'Innovation distinguishes between a leader and a follower.',
      author: 'Steve Jobs',
      id: '2',
      category: 'Success', // ✅ Added category
    ),
    Quote(
      text: 'Life is what happens when you\'re busy making other plans.',
      author: 'John Lennon',
      id: '3',
      category: 'Wisdom', // ✅ Added category
    ),
    Quote(
      text:
          'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      author: 'Winston Churchill',
      id: '4',
      category: 'Success', // ✅ Added category
    ),
    Quote(
      text: 'Believe you can and you\'re halfway there.',
      author: 'Theodore Roosevelt',
      id: '5',
      category: 'Motivation', // ✅ Added category
    ),
    Quote(
      text: 'The best thing to hold onto in life is each other.',
      author: 'Audrey Hepburn',
      id: '6',
      category: 'Love', // ✅ Added category
    ),
    Quote(
      text: 'I\'m not superstitious, but I am a little stitious.',
      author: 'Michael Scott',
      id: '7',
      category: 'Humor', // ✅ Added category
    ),
  ];

  static Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Quote(
            text: data[0]['q'] ?? '',
            author: data[0]['a'] ?? 'Unknown',
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            category: _assignCategory(
              data[0]['q'] ?? '',
            ), // ✅ Assign category based on quote text
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching quote: $e');
    }

    return _fallbackQuotes[Random().nextInt(_fallbackQuotes.length)];
  }

  // Helper method to assign category based on quote content
  static String _assignCategory(String quoteText) {
    final text = quoteText.toLowerCase();

    // Check for keywords to determine category
    if (text.contains('love') ||
        text.contains('heart') ||
        text.contains('friend')) {
      return 'Love';
    } else if (text.contains('success') ||
        text.contains('achieve') ||
        text.contains('win')) {
      return 'Success';
    } else if (text.contains('work') ||
        text.contains('dream') ||
        text.contains('goal') ||
        text.contains('keep going') ||
        text.contains('never give up')) {
      return 'Motivation';
    } else if (text.contains('funny') ||
        text.contains('laugh') ||
        text.contains('humor')) {
      return 'Humor';
    } else {
      return 'Wisdom'; // Default category
    }
  }

  // Get a random category for variety
  static String _getRandomCategory() {
    final categories = ['Motivation', 'Love', 'Success', 'Wisdom', 'Humor'];
    return categories[Random().nextInt(categories.length)];
  }
}
