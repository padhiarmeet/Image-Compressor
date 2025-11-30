package com.meet.imagecompressor

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Each button opens app with different page index
                setOnClickPendingIntent(R.id.btn_compress, createIntent(context, 0))
                setOnClickPendingIntent(R.id.btn_history, createIntent(context, 1))
                setOnClickPendingIntent(R.id.btn_pdf, createIntent(context, 2))
                setOnClickPendingIntent(R.id.btn_format, createIntent(context, 3))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun createIntent(context: Context, pageIndex: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("page_index", pageIndex)
        }
        
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        // Use unique request code for each button
        return PendingIntent.getActivity(context, pageIndex, intent, flags)
    }
}
