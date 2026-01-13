import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials
  // Get these from your Supabase project settings
  static const String supabaseUrl = 'https://lcjnegkaxugmxjyrddhl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxjam5lZ2theHVnbXhqeXJkZGhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyODkwNDYsImV4cCI6MjA4Mzg2NTA0Nn0.wpBx-g2JUPLHpOIy7xYnqQUrXInHk9bODz73B5TH1Ao';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static SupabaseQueryBuilder get quotes => client.from('quotes');

  static SupabaseQueryBuilder get userProfiles => client.from('user_profiles');

  static SupabaseQueryBuilder get userFavorites =>
      client.from('user_favorites');

  static SupabaseQueryBuilder get collections => client.from('collections');

  static SupabaseQueryBuilder get collectionItems =>
      client.from('collection_items');

  static SupabaseQueryBuilder get dailyQuotes => client.from('daily_quotes');
}
