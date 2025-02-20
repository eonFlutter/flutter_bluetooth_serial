import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_variant.dart';

/// 蓝牙配对请求类
/// 用于处理配对过程中的请求信息，如PIN码、密钥确认等
@immutable
class BluetoothPairingRequest {
  /// 设备的MAC地址或平台系统标识符
  /// 在某些平台上可能会禁止使用MAC地址而使用其他标识符
  final String? address;

  /// 配对方式
  /// 定义了不同的配对验证方式，如PIN码、密钥等
  final BluetoothPairingVariant variant;

  /// 配对密钥
  /// 用于配对确认的数字密钥
  final int? key;

  /// 创建配对请求实例
  const BluetoothPairingRequest({
    this.address,
    this.variant = BluetoothPairingVariant.unknown,
    this.key,
  });

  /// 从Map创建配对请求对象
  /// 用于从平台代码接收配对请求信息
  BluetoothPairingRequest.fromMap(final Map<dynamic, dynamic> map)
      : address = map['address']?.toString(),
        variant = BluetoothPairingVariant.parse(map['variant']),
        key = int.tryParse(map['key'].toString());
}
