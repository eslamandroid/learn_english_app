import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learn_english_app/firebase_options.dart';

typedef RouteInvoker = Future<void> Function(String routeOrPath, Map<String, dynamic>? args);

class FirebaseService {
  static FirebaseAnalytics? _analytics;
  static NavigatorObserver? analyticsObserver;

  static Future<void> init({
    GlobalKey<NavigatorState>? navigatorKey,
    RouteInvoker? externalRouter,
    bool enableCrashlytics = true,
    bool enableAnalytics = true,
    bool collectInDebug = false,
  }) async {
    // 1) Prefer default app (same in bg handler)
    await Firebase.initializeApp(
      // name: Platform.isIOS ? "kashef" : null,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2) Crashlytics (unchanged) ...
    if (enableCrashlytics) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        kReleaseMode || collectInDebug,
      );

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // 3) Analytics (unchanged) ...
    if (enableAnalytics) {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(kReleaseMode || collectInDebug);
      analyticsObserver = FirebaseAnalyticsObserver(analytics: _analytics!);
    }
  }

  static Future<void> log(String message) async {
    FirebaseCrashlytics.instance.log(message);
  }

  static Future<void> recordNonFatal(
    dynamic exception,
    StackTrace stack, {
    String? reason,
    Map<String, Object?>? keys,
  }) async {
    if (keys != null && keys.isNotEmpty) {
      await _setKeys(keys);
    }
    await FirebaseCrashlytics.instance.recordError(exception, stack, fatal: false, reason: reason);
  }

  static Future<void> _setKeys(Map<String, Object?> keys) async {
    for (final entry in keys.entries) {
      final k = entry.key;
      final v = entry.value;
      if (v is int) {
        await FirebaseCrashlytics.instance.setCustomKey(k, v);
      } else if (v is double) {
        await FirebaseCrashlytics.instance.setCustomKey(k, v);
      } else if (v is bool) {
        await FirebaseCrashlytics.instance.setCustomKey(k, v);
      } else {
        await FirebaseCrashlytics.instance.setCustomKey(k, v?.toString() ?? '');
      }
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    if (_analytics == null) return;
    final n = _normalizeName(name, maxLen: 24);
    final v = value.toString().trim();
    if (n == null || v.isEmpty) return;
    await _analytics!.setUserProperty(name: n, value: v.substring(0, v.length.clamp(0, 36)));
  }

  static String? _normalizeName(String raw, {required int maxLen}) {
    if (raw.isEmpty) return null;
    final s = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    final trimmed = s.replaceAll(RegExp(r'^_+'), '').replaceAll(RegExp(r'_+$'), '');
    if (trimmed.isEmpty) return null;
    return trimmed.length > maxLen ? trimmed.substring(0, maxLen) : trimmed;
  }

  static NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      "default",
      "Kashef Saving offers",
      priority: Priority.max,
      importance: Importance.max,
    ),
  );
}
