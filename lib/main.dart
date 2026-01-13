import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_app/config/supa_base_config.dart';
import 'package:sample_app/providers/collection_provider.dart';
import 'package:sample_app/screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/quote_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'package:sample_app/core/navigation.dart';
import 'package:sample_app/services/notification_service.dart';
import 'package:sample_app/screens/quote_detail_screen.dart';
import 'package:home_widget/home_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize notifications
  await NotificationService().initialize();

  // Initialize home widget background callback (best-effort)
  try {
    await HomeWidget.setAppGroupId('group.com.example.quotevault');
  } catch (e) {
    // ignore if not configured
  }

  HomeWidget.registerBackgroundCallback((uri) async {
    debugPrint('HomeWidget background callback triggered: $uri');
    // No-op for now; WidgetService updates are done from app when daily quote changes
  });

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
            navigatorKey: navigatorKey,
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
            onGenerateRoute: (settings) {
              // Deep link route for quote: /quote/<id>
              final uri = Uri.parse(settings.name ?? '');
              if (uri.pathSegments.isNotEmpty &&
                  uri.pathSegments.first == 'quote') {
                final id = uri.pathSegments.length > 1
                    ? uri.pathSegments[1]
                    : null;
                if (id != null) {
                  return MaterialPageRoute(
                    builder: (_) => QuoteDetailScreen(quoteId: id),
                  );
                }
              }
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            },
            home: const SplashScreen(),
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

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',

      // Enhanced Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      ),

      // Enhanced App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),

      // Enhanced Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),

      // Enhanced Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Enhanced Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Enhanced Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Enhanced Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: seedColor,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
        backgroundColor: brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_app/config/supa_base_config.dart';
import 'package:sample_app/providers/collection_provider.dart';
import 'package:sample_app/screens/home_page.dart';
import 'package:sample_app/screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/quote_provider.dart';
import 'providers/favorites_provider.dart';

import 'providers/settings_provider.dart';




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


*/
