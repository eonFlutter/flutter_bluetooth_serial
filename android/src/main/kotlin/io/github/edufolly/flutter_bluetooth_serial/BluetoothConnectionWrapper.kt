package io.github.edufolly.flutter_bluetooth_serial

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.os.AsyncTask
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

/**
 * @author Eduardo Folly
 */
/**
 * 蓝牙连接包装类
 * 用于桥接Flutter端和原生蓝牙连接
 */
class BluetoothConnectionWrapper(
    adapter: BluetoothAdapter,
    messenger: BinaryMessenger,
    private val activity: Activity,
    val id: String,
    private val connections: MutableMap<String, BluetoothConnectionWrapper>,
) : BluetoothConnection(adapter),
    StreamHandler {
    // 用于向Flutter发送数据的通道
    private var readSink: EventSink? = null

    // 读取数据的事件通道
    private val readChannel: EventChannel =
        EventChannel(messenger, "$NAMESPACE/read/$id").also {
            it.setStreamHandler(this)
        }

    /**
     * 开始监听Flutter端的数据请求
     */
    override fun onListen(
        obj: Any?,
        eventSink: EventSink?,
    ) {
        readSink = eventSink
    }

    /**
     * 停止监听Flutter端的数据请求
     */
    override fun onCancel(obj: Any?) {
        // If canceled by local, disconnects,
        // in other case, by remote, does nothing.

        disconnect()

        // True dispose.
        // TODO: Use coroutines!
        AsyncTask.execute {
            readChannel.setStreamHandler(null)
            connections.remove(id)

            Log.d(TAG, "Disconnected (id: $id)")
        }
    }

    /**
     * 接收到数据时的回调
     */
    override fun onRead(data: ByteArray) {
        activity.runOnUiThread {
            readSink?.success(data)
        }
    }

    /**
     * 连接断开时的回调
     */
    override fun onDisconnected(byRemote: Boolean) {
        activity.runOnUiThread {
            if (byRemote) {
                Log.d(TAG, "onDisconnected by remote (id: $id)")
                readSink?.endOfStream()
                readSink = null
            } else {
                Log.d(TAG, "onDisconnected by local (id: $id)")
            }
        }
    }
}
