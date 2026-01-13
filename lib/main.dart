import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_app/config/supa_base_config.dart';
import 'package:sample_app/providers/collection_provider.dart';
import 'package:sample_app/screens/home_page.dart';
import 'package:sample_app/screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/quote_provider.dart';
import 'providers/favorites_provider.dart';

import 'providers/settings_provider.dart';


/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const QuoteVaultApp());
}

class QuoteVaultApp extends StatelessWidget {
  const QuoteVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, _) {
          return MaterialApp(
            title: 'QuoteVault',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(
              brightness: Brightness.light,
              accentColor: settingsProvider.userProfile?.accentColor ?? 'purple',
            ),
            darkTheme: _buildTheme(
              brightness: Brightness.dark,
              accentColor: settingsProvider.userProfile?.accentColor ?? 'purple',
            ),
            themeMode: settingsProvider.themeMode,
            home: _buildHome(authProvider),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required String accentColor,
  }) {
    Color seedColor;
    switch (accentColor) {
      case 'blue':
        seedColor = const Color(0xFF2196F3);
        break;
      case 'green':
        seedColor = const Color(0xFF4CAF50);
        break;
      case 'orange':
        seedColor = const Color(0xFFFF9800);
        break;
      case 'purple':
      default:
        seedColor = const Color(0xFF6B4EFF);
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      fontFamily: 'Poppins',
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    // Show loading while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate based on auth state
    return authProvider.isAuthenticated 
        ? const HomePage() 
        : const LoginScreen();
  }
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const QuoteVaultApp());
}

class QuoteVaultApp extends StatelessWidget {
  const QuoteVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, _) {
          return MaterialApp(
            title: 'QuoteVault',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(
              brightness: Brightness.light,
              accentColor: settingsProvider.accentColor,
            ),
            darkTheme: _buildTheme(
              brightness: Brightness.dark,
              accentColor: settingsProvider.accentColor,
            ),
            themeMode: settingsProvider.themeMode,
            home: _buildHome(authProvider),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required String accentColor,
  }) {
    Color seedColor;
    switch (accentColor) {
      case 'blue':
        seedColor = const Color(0xFF2196F3);
        break;
      case 'green':
        seedColor = const Color(0xFF4CAF50);
        break;
      case 'orange':
        seedColor = const Color(0xFFFF9800);
        break;
      case 'purple':
      default:
        seedColor = const Color(0xFF6B4EFF);
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      fontFamily: 'Poppins',
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    // Show loading while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate based on auth state
    return authProvider.isAuthenticated 
        ? const HomePage() 
        : const LoginScreen();
  }
}


/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quote_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const DailyQuoteApp());
}

class DailyQuoteApp extends StatelessWidget {
  const DailyQuoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Daily Quote',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6B4EFF),
                brightness: Brightness.light,
              ),
              fontFamily: 'Poppins',
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6B4EFF),
                brightness: Brightness.dark,
              ),
              fontFamily: 'Poppins',
            ),
            themeMode: settingsProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
*/