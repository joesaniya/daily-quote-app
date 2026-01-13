package com.example.sample_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class DailyQuoteWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val quote = prefs.getString("daily_quote_text", "") ?: ""
        val author = prefs.getString("daily_quote_author", "") ?: ""

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_daily_quote)
            views.setTextViewText(R.id.widget_quote_text, quote)
            views.setTextViewText(R.id.widget_quote_author, author)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
