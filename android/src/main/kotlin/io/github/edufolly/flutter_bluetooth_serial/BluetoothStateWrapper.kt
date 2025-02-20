package io.github.edufolly.flutter_bluetooth_serial

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

/**
 * @author Eduardo Folly
 */
/**
 * 蓝牙状态包装类
 * 监听并处理蓝牙状态变化
 */
class BluetoothStateWrapper(
    messenger: BinaryMessenger,
    private val connections: MutableMap<String, BluetoothConnectionWrapper>,
) : BroadcastReceiver(),
    StreamHandler {
    // 状态变化事件通道
    private val stateChannel: EventChannel =
        EventChannel(messenger, "$NAMESPACE/state").also {
            it.setStreamHandler(this)
        }

    // 用于向Flutter发送状态变化
    private var stateSink: EventSink? = null

    private lateinit var activity: Activity

    /**
     * 配置必要的参数
     */
    fun config(activity: Activity) {
        this.activity = activity
    }

    fun close() {
        stateChannel.setStreamHandler(null)
    }

    override fun onListen(
        obj: Any?,
        eventSink: EventSink?,
    ) {
        Log.d(TAG, "Listening to bluetooth state changes.")

        stateSink = eventSink

        activity.applicationContext.registerReceiver(
            this,
            IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED),
        )
    }

    override fun onCancel(obj: Any?) {
        Log.d(TAG, "Canceling listening to bluetooth state changes.")

        try {
            activity.applicationContext.unregisterReceiver(this)
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        // TODO: Check if necessary.
        //  stateSink?.endOfStream()
        stateSink = null
    }

    /**
     * 接收蓝牙状态变化广播
     */
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        if (stateSink == null) return

        when (intent.action) {
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                Log.w(TAG, "Clear All Connections!!")
                connections.values.forEach { it.disconnect() }
                connections.clear()

                stateSink?.success(
                    intent.getIntExtra(
                        BluetoothAdapter.EXTRA_STATE,
                        BluetoothDevice.ERROR,
                    ),
                )
            }

            else -> {
                Log.w(TAG, "Unknown bluetooth state received! ${intent.action}")
            }
        }
    }
}
