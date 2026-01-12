
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/quote_provider.dart';
import '../providers/favorites_provider.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _pages = const [
    _HomeView(),
    FavoritesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuote();
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadQuote() async {
    _fadeController.reset();
    await context.read<QuoteProvider>().loadRandomQuote();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeView(
            fadeAnimation: _fadeAnimation,
            scaleAnimation: _scaleAnimation,
            scaleController: _scaleController,
            onLoadQuote: _loadQuote,
          ),
          const FavoritesPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  final Animation<double>? fadeAnimation;
  final Animation<double>? scaleAnimation;
  final AnimationController? scaleController;
  final VoidCallback? onLoadQuote;

  const _HomeView({
    this.fadeAnimation,
    this.scaleAnimation,
    this.scaleController,
    this.onLoadQuote,
  });

  Future<void> _toggleFavorite(BuildContext context) async {
    final quoteProvider = context.read<QuoteProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final currentQuote = quoteProvider.currentQuote;

    if (currentQuote == null) return;

    final wasFavorite = favoritesProvider.isFavorite(currentQuote.id);
    await favoritesProvider.toggleFavorite(currentQuote);

    scaleController?.forward().then((_) => scaleController?.reverse());

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite ? 'Removed from favorites' : '❤️ Added to favorites',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareQuote(BuildContext context) {
    final currentQuote = context.read<QuoteProvider>().currentQuote;
    if (currentQuote == null) return;

    Share.share(
      '"${currentQuote.text}"\n\n- ${currentQuote.author}',
      subject: 'Daily Quote',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildQuoteContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Quote',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Consumer<QuoteProvider>(
                builder: (context, provider, _) {
                  return Text(
                    provider.getGreeting(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.format_quote,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteContent(BuildContext context) {
    return Consumer2<QuoteProvider, FavoritesProvider>(
      builder: (context, quoteProvider, favoritesProvider, _) {
        if (quoteProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (quoteProvider.error != null) {
          return Center(
            child: Text(
              quoteProvider.error!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final quote = quoteProvider.currentQuote;
        if (quote == null) {
          return const SizedBox.shrink();
        }

        final isFavorite = favoritesProvider.isFavorite(quote.id);

        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuoteCard(context, quote),
              const SizedBox(height: 32),
              _buildActionButtons(context, isFavorite),
            ],
          ),
        );

        if (fadeAnimation != null) {
          return FadeTransition(opacity: fadeAnimation!, child: content);
        }

        return content;
      },
    );
  }

  Widget _buildQuoteCard(BuildContext context, quote) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            quote.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '— ${quote.author}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isFavorite) {
    Widget favoriteButton = _buildActionButton(
      context: context,
      icon: isFavorite ? Icons.favorite : Icons.favorite_outline,
      onPressed: () => _toggleFavorite(context),
      color: Colors.red,
    );

    if (scaleAnimation != null) {
      favoriteButton = ScaleTransition(
        scale: scaleAnimation!,
        child: favoriteButton,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        favoriteButton,
        const SizedBox(width: 16),
        _buildActionButton(
          context: context,
          icon: Icons.share,
          onPressed: () => _shareQuote(context),
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context: context,
          icon: Icons.refresh,
          onPressed: onLoadQuote ?? () {},
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}