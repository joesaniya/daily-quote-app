import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _apiUrl = 'r';

  static final List<Quote> _fallbackQuotes = [
    Quote(
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      id: '1',
    ),
    Quote(
      text: 'Innovation distinguishes between a leader and a follower.',
      author: 'Steve Jobs',
      id: '2',
    ),
    Quote(
      text: 'Life is what happens when you\'re busy making other plans.',
      author: 'John Lennon',
      id: '3',
    ),
    Quote(
      text:
          'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      author: 'Winston Churchill',
      id: '4',
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
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching quote: $e');
    }

    return _fallbackQuotes[Random().nextInt(_fallbackQuotes.length)];
  }
}
