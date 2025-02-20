package io.github.edufolly.flutter_bluetooth_serial

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

const val TAG = "FlutterBluetoothPlugin"
const val NAMESPACE = "flutter_bluetooth_serial"

/**
 * 检查设备是否已连接
 */
fun checkIsDeviceConnected(device: BluetoothDevice?): Boolean =
    try {
        device
            ?.javaClass
            ?.getMethod("isConnected")
            ?.invoke(device)
            ?.toString()
            ?.lowercase() == "true"
    } catch (t: Throwable) {
        false
    }

/**
 * Flutter蓝牙串行通信插件主类
 * 负责初始化和管理各个功能模块
 */
class FlutterBluetoothSerialPlugin :
    FlutterPlugin,
    ActivityAware {
    // 存储所有活动的蓝牙连接
    private val connections = mutableMapOf<String, BluetoothConnectionWrapper>()

    // 设备发现包装器
    private lateinit var discoveryWrapper: BluetoothDiscoveryWrapper
    
    // 状态监听包装器
    private lateinit var stateWrapper: BluetoothStateWrapper
    
    // 方法调用包装器
    private lateinit var methodsWrapper: BluetoothMethodsWrapper

    /**
     * 插件绑定到Flutter引擎时调用
     */
    override fun onAttachedToEngine(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    ) {
        Log.v("FlutterBluetoothSerial", "Attached to engine!")

        val messenger = flutterPluginBinding.binaryMessenger

        discoveryWrapper = BluetoothDiscoveryWrapper(messenger)

        stateWrapper = BluetoothStateWrapper(messenger, connections)

        methodsWrapper = BluetoothMethodsWrapper(messenger, connections)
    }

    /**
     * 插件从Flutter引擎解绑时调用
     */
    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding,
    ) {
        discoveryWrapper.close()

        stateWrapper.close()

        methodsWrapper.close()
    }

    /**
     * 插件绑定到Activity时调用
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val activity = binding.activity

        val manager =
            activity.getSystemService(
                Context.BLUETOOTH_SERVICE,
            ) as BluetoothManager?

        val bluetoothAdapter = manager?.adapter

        discoveryWrapper.config(activity, bluetoothAdapter)

        stateWrapper.config(activity)

        methodsWrapper.config(activity, discoveryWrapper, bluetoothAdapter)

        binding.addActivityResultListener(methodsWrapper)

        binding.addRequestPermissionsResultListener(methodsWrapper)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding,
    ) {
    }

    override fun onDetachedFromActivity() {
    }
}
