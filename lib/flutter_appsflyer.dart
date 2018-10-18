import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

typedef AfSuccessListener = void Function(Map<dynamic, dynamic> data);
typedef AfErrorListener = void Function(String errorMessage);

AfSuccessListener _onConversionDataReceived;
AfSuccessListener _onAppOpenAttribution;
AfErrorListener _onAppOpenAttributionFailure;
AfErrorListener _onConversionDataRequestFailure;

const MethodChannel _channel =
    const MethodChannel('com.sarpongkb/flutter_appsflyer');

Future<dynamic> _methodCallHandler(MethodCall call) {
  switch (call.method) {
    case "conversionDataReceived":
      if (_onConversionDataReceived != null) {
        _onConversionDataReceived(call.arguments);
      }
      break;
    case "appOpenAttribution":
      if (_onAppOpenAttribution != null) {
        _onAppOpenAttribution(call.arguments);
      }
      break;
    case "appOpenAttributionFailure":
      if (_onAppOpenAttributionFailure != null) {
        _onAppOpenAttributionFailure(call.arguments);
      }
      break;
    case "conversionDataRequestFailure":
      if (_onConversionDataRequestFailure != null) {
        _onConversionDataRequestFailure(call.arguments);
      }
      break;
    default:
      FlutterError("Method ${call.method} not implemented");
  }
  return null;
}

class FlutterAppsflyer {
  FlutterAppsflyer._();

  static AppsflyerInstance createInstance({
    @required String devKey,
    String appleAppId,
    String oneLinkId,
    bool isDebug = false,
    AfSuccessListener onConversionDataReceived,
    AfSuccessListener onAppOpenAttribution,
    AfErrorListener onAppOpenAttributionFailure,
    AfErrorListener onConversionDataRequestFailure,
  }) {
    assert(devKey != null);
    assert(appleAppId != null || !Platform.isIOS,
        "appleAppId is required for iOS apps");
    _channel.invokeMethod("initSdk", {
      "devKey": devKey,
      "appleAppId": appleAppId,
      "oneLinkId": oneLinkId,
      "isDebug": isDebug,
    });

    _onConversionDataReceived = onConversionDataReceived;
    _onAppOpenAttribution = onAppOpenAttribution;
    _onAppOpenAttributionFailure = onAppOpenAttributionFailure;
    _onConversionDataRequestFailure = onConversionDataRequestFailure;
    _channel.setMethodCallHandler(_methodCallHandler);

    return AppsflyerInstance();
  }
}

class AppsflyerInstance {
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

  Future<void> setCustomerUserId(String userId) async {
    return await _channel.invokeMethod("setCustomerUserId", userId);
  }

  Future<void> setUserEmails(List<String> emails) async {
    return await _channel.invokeMethod("setUserEmail", emails);
  }

  Future<void> setAdditionalData(Map<String, dynamic> data) async {
    return await _channel.invokeMethod("setAdditionalData", data);
  }

  Future<bool> isDeviceTrackingEnabled() async {
    return await _channel.invokeMethod("isDeviceTrackingEnabled");
  }

  Future<void> enableDeviceTracking() async {
    return await _channel.invokeMethod("setDeviceTrackingDisabled", false);
  }

  Future<void> disableDeviceTracking() async {
    return await _channel.invokeMethod("setDeviceTrackingDisabled", true);
  }

  Future<String> generateShareLink({
    @required String channel,
    String campaign,
    String playerId,
    List<String> keywords,
  }) async {
    assert(channel != null);
    assert(campaign != null);
    return await _channel.invokeMethod("generateShareLink", {
      "channel": channel,
      "campaign": campaign,
      "playerId": playerId,
      "keywords": keywords.join(","),
    });
  }
}
