import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAppsflyer {
  static const MethodChannel _channel =
      const MethodChannel('com.sarpongkb/flutter_appsflyer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
