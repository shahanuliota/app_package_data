import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_package_data/app_package_data.dart';

void main() {
  const MethodChannel channel = MethodChannel('app_package_data');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AppPackageData.platformVersion, '42');
  });
}
