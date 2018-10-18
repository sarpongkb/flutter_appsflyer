import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

typedef AfSuccessListener = void Function(Map<dynamic, dynamic> data);
typedef AfErrorListener = void Function(String errorMessage);

class FlutterAppsflyer {
  static const MethodChannel _channel =
      const MethodChannel('com.sarpongkb/flutter_appsflyer');

  final AfSuccessListener onConversionDataReceived;
  final AfSuccessListener onAppOpenAttribution;
  final AfErrorListener onAppOpenAttributionFailure;
  final AfErrorListener onConversionDataRequestFailure;

  FlutterAppsflyer({
    this.onConversionDataReceived,
    this.onAppOpenAttribution,
    this.onAppOpenAttributionFailure,
    this.onConversionDataRequestFailure,
  }) {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> initSdk({
    @required String devKey,
    String appleAppId,
    String oneLinkId,
    bool isDebug = false,
  }) {
    assert(devKey != null);
    assert(appleAppId != null || !Platform.isIOS,
        "appleAppId is required for iOS apps");
    return _channel.invokeMethod("initSdk", {
      "devKey": devKey,
      "appleAppId": appleAppId,
      "oneLinkId": oneLinkId,
      "isDebug": isDebug,
    });
  }

  Future<String> getSdkVersion() async {
    String sdkVersion = await _channel.invokeMethod("getSdkVersion");
    return sdkVersion;
  }

  Future<String> getAppsflyerDeviceId() async {
    String deviceId = await _channel.invokeMethod("getAppsflyerDeviceId");
    return deviceId;
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

  Future<void> _methodCallHandler(MethodCall call) {
    switch (call.method) {
      case "conversionDataReceived":
        if (onConversionDataReceived != null) {
          onConversionDataReceived(call.arguments);
        }
        break;
      case "appOpenAttribution":
        if (onAppOpenAttribution != null) {
          onAppOpenAttribution(call.arguments);
        }
        break;
      case "appOpenAttributionFailure":
        if (onAppOpenAttributionFailure != null) {
          onAppOpenAttributionFailure(call.arguments);
        }
        break;
      case "conversionDataRequestFailure":
        if (onConversionDataRequestFailure != null) {
          onConversionDataRequestFailure(call.arguments);
        }
        break;
      default:
        FlutterError("Method ${call.method} not implemented");
    }
    return null;
  }
}
