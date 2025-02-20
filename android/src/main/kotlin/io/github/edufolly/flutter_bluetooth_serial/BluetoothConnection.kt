package io.github.edufolly.flutter_bluetooth_serial

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import java.io.IOException
import java.util.UUID

/**
 * 通用蓝牙串行连接抽象类
 * 负责处理蓝牙设备的连接、断开和数据传输
 */
abstract class BluetoothConnection(
    private val bluetoothAdapter: BluetoothAdapter,
) {
    companion object {
        // 默认的蓝牙串行端口服务UUID
        val DEFAULT_UUID: UUID =
            UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    }

    // 当收到数据时的回调
    abstract fun onRead(data: ByteArray)

    // 当连接断开时的回调
    // @param byRemote 是否由远程设备主动断开
    abstract fun onDisconnected(byRemote: Boolean)

    // 当前的连接线程
    private var connectionThread: BluetoothConnectionThread? = null

    // 检查是否已连接
    private fun isConnected(): Boolean =
        connectionThread?.isRequestedClosing() ?: false

    // TODO: `connect` could be done performed on the other thread
    // TODO: `connect` parameter: timeout
    // TODO: `connect` other methods than `createRfcommSocketToServiceRecord`,
    //  including hidden one raw `createRfcommSocket` (on channel).
    // TODO: how about turning it into a factory?
    // Connects to given device by hardware address

    /**
     * 连接到指定地址的蓝牙设备
     * @param address 蓝牙设备地址
     * @param uuid 服务UUID,默认使用串行端口服务
     */
    @SuppressLint("MissingPermission")
    fun connect(
        address: String,
        uuid: UUID = DEFAULT_UUID,
    ) {
        if (isConnected()) {
            throw IllegalStateException("Already connected")
        }

        val device: BluetoothDevice =
            bluetoothAdapter.getRemoteDevice(address)
                ?: throw IllegalArgumentException("Device not found")

        // TODO: Introduce ConnectionMethod
        val socket: BluetoothSocket =
            device.createRfcommSocketToServiceRecord(uuid)
                ?: throw IOException("Socket connection not established")

        // Cancel discovery, even though we didn't start it
        bluetoothAdapter.cancelDiscovery()

        socket.connect()

        connectionThread =
            BluetoothConnectionThread(
                socket,
                { data -> onRead(data) },
                { byRemote -> onDisconnected(byRemote) },
            ).apply { start() }
    }

    /**
     * 断开当前连接
     */
    fun disconnect() {
//        if (isConnected()) {
        connectionThread?.cancel()
        connectionThread = null
//        }
    }

    /**
     * 向连接的设备写入数据
     * @param bytes 要发送的字节数组
     */
    fun write(bytes: ByteArray) {
        if (!isConnected()) {
            throw IOException("Not connected")
        }

        connectionThread?.write(bytes)
    }
}
