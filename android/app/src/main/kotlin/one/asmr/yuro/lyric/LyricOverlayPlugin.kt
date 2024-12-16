package one.asmr.yuro.lyric

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class LyricOverlayPlugin(private val context: Context) : MethodCallHandler {
    private var service: LyricOverlayService? = null
    private val serviceIntent by lazy { Intent(context, LyricOverlayService::class.java) }
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            service = (binder as? LyricOverlayService.LocalBinder)?.service
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            service = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                context.startService(serviceIntent)
                context.bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
                result.success(null)
            }
            "show" -> {
                service?.showLyric("测试歌词")
                result.success(null)
            }
            "hide" -> {
                service?.hideLyric()
                result.success(null)
            }
            "updateLyric" -> {
                val arguments = call.arguments as? Map<*, *>
                val text = arguments?.get("text") as? String ?: "无歌词"
                service?.showLyric(text)
                result.success(null)
            }
            "dispose" -> {
                context.unbindService(serviceConnection)
                context.stopService(serviceIntent)
                service = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
} 