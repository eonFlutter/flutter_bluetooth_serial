import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_request.dart';
import 'package:flutter_bluetooth_serial/bluetooth_state.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

/// 提供蓝牙功能的核心实现类
/// 包含蓝牙状态管理、设备发现、配对和连接等功能
class FlutterBluetoothSerial {
  /// 监听蓝牙状态变化
  /// 返回一个包含蓝牙状态更新的Stream
  Stream<BluetoothState> onStateChanged() =>
      FlutterBluetoothSerialPlatform.instance.onStateChanged();

  /// 监听设备发现结果
  /// 返回一个包含新发现设备信息的Stream
  Stream<BluetoothDiscoveryResult> onDiscovery() =>
      FlutterBluetoothSerialPlatform.instance.onDiscovery();

  /// 检查设备是否支持蓝牙功能
  Future<bool> isAvailable() =>
      FlutterBluetoothSerialPlatform.instance.isAvailable();

  /// 检查蓝牙是否已启用
  Future<bool> isEnabled() =>
      FlutterBluetoothSerialPlatform.instance.isEnabled();

  /// 打开系统蓝牙设置页面
  Future<void> openSettings() =>
      FlutterBluetoothSerialPlatform.instance.openSettings();

  /// 请求启用蓝牙
  Future<bool> requestEnable() =>
      FlutterBluetoothSerialPlatform.instance.requestEnable();

  /// 请求禁用蓝牙
  Future<bool> requestDisable() =>
      FlutterBluetoothSerialPlatform.instance.requestDisable();

  /// 确保所需的蓝牙权限已获取
  Future<bool> ensurePermissions() =>
      FlutterBluetoothSerialPlatform.instance.ensurePermissions();

  /// 获取本机蓝牙地址
  Future<String?> get address =>
      FlutterBluetoothSerialPlatform.instance.address;

  /// 获取当前蓝牙状态
  Future<BluetoothState> get state =>
      FlutterBluetoothSerialPlatform.instance.state;

  /// 获取本机蓝牙名称
  Future<String?> get name => FlutterBluetoothSerialPlatform.instance.name;

  /// 设置本机蓝牙名称
  Future<bool> setName(final String name) =>
      FlutterBluetoothSerialPlatform.instance.setName(name);

  /// 检查设备是否可被发现
  Future<bool> isDiscoverable() =>
      FlutterBluetoothSerialPlatform.instance.isDiscoverable();

  /// 请求设备可被发现
  /// [durationInSeconds] 可见时长（秒）
  Future<int?> requestDiscoverable({final int? durationInSeconds}) =>
      FlutterBluetoothSerialPlatform.instance
          .requestDiscoverable(durationInSeconds: durationInSeconds);

  /// 检查是否正在搜索设备
  Future<bool> isDiscovering() =>
      FlutterBluetoothSerialPlatform.instance.isDiscovering();

  /// 开始搜索蓝牙设备
  Future<bool> startDiscovery() =>
      FlutterBluetoothSerialPlatform.instance.startDiscovery();

  /// 停止搜索蓝牙设备
  Future<bool> stopDiscovery() =>
      FlutterBluetoothSerialPlatform.instance.stopDiscovery();

  /// 获取指定设备的配对状态
  Future<BluetoothBondState> getDeviceBondState(final String address) =>
      FlutterBluetoothSerialPlatform.instance.getDeviceBondState(address);

  /// 获取已配对设备列表
  Future<List<BluetoothDevice>> getBondedDevices() =>
      FlutterBluetoothSerialPlatform.instance.getBondedDevices();

  /// 移除已配对设备
  Future<bool> removeBondedDevice(final String address) =>
      FlutterBluetoothSerialPlatform.instance.removeBondedDevice(address);

  /// 设置配对请求处理器
  void setPairingRequestHandler(
    final Future<dynamic> Function(BluetoothPairingRequest request)? handler,
  ) =>
      FlutterBluetoothSerialPlatform.instance.setPairingRequestHandler(handler);

  /// 与指定设备配对
  /// [pin] 配对PIN码
  /// [passkeyConfirm] 是否需要确认配对密钥
  Future<bool> bondDevice(
    final String address, {
    final String? pin,
    final bool? passkeyConfirm,
  }) =>
      FlutterBluetoothSerialPlatform.instance.bondDevice(
        address,
        pin: pin,
        passkeyConfirm: passkeyConfirm,
      );

  /// 连接到指定的蓝牙设备
  Future<String> connect(final String address) async =>
      FlutterBluetoothSerialPlatform.instance.connect(address);

  // TODO(edufolly): Write

  /// 断开与指定设备的连接
  Future<void> disconnect(final String id) =>
      FlutterBluetoothSerialPlatform.instance.disconnect(id);
}
