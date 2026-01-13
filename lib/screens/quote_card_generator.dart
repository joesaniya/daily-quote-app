import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/quote.dart';
import '../services/share_service.dart';

enum CardStyle { minimal, gradient, illustrated, modern }

class QuoteCardGenerator extends StatefulWidget {
  final Quote quote;

  const QuoteCardGenerator({Key? key, required this.quote}) : super(key: key);

  @override
  State<QuoteCardGenerator> createState() => _QuoteCardGeneratorState();
}

class _QuoteCardGeneratorState extends State<QuoteCardGenerator> {
  final GlobalKey _cardKey = GlobalKey();
  CardStyle _selectedStyle = CardStyle.gradient;
  bool _isGenerating = false;

  Future<void> _shareAsImage() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _captureCardBytes();
      if (bytes == null) throw 'Failed to capture image';

      await ShareService.shareImageBytes(bytes, widget.quote);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveAsImage() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _captureCardBytes();
      if (bytes == null) throw 'Failed to capture image';

      final success = await ShareService.saveImageToGallery(
        bytes,
        name: 'quote_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Saved to gallery' : 'Failed to save image',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<Uint8List?> _captureCardBytes() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('capture error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Card'),
        actions: [
          if (_isGenerating)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.text_snippet),
              onPressed: () => ShareService.shareText(widget.quote),
              tooltip: 'Share as Text',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _saveAsImage,
              tooltip: 'Save image to device',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareAsImage,
              tooltip: 'Share as Image',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: RepaintBoundary(key: _cardKey, child: _buildCard()),
              ),
            ),
          ),
          _buildStyleSelector(),
        ],
      ),
    );
  }

  Widget _buildCard() {
    switch (_selectedStyle) {
      case CardStyle.minimal:
        return _MinimalCard(quote: widget.quote);
      case CardStyle.gradient:
        return _GradientCard(quote: widget.quote);
      case CardStyle.illustrated:
        return _IllustratedCard(quote: widget.quote);
      case CardStyle.modern:
        return _ModernCard(quote: widget.quote);
    }
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Style',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: CardStyle.values.map((style) {
                final isSelected = _selectedStyle == style;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStyle = style),
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getStyleIcon(style),
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStyleName(style),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStyleIcon(CardStyle style) {
    switch (style) {
      case CardStyle.minimal:
        return Icons.notes;
      case CardStyle.gradient:
        return Icons.gradient;
      case CardStyle.illustrated:
        return Icons.brush;
      case CardStyle.modern:
        return Icons.auto_awesome;
    }
  }

  String _getStyleName(CardStyle style) {
    switch (style) {
      case CardStyle.minimal:
        return 'Minimal';
      case CardStyle.gradient:
        return 'Gradient';
      case CardStyle.illustrated:
        return 'Artistic';
      case CardStyle.modern:
        return 'Modern';
    }
  }
}

// Card Style Implementations
class _MinimalCard extends StatelessWidget {
  final Quote quote;
  const _MinimalCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.format_quote, size: 40, color: Colors.black26),
          const SizedBox(height: 24),
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 24,
              height: 1.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '— ${quote.author}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientCard extends StatelessWidget {
  final Quote quote;
  const _GradientCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    final color = QuoteCategory.getColor(quote.category);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  QuoteCategory.getEmoji(quote.category),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  quote.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.format_quote, size: 48, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 26,
              height: 1.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '— ${quote.author}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustratedCard extends StatelessWidget {
  final Quote quote;
  const _IllustratedCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  QuoteCategory.getEmoji(quote.category),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  quote.text,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.6,
                    color: Color(0xFF2C1810),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '— ${quote.author}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B4423),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernCard extends StatelessWidget {
  final Quote quote;
  const _ModernCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: QuoteCategory.getColor(quote.category),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Text(
                  QuoteCategory.getEmoji(quote.category),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  quote.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.text,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      color: QuoteCategory.getColor(quote.category),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        quote.author,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
