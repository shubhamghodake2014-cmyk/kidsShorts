package com.example.kidz_shorts

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.SystemClock

class KidsModeAccessibilityService : AccessibilityService() {
    companion object {
        private const val PREFS_NAME = "kidzshorts_kids_mode"
        private const val KEY_PROTECTION_ENABLED = "protection_enabled"
        private const val REDIRECT_DELAY_MS = 350L
        private const val REDIRECT_COOLDOWN_MS = 1200L
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastRedirectAt = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val enabled = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
            .getBoolean(KEY_PROTECTION_ENABLED, false)

        if (!enabled) return

        val foregroundPackage = event?.packageName?.toString() ?: return
        if (foregroundPackage == packageName) return

        val now = SystemClock.elapsedRealtime()
        if (now - lastRedirectAt < REDIRECT_COOLDOWN_MS) return
        lastRedirectAt = now

        mainHandler.removeCallbacks(redirectToKidzShorts)
        mainHandler.postDelayed(redirectToKidzShorts, REDIRECT_DELAY_MS)
    }

    private val redirectToKidzShorts = Runnable {
        val enabled = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
            .getBoolean(KEY_PROTECTION_ENABLED, false)

        if (!enabled) return@Runnable

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: return@Runnable

        launchIntent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
        )

        try {
            startActivity(launchIntent)
        } catch (_: Exception) {
            // Android may block some background launches depending on OS policy.
        }
    }

    override fun onInterrupt() {
        // No ongoing feedback operation to interrupt.
    }

    override fun onDestroy() {
        mainHandler.removeCallbacks(redirectToKidzShorts)
        super.onDestroy()
    }
}
