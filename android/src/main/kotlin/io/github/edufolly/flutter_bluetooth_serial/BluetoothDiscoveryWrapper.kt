package io.github.edufolly.flutter_bluetooth_serial

import android.annotation.SuppressLint
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
 * 蓝牙设备发现包装类
 * 用于处理蓝牙设备的搜索和发现
 */
class BluetoothDiscoveryWrapper(
    messenger: BinaryMessenger,
) : BroadcastReceiver(),
    StreamHandler {
    // 设备发现事件通道
    private val discoveryChannel =
        EventChannel(messenger, "$NAMESPACE/discovery").also {
            it.setStreamHandler(this)
        }

    // 用于向Flutter发送发现的设备信息
    private var discoverySink: EventSink? = null

    private lateinit var activity: Activity

    private var bluetoothAdapter: BluetoothAdapter? = null

    /**
     * 配置必要的参数
     */
    fun config(
        activity: Activity,
        bluetoothAdapter: BluetoothAdapter?,
    ) {
        this.activity = activity
        this.bluetoothAdapter = bluetoothAdapter
    }

    /**
     * 关闭发现通道
     */
    fun close() {
        discoveryChannel.setStreamHandler(null)
    }

    override fun onListen(
        obj: Any?,
        eventSink: EventSink?,
    ) {
        Log.d(TAG, "Listening to bluetooth discovery events.")

        discoverySink = eventSink
    }

    override fun onCancel(obj: Any?) {
        Log.d(TAG, "Canceling listening to bluetooth discovery events.")

        discoverySink = null
    }

    /**
     * 接收蓝牙广播事件
     */
    @SuppressLint("MissingPermission")
    @Suppress("DEPRECATION")
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        if (discoverySink == null) return

        when (intent.action) {
            BluetoothDevice.ACTION_FOUND -> {
                // TODO: getParcelableExtra is deprecated.
                val device: BluetoothDevice? =
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)

                // TODO !BluetoothClass!
                //  final BluetoothClass deviceClass =
                //  intent.getParcelableExtra(BluetoothDevice.EXTRA_CLASS);

                // TODO ? !EXTRA_NAME!
                //  final String extraName =
                //  intent.getStringExtra(BluetoothDevice.EXTRA_NAME);

                val deviceRSSI =
                    intent.getShortExtra(
                        BluetoothDevice.EXTRA_RSSI,
                        Short.MIN_VALUE,
                    )

                Log.d(TAG, "Discovered ${device?.address}")

                discoverySink?.success(
                    mapOf(
                        "address" to device?.address,
                        "name" to device?.name,
                        "type" to (device?.type ?: -1),
                        "isConnected" to checkIsDeviceConnected(device),
                        "bondState" to (device?.bondState ?: -1),
                        "rssi" to deviceRSSI,
                    ),
                )
            }

            BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                Log.d(TAG, "Discovery finished.")

                stopDiscovery()
            }

            else -> {
                Log.w(
                    TAG,
                    "Unknown bluetooth discovery event received! " +
                        "${intent.action}",
                )
            }
        }
    }

    /**
     * 停止设备发现
     */
    @SuppressLint("MissingPermission")
    fun stopDiscovery() {
        Log.d(TAG, "Stopping bluetooth discovery.")
        try {
            activity.applicationContext.unregisterReceiver(this)
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        bluetoothAdapter?.cancelDiscovery()

        discoverySink?.endOfStream()
        discoverySink = null
    }

    /**
     * 开始设备发现
     */
    @SuppressLint("MissingPermission")
    fun startDiscovery() {
        Log.d(TAG, "Starting bluetooth discovery.")

        activity.applicationContext.registerReceiver(
            this,
            IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            },
        )

        bluetoothAdapter?.startDiscovery()
    }
}
