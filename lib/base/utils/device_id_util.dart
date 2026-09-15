import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

@LazySingleton()
class DeviceIdUtil {
  final SharedPreferences _preferences;
  static const _deviceIdKey = 'device_unique_id';

  DeviceIdUtil(this._preferences);

  /// Get or generate a unique device ID
  Future<String> getDeviceId() async {
    // Check if we already have a device ID stored
    String? deviceId = _preferences.getString(_deviceIdKey);
    
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // Generate a new device ID
    deviceId = _generateDeviceId();
    await _preferences.setString(_deviceIdKey, deviceId);
    
    return deviceId;
  }

  /// Generate a unique device ID based on platform and UUID
  String _generateDeviceId() {
    final uuid = const Uuid().v4();
    final platform = Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown';
    return '${platform}_$uuid';
  }

  /// Clear the stored device ID (useful for testing)
  Future<bool> clearDeviceId() async {
    return await _preferences.remove(_deviceIdKey);
  }

  /// Get a display name for the device
  String getDeviceDisplayName() {
    if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    }
    return 'Unknown Device';
  }
}

