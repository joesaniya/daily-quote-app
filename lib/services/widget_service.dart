import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  Future<void> updateDailyQuoteWidget({
    required String quoteId,
    required String quoteText,
    required String author,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('daily_quote_id', quoteId);
      await HomeWidget.saveWidgetData<String>('daily_quote_text', quoteText);
      await HomeWidget.saveWidgetData<String>('daily_quote_author', author);

      await HomeWidget.updateWidget(name: 'DailyQuoteWidgetProvider');
      debugPrint('✅ Widget updated with quote');
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
