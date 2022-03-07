import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class AppPackageData {
  static const MethodChannel _channel = MethodChannel('app_package_data');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<PlatformData> get getAll async {
    final version = await _channel.invokeMethod('getAll');
    Map<String, dynamic> mp = json.decode(version);
    return PlatformData.fromJson(mp);
  }
}

class PlatformData {
  PlatformData({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
  });

  factory PlatformData.fromJson(Map<String, dynamic> mp) => PlatformData(
        buildNumber: mp['appName'] ?? '',
        buildSignature: BuildSignature.fromJson(mp['buildSignature'] ?? {}),
        appName: mp['packageName'] ?? '',
        packageName: mp['packageName'] ?? '',
        version: mp['packageName'] ?? '',
      );

  /// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
  final String appName;

  /// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
  final String packageName;

  /// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
  final String version;

  /// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
  final String buildNumber;

  /// The build signature. Empty string on iOS, signing key signature (hex) on Android.
  final BuildSignature buildSignature;
}

class BuildSignature {
  String sha1;
  String sha256;
  String md5;

  BuildSignature({
    required this.md5,
    required this.sha1,
    required this.sha256,
  });

  factory BuildSignature.fromJson(Map<String, dynamic> m) => BuildSignature(
        md5: m['MD5'] ?? '',
        sha256: m['SHA256'] ?? '',
        sha1: m['SHA1'] ?? '',
      );
}
