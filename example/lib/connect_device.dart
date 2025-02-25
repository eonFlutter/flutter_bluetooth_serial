import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// 设备连接页面
class ConnectDevice extends StatefulWidget {
  final BluetoothDevice device;

  const ConnectDevice(this.device, {super.key});

  @override
  State<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends State<ConnectDevice> {
  final FlutterBluetoothSerial _flutterBluetoothSerialPlugin = FlutterBluetoothSerial();

  String? _id;

  @override
  void initState() {
    if (widget.device.isConnected) {
      _id = widget.device.address;
    }
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect Device'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(widget.device.address),
            Text(widget.device.name ?? ''),

            // Connect
            ElevatedButton(
              onPressed: _id != null
                  ? null
                  : () async {
                      final String id = await _flutterBluetoothSerialPlugin.connect(widget.device.address);

                      // 监听数据
                      // _flutterBluetoothSerialPlugin.onRead(id).listen(
                      //       (Uint8List data) {
                      //     print('收到数据: ${String.fromCharCodes(data)}');
                      //   },
                      //   onError: (error) {
                      //     print('接收错误: $error');
                      //   },
                      //   onDone: () {
                      //     print('连接已关闭');
                      //   },
                      // );

                      if (kDebugMode) {
                        print('Id: $id');
                      }

                      setState(() => _id = id);
                    },
              child: const Text('Connect'),
            ),

            // 断开连接
            ElevatedButton(
              onPressed: _id == null
                  ? null
                  : () {
                      _flutterBluetoothSerialPlugin.disconnect(_id!);

                      setState(() => _id = null);
                    },
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
