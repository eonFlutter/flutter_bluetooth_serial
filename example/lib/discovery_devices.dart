import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/bluetooth_device_tile.dart';

/// 设备扫描页面
class DiscoveryDevices extends StatefulWidget {
  const DiscoveryDevices({super.key});

  @override
  State<DiscoveryDevices> createState() => _DiscoveryDevicesState();
}

class _DiscoveryDevicesState extends State<DiscoveryDevices> {
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];

  bool _isDiscovering = false;

  final FlutterBluetoothSerial _flutterBluetoothSerialPlugin =
      FlutterBluetoothSerial();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  /// 初始化蓝牙发现状态
  /// 1. 检查当前蓝牙是否正在进行设备发现
  /// 2. 同步更新UI中的发现状态
  Future<void> initPlatformState() async {
    if (mounted) {
      final bool isDiscovering = await _flutterBluetoothSerialPlugin.isDiscovering();
      setState(() {
        _isDiscovering = isDiscovering;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Discovery--1')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Discovering
            Visibility(
              visible: _isDiscovering,
              child: const LinearProgressIndicator(),
            ),

            // Start Discovery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _isDiscovering
                    ? null
                    : () async {
                        await _flutterBluetoothSerialPlugin.startDiscovery();

                        /// 扫描设备回调
                        _flutterBluetoothSerialPlugin.onDiscovery().listen(
                              (final BluetoothDiscoveryResult event) {
                                if (results.contains(event)) {
                                  results.remove(event);
                                }

                                /// 设备过滤
                                if (event.name != null && event.name!.isNotEmpty) {
                                  if (event.rssi > -50) {
                                    setState(() {
                                      results.add(event);
                                    });
                                  }
                                }

                              },
                              cancelOnError: true,
                              onError: (final dynamic e, final StackTrace s) {
                                if (kDebugMode) {
                                  print(e);
                                  print(s);
                                }
                                return initPlatformState();
                              },
                              onDone: initPlatformState,
                            );

                        await initPlatformState();
                      },
                child: const Text('开始扫描'),
              ),
            ),

            // Stop Discovery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: !_isDiscovering
                    ? null
                    : () async {
                        await _flutterBluetoothSerialPlugin.stopDiscovery();

                        await initPlatformState();
                      },
                child: const Text('停止扫描'),
              ),
            ),

            // Discovery List
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (final BuildContext context, final int index) {
                  return BluetoothDeviceTile(
                    results[index],
                    bondDevice: (final BluetoothDevice device) async {
                      final bool bonded = await _flutterBluetoothSerialPlugin
                          .bondDevice(device.address);

                      // if (bonded) {
                      //   await initPlatformState();
                      // }

                      return bonded;
                    },
                    removeBondedDevice: (final BluetoothDevice device) async {
                      final bool removed = await _flutterBluetoothSerialPlugin
                          .removeBondedDevice(device.address);

                      if (removed) {
                        results.remove(device);
                        await initPlatformState();
                      }

                      return removed;
                    },
                  );
                },
              ),
            ),

            // Clear Discovery List
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: results.isEmpty
                    ? null
                    : () => setState(() => results.clear()),
                child: const Text('Clear Discovery List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
