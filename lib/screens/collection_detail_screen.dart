import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/share_service.dart';
import '../models/collection.dart';
import '../models/quote.dart';
import '../providers/collection_provider.dart';

class CollectionDetailScreen extends StatefulWidget {
  final Collection collection;

  const CollectionDetailScreen({Key? key, required this.collection})
    : super(key: key);

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  List<Quote>? _quotes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    final quotes = await context
        .read<CollectionsProvider>()
        .loadCollectionQuotes(widget.collection.id);
    setState(() {
      _quotes = quotes;
      _isLoading = false;
    });
  }

  Future<void> _editCollection() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          _EditCollectionDialog(collection: widget.collection),
    );

    if (result != null && mounted) {
      final success = await context
          .read<CollectionsProvider>()
          .updateCollection(
            widget.collection.id,
            name: result['name'],
            description: result['description'],
          );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Collection updated')));
      }
    }
  }

  Future<void> _deleteCollection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text(
          'Are you sure you want to delete "${widget.collection.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context
          .read<CollectionsProvider>()
          .deleteCollection(widget.collection.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
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
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_quotes == null || _quotes!.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              _buildQuotesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.collection.name),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.collections_bookmark, size: 48, color: Colors.white),
              if (widget.collection.description != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.collection.description!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: _editCollection),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _deleteCollection,
        ),
      ],
    );
  }

  Widget _buildQuotesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final quote = _quotes![index];
          return _buildQuoteCard(quote);
        }, childCount: _quotes!.length),
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '— ${quote.author}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    final success = await context
                        .read<CollectionsProvider>()
                        .removeQuoteFromCollection(
                          widget.collection.id,
                          quote.id,
                        );
                    if (success) {
                      _loadQuotes();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quote removed')),
                        );
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ShareService.shareText(quote);
                  },
                ),
              ],
            ),
          ],
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
            Icons.collections_bookmark_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text('No quotes yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Add quotes from the browse page',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCollectionDialog extends StatefulWidget {
  final Collection collection;

  const _EditCollectionDialog({required this.collection});

  @override
  State<_EditCollectionDialog> createState() => _EditCollectionDialogState();
}

class _EditCollectionDialogState extends State<_EditCollectionDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.collection.name);
    _descriptionController = TextEditingController(
      text: widget.collection.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Collection'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'description': _descriptionController.text,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
