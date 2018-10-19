package com.sarpongkb.flutterappsflyer;

import java.util.Map;
// import android.app.application;
// import java.io;

import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.appsflyer.AppsFlyerLib;
import com.appsflyer.AppsFlyerConversionListener;

/** FlutterAppsflyerPlugin */
public class FlutterAppsflyerPlugin implements MethodCallHandler {
  private static final String DONE = "DONE";
  private static MethodChannel channel;
  private static Registrar registrar;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    FlutterAppsflyerPlugin.registrar = registrar;
    channel = new MethodChannel(registrar.messenger(), "com.sarpongkb/flutter_appsflyer");
    channel.setMethodCallHandler(new FlutterAppsflyerPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("initSdk")) {
      onInitSdk(call, result);
    } else if (call.method.equals("trackEvent")) {
      onTrackEvent(call, result);
    } else if (call.method.equals("getAppsflyerDeviceId")) {
      onGetAppsflyerDeviceId(call, result);
    } else if (call.method.equals("getSdkVersion")) {
      onGetSdkVersion(call, result);
    } else if (call.method.equals("generateShareLink")) {
      onGenerateShareLink(call, result);
    } else if (call.method.equals("setCustomerUserId")) {
      onSetCustomerUserId(call, result);
    } else if (call.method.equals("setUserEmails")) {
      onSetUserEmails(call, result);
    } else if (call.method.equals("setAdditionalData")) {
      onSetAdditionalData(call, result);
    } else if (call.method.equals("isDeviceTrackingEnabled")) {
      isDeviceTrackingEnabled(call, result);
    } else if (call.method.equals("setDeviceTrackingDisabled")) {
      onSetDeviceTrackingDisabled(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void onInitSdk(MethodCall call, Result result) {
    String devKey = call.argument("devKey");
    String appleAppId = call.argument("appleAppId");
    AppsFlyerLib.getInstance().init(devKey, conversionDataListener, registrar.context());
    // AppsFlyerLib.getInstance().startTracking(registrar.context());
    result.success(DONE);
  }

  private void onTrackEvent(MethodCall call, Result result) {
    // String eventName = call.arguments["eventName"];
    // Map eventValues = call.arguments["eventValues"];
    // [[AppsFlyerTracker sharedTracker] trackEvent:eventName
    // withValues:eventValues];
    result.success(DONE);
  }

  private void onGetAppsflyerDeviceId(MethodCall call, Result result) {
    String deviceId = "not implemented"; // AppsFlyerLib.getInstance().getAppsFlyerUID(registrar.context());
    result.success(deviceId);
  }

  private void onGetSdkVersion(MethodCall call, Result result) {
    String sdkVersion = AppsFlyerLib.getInstance().getSdkVersion();
    result.success(sdkVersion);
  }

  private void isDeviceTrackingEnabled(MethodCall call, Result result) {
    // BOOL enabled = ![AppsFlyerTracker sharedTracker].deviceTrackingDisabled;
    result.success(true);
  }

  private void onSetDeviceTrackingDisabled(MethodCall call, Result result) {
    // BOOL disabled = call.arguments;
    // NSLog(@"Requesting Appsflyer deviceTrackingDisabled: %i", disabled);
    // NSLog(@"Before: Appsflyer deviceTrackingDisabled: %i", [AppsFlyerTracker
    // sharedTracker].deviceTrackingDisabled);
    // [AppsFlyerTracker sharedTracker].deviceTrackingDisabled = disabled;
    // NSLog(@"After: Appsflyer deviceTrackingDisabled: %i", [AppsFlyerTracker
    // sharedTracker].deviceTrackingDisabled);
    result.success(DONE);
  }

  private void onGenerateShareLink(MethodCall call, Result result) {
    // String campaign = call.arguments["campaign"];
    // String channel = call.arguments["channel"];
    // String playerId = call.arguments["playerId"];
    // String keywords = call.arguments["keywords"];

    // [AppsFlyerShareInviteHelper
    // generateInviteUrlWithLinkGenerator:^AppsFlyerLinkGenerator *
    // _Nonnull(AppsFlyerLinkGenerator * _Nonnull generator) {
    // [generator setCampaign:campaign];
    // [generator setChannel:channel];
    // [generator setReferrerCustomerId:playerId];
    // [generator addParameterValue:keywords forKey:@"af_keywords"];
    // return generator;
    // } completionHandler:^(NSURL * _Nullable url) {
    // result([url absoluteString]);
    // }];
    result.success(DONE);
  }

  private void onSetCustomerUserId(MethodCall call, Result result) {
    // [[AppsFlyerTracker sharedTracker] setCustomerUserID:call.arguments];
    result.success(DONE);
  }

  private void onSetUserEmails(MethodCall call, Result result) {
    // [[AppsFlyerTracker sharedTracker] setUserEmails:call.arguments
    // withCryptType:EmailCryptTypeNone];
    result.success(DONE);
  }

  private void onSetAdditionalData(MethodCall call, Result result) {
    // [[AppsFlyerTracker sharedTracker] setAdditionalData:call.arguments];
    result.success(DONE);
  }

  private AppsFlyerConversionListener conversionDataListener = new AppsFlyerConversionListener() {
    public void onInstallConversionDataLoaded(Map<String, String> conversionData) {
      Log.d("FlutterAppsflyer onInstallConversionDataLoaded", conversionData.toString());
      // [afChannel invokeMethod:@"conversionDataReceived" arguments:installData];
    }

    public void onAppOpenAttribution(Map<String, String> attributionData) {
      Log.d("FlutterAppsflyer onAppOpenAttribution", attributionData.toString());
      // [afChannel invokeMethod:@"appOpenAttribution" arguments:attributionData];
    }

    public void onInstallConversionFailure(String errorMessage) {
      Log.d("FlutterAppsflyer onInstallConversionFailure", errorMessage);
      // [afChannel invokeMethod:@"appOpenAttributionFailure"
      // arguments:error.localizedDescription];
    }

    public void onAttributionFailure(String errorMessage) {
      Log.d("FlutterAppsflyer onAttributionFailure", errorMessage);
      // [afChannel invokeMethod:@"conversionDataRequestFailure"
      // arguments:error.localizedDescription];
    }
  };
}
