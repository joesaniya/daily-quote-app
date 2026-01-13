import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/quote_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/quote.dart';

class BrowseQuotesPage extends StatefulWidget {
  final String? initialCategory;

  const BrowseQuotesPage({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<BrowseQuotesPage> createState() => _BrowseQuotesPageState();
}

class _BrowseQuotesPageState extends State<BrowseQuotesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuoteProvider>();
      if (_selectedCategory != null) {
        provider.loadByCategory(_selectedCategory!);
      } else {
        provider.loadQuotes(refresh: true);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<QuoteProvider>().loadQuotes();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<QuoteProvider>().searchQuotes(query);
  }

  void _onCategorySelected(String? category) {
    setState(() => _selectedCategory = category);
    if (category != null) {
      context.read<QuoteProvider>().loadByCategory(category);
    } else {
      context.read<QuoteProvider>().clearFilters();
      context.read<QuoteProvider>().loadQuotes(refresh: true);
    }
  }

  Future<void> _onRefresh() async {
    await context.read<QuoteProvider>().loadQuotes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              if (_showFilters) _buildFilters(),
              Expanded(child: _buildQuotesList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search quotes or authors...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: _showFilters
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: _showFilters
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                ...QuoteCategory.all.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(category, category),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    final color = category != null
        ? QuoteCategory.getColor(category)
        : Theme.of(context).colorScheme.primary;

    return Material(
      color: isSelected ? color : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _onCategorySelected(category),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category != null) ...[
                Text(
                  QuoteCategory.getEmoji(category),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotesList() {
    return Consumer2<QuoteProvider, FavoritesProvider>(
      builder: (context, quoteProvider, favoritesProvider, _) {
        if (quoteProvider.isLoading && quoteProvider.quotes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quoteProvider.quotes.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: quoteProvider.quotes.length +
                (quoteProvider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == quoteProvider.quotes.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final quote = quoteProvider.quotes[index];
              final isFavorite = favoritesProvider.isFavorite(quote.id);

              return _buildQuoteCard(quote, isFavorite, favoritesProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuoteCard(
    Quote quote,
    bool isFavorite,
    FavoritesProvider favoritesProvider,
  ) {
    final color = QuoteCategory.getColor(quote.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      QuoteCategory.getEmoji(quote.category),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      quote.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quote Text
              Text(
                quote.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
              ),

              const SizedBox(height: 12),

              // Author & Actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${quote.author}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      favoritesProvider.toggleFavorite(quote);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite ? 'Removed from saved' : 'Saved!',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.grey),
                    onPressed: () {
                      Share.share(
                        '"${quote.text}"\n\n— ${quote.author}',
                        subject: 'Quote',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No quotes found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }
}