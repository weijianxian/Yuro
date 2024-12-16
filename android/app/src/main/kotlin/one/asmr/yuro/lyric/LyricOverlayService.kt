package one.asmr.yuro.lyric

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Binder
import android.os.IBinder
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import one.asmr.yuro.R
import android.view.Gravity

class LyricOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var lyricView: View? = null
    private val binder = LocalBinder()
    
    inner class LocalBinder : Binder() {
        val service: LyricOverlayService
            get() = this@LyricOverlayService
    }
    
    override fun onBind(intent: Intent?): IBinder = binder
    
    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }
    
    fun showLyric(text: String) {
        if (lyricView == null) {
            createLyricView()
        }
        (lyricView as? TextView)?.text = text
    }
    
    private fun createLyricView() {
        lyricView = LayoutInflater.from(this).inflate(R.layout.lyric_overlay, null)
        
        val params = WindowManager.LayoutParams(
            240.dpToPx(),
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = 100
            y = 200
            windowAnimations = 0
        }
        
        windowManager?.addView(lyricView, params)
    }
    
    private fun Int.dpToPx(): Int {
        val scale = resources.displayMetrics.density
        return (this * scale + 0.5f).toInt()
    }
    
    fun hideLyric() {
        try {
            if (lyricView != null) {
                windowManager?.removeView(lyricView)
                lyricView = null
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        hideLyric()
    }
} 