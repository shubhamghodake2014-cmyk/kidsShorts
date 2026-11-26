package com.example.kidz_shorts

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.kidz_shorts/kids_mode"
        private const val PREFS_NAME = "kidzshorts_kids_mode"
        private const val KEY_PROTECTION_ENABLED = "protection_enabled"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setProtectionEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
                        .edit()
                        .putBoolean(KEY_PROTECTION_ENABLED, enabled)
                        .apply()
                    result.success(true)
                }

                "isProtectionEnabled" -> {
                    val enabled = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
                        .getBoolean(KEY_PROTECTION_ENABLED, false)
                    result.success(enabled)
                }

                "isAccessibilityEnabled" -> {
                    result.success(isKidsModeAccessibilityEnabled())
                }

                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isKidsModeAccessibilityEnabled(): Boolean {
        val expected = ComponentName(this, KidsModeAccessibilityService::class.java)
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)

        while (splitter.hasNext()) {
            val component = ComponentName.unflattenFromString(splitter.next())
            if (component == expected) return true
        }

        return false
    }
}
