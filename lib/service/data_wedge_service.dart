import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

class DataWedgeService {
  // Singleton
  static final DataWedgeService _instance = DataWedgeService._internal();

  factory DataWedgeService() => _instance;

  DataWedgeService._internal() {
    _dataWedge = FlutterDataWedge();
  }

  FlutterDataWedge? _dataWedge;
  bool _initialized = false;

  StreamSubscription? _scanSub;
  StreamSubscription? _statusSub;

  /// ✅ Call once (e.g. in main or first scanner screen)
  Future<void> init() async {
    if (!Platform.isAndroid) return;
    if (_initialized) return;
    _dataWedge ??= FlutterDataWedge();

    await _dataWedge!.initialize();

    final result = await _dataWedge!.requestProfiles();
    if (result.isFailure) {
      debugPrint('requestProfiles failed: ${result.maybeError}');
    } else {
      await _ensureProfileExists();
    }

    // Enable scanner plugin initially
    final enableResult = await _dataWedge!.enableScanner(true);
    if (enableResult.isFailure) {
      debugPrint('enableScanner(true) failed: ${enableResult.maybeError}');
    }

    _listenScannerStatus();
    _initialized = true;
  }

  Future<void> _ensureProfileExists() async {
    try {
      final profiles = await _dataWedge!.waitForProfiles();
      debugPrint('Existing DataWedge profiles: $profiles');

      if (!profiles.contains('WhsAutoProfile')) {
        debugPrint('Profile WhsAutoProfile not found, creating...');
        await _dataWedge!.createDefaultProfile(profileName: 'WhsAutoProfile');
      } else {
        debugPrint('Profile WhsAutoProfile already exists, skipping creation.');
      }
    } catch (e) {
      debugPrint('Error while waiting for profiles: $e');
      await _dataWedge!.createDefaultProfile(profileName: 'WhsAutoProfile');
    }
  }

  void _listenScannerStatus() {
    _statusSub ??= _dataWedge?.onScannerStatus.listen((status) {
      // status has fields like: status.status, status.profileName, etc.
      debugPrint('Scanner status: $status');
    });
  }

  /// 🎯 Subscribe once per screen (don’t create multiple listeners)
  void startListening({required void Function(String code) onScan}) {
    if (!Platform.isAndroid) return;
    if (_scanSub != null) return; // already listening

    _scanSub = _dataWedge?.onScanResult.listen((scan) {
      final code = scan.data.trim();
      if (code.isEmpty) return;
      onScan(code);
    });
  }

  /// Stop receiving scan events (e.g. when leaving the screen)
  void stopListening() {
    if (!Platform.isAndroid) return;
    _scanSub?.cancel();
    _scanSub = null;
  }

  /// ⏸ Pause scanning quickly (uses activateScanner → fallback enableScanner)
  Future<void> pauseScanning() async {
    await _setActive(false);
  }

  /// ▶️ Resume scanning quickly (uses activateScanner → fallback enableScanner)
  Future<void> resumeScanning() async {
    await _setActive(true);
  }

  Future<void> _setActive(bool active) async {
    if (_dataWedge == null) return;

    // Try the fast way first: activateScanner (resume/suspend)
    final fastResult = await _dataWedge!.activateScanner(active);
    if (fastResult.isFailure) {
      debugPrint(
        'activateScanner($active) failed: ${fastResult.maybeError}, '
        'falling back to enableScanner($active)',
      );

      // Fallback to the "slower" but more general method
      final fallbackResult = await _dataWedge!.enableScanner(active);
      if (fallbackResult.isFailure) {
        debugPrint(
          'enableScanner($active) also failed: ${fallbackResult.maybeError}',
        );
      }
    }
  }

  /// Optional: if you ever want to fully dispose (usually not needed)
  Future<void> dispose() async {
    await _scanSub?.cancel();
    await _statusSub?.cancel();
    _scanSub = null;
    _statusSub = null;
    _initialized = false;
  }
}
