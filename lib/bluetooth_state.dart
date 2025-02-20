/// 蓝牙适配器状态枚举
enum BluetoothState {
  /// 蓝牙已关闭
  off(10),
  /// 蓝牙正在打开
  turningOn(11),
  /// 蓝牙已打开
  on(12),
  /// 蓝牙正在关闭
  turningOff(13),
  /// 错误状态
  error(-1),
  /// 未知状态
  unknown(-2);

  final int value;

  const BluetoothState(this.value);

  /// 将动态值解析为枚举值
  /// @param value 要解析的值
  /// @return 对应的枚举值,如果无法解析则返回 UNKNOWN
  static BluetoothState parse(final dynamic value) {
    final int intValue =
        int.tryParse(value.toString()) ?? BluetoothState.unknown.value;

    return BluetoothState.values.firstWhere(
      (final BluetoothState e) => e.value == intValue,
      orElse: () => BluetoothState.unknown,
    );
  }
}
