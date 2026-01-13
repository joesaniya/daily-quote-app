package com.example.sample_app

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.sample_app/share"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "saveImageToGallery" -> {
          val path = call.argument<String>("path")
          val name = call.argument<String>("name")
          val ok = saveImageToGallery(path, name)
          result.success(ok)
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun saveImageToGallery(path: String?, name: String?): Boolean {
    if (path == null) return false
    try {
      val file = File(path)
      val filename = name ?: file.name
      val resolver = applicationContext.contentResolver
      val values = ContentValues().apply {
        put(MediaStore.Images.Media.DISPLAY_NAME, filename)
        put(MediaStore.Images.Media.MIME_TYPE, "image/png")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          put(MediaStore.Images.Media.RELATIVE_PATH, "DCIM/Quotient")
          put(MediaStore.Images.Media.IS_PENDING, 1)
        }
      }

      val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
      uri?.let {
        resolver.openOutputStream(uri).use { out ->
          file.inputStream().use { input ->
            input.copyTo(out!!)
          }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          values.clear()
          values.put(MediaStore.Images.Media.IS_PENDING, 0)
          resolver.update(uri, values, null, null)
        }
        return true
      } ?: return false
    } catch (e: Exception) {
      Log.e("MainActivity", "saveImageToGallery failed", e)
      return false
    }
  }
}
