/// 蓝牙设备配对状态枚举
enum BluetoothBondState {
  /// 未配对
  none(10),
  /// 配对中
  bonding(11),
  /// 已配对
  bonded(12),
  /// 错误状态
  error(-1),
  /// 未知状态
  unknown(-2);

  final int value;

  const BluetoothBondState(this.value);

  /// 将动态值解析为枚举值
  /// @param value 要解析的值
  /// @return 对应的枚举值,如果无法解析则返回 unknown
  static BluetoothBondState parse(final dynamic value) {
    final int intValue =
        int.tryParse(value.toString()) ?? BluetoothBondState.unknown.value;

    return BluetoothBondState.values.firstWhere(
      (final BluetoothBondState e) => e.value == intValue,
      orElse: () => BluetoothBondState.unknown,
    );
  }

  /// 判断是否已配对
  bool get isBonded => this == bonded;
}
