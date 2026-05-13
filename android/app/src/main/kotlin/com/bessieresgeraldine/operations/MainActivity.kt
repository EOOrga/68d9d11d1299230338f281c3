package com.bessieresgeraldine.operations

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val preferences = getSharedPreferences("bessieres_operations", Context.MODE_PRIVATE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.bessieresgeraldine.operations/local_store"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "read" -> {
                    val key = call.argument<String>("key")
                    if (key == null) {
                        result.error("missing_key", "A storage key is required.", null)
                    } else {
                        result.success(preferences.getString(key, null))
                    }
                }
                "write" -> {
                    val key = call.argument<String>("key")
                    val value = call.argument<String>("value")
                    if (key == null || value == null) {
                        result.error("missing_value", "A storage key and value are required.", null)
                    } else {
                        preferences.edit().putString(key, value).apply()
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
