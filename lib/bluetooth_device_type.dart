/// 蓝牙设备类型枚举
enum BluetoothDeviceType {
  /// 未知设备类型
  unknown(-2),
  error(-1),
  
  /// 经典蓝牙设备
  classic(1),
  
  /// 低功耗蓝牙设备(BLE)
  le(2),
  
  /// 双模蓝牙设备(同时支持经典蓝牙和BLE)
  dual(3);

  final int value;
  
  const BluetoothDeviceType(this.value);

  /// 将动态值解析为枚举值
  /// @param value 要解析的值
  /// @return 对应的枚举值,如果无法解析则返回 unknown
  static BluetoothDeviceType parse(final dynamic value) {
    final int intValue = 
        int.tryParse(value.toString()) ?? BluetoothDeviceType.unknown.value;

    return BluetoothDeviceType.values.firstWhere(
      (final BluetoothDeviceType e) => e.value == intValue,
      orElse: () => BluetoothDeviceType.unknown,
    );
  }
}
