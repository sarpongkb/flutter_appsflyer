import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class FlutterAppsflyer {
  static const MethodChannel _channel =
      const MethodChannel('com.sarpongkb/flutter_appsflyer');

  final AfInstallConversionListener installConversionListener;

  FlutterAppsflyer({@required this.installConversionListener})
      : assert(installConversionListener != null) {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> initIOS(
      {@required String devKey,
      @required String appleAppId,
      bool isDebug = false}) {
    assert(devKey != null);
    assert(appleAppId != null);
    return _channel.invokeMethod("initSdk", {
      "devKey": devKey,
      "appleAppId": appleAppId,
      "isDebug": isDebug,
    });
  }

  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic> eventValues = const {},
  }) async {
    return await _channel.invokeMethod("trackEvent", {
      "eventName": eventName,
      "eventValues": eventValues,
    });
  }

  Future<String> getAppsflyerDeviceId() async {
    dynamic deviceId = await _channel.invokeMethod("getAppsflyerDeviceId");
    return deviceId.toString();
  }

  Future<String> getSdkVersion() async {
    dynamic sdkVersion = await _channel.invokeMethod("getSdkVersion");
    return sdkVersion.toString();
  }

  Future<void> _methodCallHandler(MethodCall call) {
    if ("conversionDataReceived" == call.method) {
      if (installConversionListener != null) {
        installConversionListener(call.arguments);
      }
    } else {
      FlutterError("Method ${call.method} not implemented");
    }
    return null;
  }
}

typedef AfInstallConversionListener = void Function(
  Map<dynamic, dynamic> installData,
);
