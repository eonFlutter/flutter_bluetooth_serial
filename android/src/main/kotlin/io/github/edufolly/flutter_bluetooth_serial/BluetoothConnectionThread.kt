package io.github.edufolly.flutter_bluetooth_serial

import android.bluetooth.BluetoothSocket
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

/**
 * @author Eduardo Folly
 */

/**
 * 蓝牙连接线程类
 * 负责处理具体的数据收发
 */
class BluetoothConnectionThread(
    private val socket: BluetoothSocket,
    private val onRead: (data: ByteArray) -> Unit,
    private val onDisconnected: (byRemote: Boolean) -> Unit,
) : Thread() {
    // 输入流,用于接收数据
    private var input: InputStream = socket.inputStream
    
    // 输出流,用于发送数据
    private var output: OutputStream = socket.outputStream
    
    // 是否请求关闭连接
    private var requestedClosing = false

    /**
     * 检查是否已请求关闭连接
     */
    fun isRequestedClosing(): Boolean = requestedClosing

    /**
     * 线程运行函数
     * 循环读取输入流中的数据
     */
    override fun run() {
        val buffer = ByteArray(1024)
        var bytes: Int

        while (!requestedClosing) {
            try {
                bytes = input.read(buffer)
                if (bytes > 0) {
                    onRead(buffer.copyOfRange(0, bytes))
                }
            } catch (e: IOException) {
                // `input.read` throws when closed by remote device.
                break
            }

            try {
                output.close()
            } catch (t: Throwable) {
                // Ignore any kind of Throwable.
            }

            try {
                input.close()
            } catch (t: Throwable) {
                // Ignore any kind of Throwable.
            }

            // TODO: Socket still open?

            // Callback on disconnected, with information which side is closing.
            onDisconnected(!requestedClosing)

            // Just prevent unnecessary `cancel`ing.
            requestedClosing = true
        }
    }

    /**
     * 发送数据
     * @param bytes 要发送的字节数组
     */
    fun write(bytes: ByteArray) {
        // TODO: Really need to catch exceptions?
        output.write(bytes)
    }

    /**
     * 取消连接
     * 关闭socket和输入输出流
     */
    fun cancel() {
        if (requestedClosing) return

        requestedClosing = true

        // Flush output buffers before closing.
        try {
            output.flush()
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        // Close the connection socket.
        // Might be useful (see https://stackoverflow.com/a/22769260/4880243)
        try {
            sleep(111)
            socket.close()
        } catch (t: Throwable) {
            // Ignore any kind of Throwable.
        }

        // TODO: Need to call onDisconnected?
    }
}
