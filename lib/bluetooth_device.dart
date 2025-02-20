import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device_type.dart';

/// 表示蓝牙设备的信息类
/// 注意:信息可能不是实时的
@immutable
class BluetoothDevice {
  /// 设备的MAC地址或平台系统标识符
  /// (如果MAC地址被禁止使用)
  final String address;

  /// 设备的友好名称
  final String? name;

  /// 设备类型(蓝牙标准类型)
  final BluetoothDeviceType type;

  /// 设备是否已连接
  final bool isConnected;

  /// 设备的配对状态
  final BluetoothBondState bondState;

  /// 构造函数
  const BluetoothDevice({
    required this.address,
    this.name,
    this.type = BluetoothDeviceType.unknown,
    this.isConnected = false,
    this.bondState = BluetoothBondState.unknown,
  });

  /// 从Map创建BluetoothDevice对象
  /// 内部用于从平台代码接收对象
  BluetoothDevice.fromMap(final Map<dynamic, dynamic> map)
      : name = map['name']?.toString(),
        address = map['address']!.toString(),
        type = BluetoothDeviceType.parse(map['type']),
        isConnected = map['isConnected'].toString().toLowerCase() == 'true',
        bondState = BluetoothBondState.parse(map['bondState']);

  /// 将BluetoothDevice转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'address': address,
        'type': type.name,
        'isConnected': isConnected,
        'bondState': bondState.name,
      };

  /// 比较两个BluetoothDevice是否相等
  /// 实际上只比较address,因为这是识别设备的最重要且不可变的信息
  @override
  bool operator ==(final Object other) {
    return other is BluetoothDevice && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;

  /// 判断设备是否已配对(可以安全连接)
  bool get isBonded => bondState.isBonded;
}
