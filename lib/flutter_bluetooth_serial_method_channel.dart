import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/bluetooth_bond_state.dart';
import 'package:flutter_bluetooth_serial/bluetooth_device.dart';
import 'package:flutter_bluetooth_serial/bluetooth_discovery_result.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_request.dart';
import 'package:flutter_bluetooth_serial/bluetooth_pairing_variant.dart';
import 'package:flutter_bluetooth_serial/bluetooth_state.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial_platform_interface.dart';

/// 通过 MethodChannel 实现与平台原生代码通信的蓝牙功能类
class MethodChannelFlutterBluetoothSerial
    extends FlutterBluetoothSerialPlatform {
  /// 定义插件的命名空间
  static const String namespace = 'flutter_bluetooth_serial';

  /// 用于监听蓝牙状态变化的事件通道
  @visibleForTesting
  final EventChannel stateChannel = const EventChannel('$namespace/state');

  /// 监听蓝牙状态变化的流
  @override
  Stream<BluetoothState> onStateChanged() {
    return stateChannel.receiveBroadcastStream().map(BluetoothState.parse);
  }

  /// 用于监听设备发现结果的事件通道
  @visibleForTesting
  final EventChannel discoveryChannel =
      const EventChannel('$namespace/discovery');

  /// 监听设备发现结果的流
  @override
  Stream<BluetoothDiscoveryResult> onDiscovery() {
    return discoveryChannel.receiveBroadcastStream().map(
          (final dynamic e) =>
              BluetoothDiscoveryResult.fromMap(e as Map<dynamic, dynamic>),
        );
  }

  /// 用于调用平台方法的通道
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('$namespace/methods');

  /// 配对请求处理函数
  Future<dynamic> Function(BluetoothPairingRequest request)?
      _pairingRequestHandler;

  /// 构造函数，设置方法调用处理器
  MethodChannelFlutterBluetoothSerial() {
    methodChannel.setMethodCallHandler((final MethodCall call) async {
      switch (call.method) {
        case 'handlePairingRequest':
          if (_pairingRequestHandler != null) {
            return _pairingRequestHandler!(
              BluetoothPairingRequest.fromMap(call.arguments),
            );
          }

        default:
          throw Exception(
            'unknown common code method ${call.method} not implemented',
          );
      }
    });
  }

  /// 检查设备是否支持蓝牙功能
  @override
  Future<bool> isAvailable() async =>
      (await methodChannel.invokeMethod<bool>('isAvailable')) ?? false;

  /// 检查蓝牙是否已启用
  @override
  Future<bool> isEnabled() async =>
      (await methodChannel.invokeMethod<bool>('isEnabled')) ?? false;

  /// 打开系统蓝牙设置页面
  @override
  Future<void> openSettings() async =>
      methodChannel.invokeMethod<void>('openSettings');

  /// 请求启用蓝牙
  /// 可能会弹出用户确认对话框
  @override
  Future<bool> requestEnable() async =>
      (await methodChannel.invokeMethod<bool>('requestEnable')) ?? false;

  /// 请求禁用蓝牙
  @override
  Future<bool> requestDisable() async =>
      (await methodChannel.invokeMethod<bool>('requestDisable')) ?? false;

  /// 确保所需的蓝牙权限已获取
  @override
  Future<bool> ensurePermissions() async =>
      (await methodChannel.invokeMethod<bool>('ensurePermissions')) ?? false;

  /// 获取本机蓝牙地址
  /// 注意：从Android 6.0开始，第三方应用可能无法获取MAC地址
  @override
  Future<String?> get address =>
      methodChannel.invokeMethod<String>('getAddress');

  /// 获取当前蓝牙状态
  @override
  Future<BluetoothState> get state async => BluetoothState.parse(
        (await methodChannel.invokeMethod<int>('getState')) ?? -2,
      );

  /// 获取本机蓝牙名称
  /// 此名称对其他蓝牙设备可见
  @override
  Future<String?> get name => methodChannel.invokeMethod<String>('getName');

  /// 设置本机蓝牙名称
  /// 名称最大长度为248字节(UTF-8编码)
  /// 但多数远程设备只能显示前40个字符
  @override
  Future<bool> setName(final String name) async =>
      (await methodChannel.invokeMethod<bool>(
        'setName',
        <String, dynamic>{'name': name},
      )) ??
      false;

  /// 检查设备是否可被发现
  @override
  Future<bool> isDiscoverable() async =>
      (await methodChannel.invokeMethod<bool>('isDiscoverable')) ?? false;

  /// 请求设备可被发现
  /// 返回获得的可见时长(秒)，如果失败返回-1
  /// 注意：某些设备可能会限制最大可见时长为120秒、300秒或3600秒
  @override
  Future<int?> requestDiscoverable({final int? durationInSeconds}) =>
      methodChannel.invokeMethod<int>(
        'requestDiscoverable',
        durationInSeconds == null
            ? null
            : <String, dynamic>{
                'duration': durationInSeconds,
              },
      );

  /// 检查是否正在搜索设备
  @override
  Future<bool> isDiscovering() async =>
      (await methodChannel.invokeMethod<bool>('isDiscovering')) ?? false;

  /// 开始搜索蓝牙设备
  @override
  Future<bool> startDiscovery() async =>
      (await methodChannel.invokeMethod<bool>('startDiscovery')) ?? false;

  /// 停止搜索蓝牙设备
  @override
  Future<bool> stopDiscovery() async =>
      (await methodChannel.invokeMethod<bool>('stopDiscovery')) ?? false;

  /// 获取指定设备的配对状态
  /// 可能从系统缓存中获取
  @override
  Future<BluetoothBondState> getDeviceBondState(final String address) async =>
      BluetoothBondState.parse(
        await methodChannel.invokeMethod<int>(
          'getDeviceBondState',
          <String, dynamic>{'address': address},
        ),
      );

  /// 获取已配对设备列表
  @override
  Future<List<BluetoothDevice>> getBondedDevices() async =>
      (await methodChannel.invokeMethod<List<dynamic>>('getBondedDevices'))
          ?.map(
            (final dynamic e) =>
                BluetoothDevice.fromMap(e as Map<dynamic, dynamic>),
          )
          .toList() ??
      <BluetoothDevice>[];

  /// 移除已配对设备
  /// 返回true表示成功解除配对，false表示取消或失败
  /// 注意：可能不是所有Android设备都支持此功能
  @override
  Future<bool> removeBondedDevice(final String address) async {
    return (await methodChannel.invokeMethod<bool>(
          'removeBondedDevice',
          <String, dynamic>{'address': address},
        )) ??
        false;
  }

  /// 设置配对请求处理器
  /// 用于处理不同类型的配对请求：
  /// * PIN码输入
  /// * 密钥确认
  /// * 简单同意配对
  /// 注意：某些配对方式可能需要系统权限，第三方应用可能无法使用
  @override
  void setPairingRequestHandler(
    final Future<dynamic> Function(BluetoothPairingRequest request)? handler,
  ) {
    if (handler == null) {
      _pairingRequestHandler = null;
      methodChannel.invokeMethod('pairingRequestHandlingDisable');
      return;
    }

    if (_pairingRequestHandler == null) {
      methodChannel.invokeMethod('pairingRequestHandlingEnable');
    }

    _pairingRequestHandler = handler;
  }

  /// 与指定设备配对
  /// [pin] 可选的PIN码
  /// [passkeyConfirm] 是否需要确认配对密钥
  /// 注意：自动确认配对可能需要系统权限
  @override
  Future<bool> bondDevice(
    final String address, {
    final String? pin,
    final bool? passkeyConfirm,
  }) async {
    if (pin != null || passkeyConfirm != null) {
      if (_pairingRequestHandler != null) {
        throw Exception('pairing request handler already registered');
      }

      setPairingRequestHandler((final BluetoothPairingRequest request) async {
        Future<void>.delayed(const Duration(seconds: 1), () {
          setPairingRequestHandler(null);
        });
        if (pin != null && request.variant == BluetoothPairingVariant.pin) {
          return pin;
        }

        if (passkeyConfirm != null &&
            (request.variant == BluetoothPairingVariant.consent ||
                request.variant ==
                    BluetoothPairingVariant.passkeyConfirmation)) {
          return passkeyConfirm;
        }

        // 其他配对方式，无法自动处理
        return null;
      });
    }

    return await methodChannel.invokeMethod(
          'bondDevice',
          <String, dynamic>{'address': address},
        ) ??
        false;
  }

  /// 连接到指定的蓝牙设备
  @override
  Future<String> connect(final String address) async {
    return await methodChannel.invokeMethod(
          'connect',
          <String, dynamic>{'address': address},
        ) ??
        -1;
  }

  // TODO(edufolly): Write

  /// 断开与指定设备的连接
  @override
  Future<void> disconnect(final String id) {
    return methodChannel.invokeMethod(
      'disconnect',
      <String, dynamic>{'id': id},
    );
  }
}
