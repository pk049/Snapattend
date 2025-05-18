// lib/utils/device_utils.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceUtils {
  static Future<bool> isRunningOnEmulator() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    }
    return false;
  }

  static Future<String> getBaseUrl() async {
    final isEmulator = await isRunningOnEmulator();
    return isEmulator
        ? 'http://10.0.2.2:5000'
        : 'http://192.168.29.102:5000';
  }
}

