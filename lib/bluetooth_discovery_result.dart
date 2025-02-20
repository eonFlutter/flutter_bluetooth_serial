import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';

/// 蓝牙设备发现结果类，包含设备信息和信号强度
@immutable
class BluetoothDiscoveryResult extends BluetoothDevice {
  /// 信号强度指示(RSSI)，单位dBm
  /// 通常范围在-100到0之间，数值越大表示信号越强
  final int rssi;

  const BluetoothDiscoveryResult({
    required super.address,
    super.name,
    super.type,
    super.isConnected,
    super.bondState,
    this.rssi = 0,
  });

  /// 从平台返回的Map数据创建设备发现结果对象
  BluetoothDiscoveryResult.fromMap(super.map)
      : rssi = int.tryParse(map['rssi'].toString()) ?? 0,
        super.fromMap();

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
        ...super.toMap(),
        'rssi': rssi,
      };
}
