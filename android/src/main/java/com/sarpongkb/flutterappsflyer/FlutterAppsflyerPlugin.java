package com.sarpongkb.flutterappsflyer;

import java.util.Map;
import java.util.HashMap;

import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.appsflyer.AppsFlyerLib;
import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerProperties;
import com.appsflyer.CreateOneLinkHttpTask;
import com.appsflyer.share.LinkGenerator;
import com.appsflyer.share.ShareInviteHelper;

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
    boolean isDebug = call.argument("isDebug");
    AppsFlyerLib.getInstance().setDebugLog(isDebug);
    AppsFlyerLib.getInstance().init(devKey, conversionDataListener, registrar.context());
    AppsFlyerLib.getInstance().trackAppLaunch(registrar.context(), devKey);
    // AppsFlyerLib.getInstance().startTracking(registrar.activity());
    result.success(DONE);
  }

  private void onTrackEvent(MethodCall call, Result result) {
    String eventName = call.argument("eventName");
    Map eventValues = call.argument("eventValues");
    AppsFlyerLib.getInstance().trackEvent(registrar.context(), eventName, eventValues);
    result.success(DONE);
  }

  private void onGetAppsflyerDeviceId(MethodCall call, Result result) {
    String deviceId = AppsFlyerLib.getInstance().getAppsFlyerUID(registrar.context());
    result.success(deviceId);
  }

  private void onGetSdkVersion(MethodCall call, Result result) {
    String sdkVersion = AppsFlyerLib.getInstance().getSdkVersion();
    result.success(sdkVersion);
  }

  private void isDeviceTrackingEnabled(MethodCall call, Result result) {
    boolean disabled = AppsFlyerLib.getInstance().isTrackingStopped();
    result.success(!disabled);
  }

  private void onSetDeviceTrackingDisabled(MethodCall call, Result result) {
    boolean disabled = call.arguments();
    AppsFlyerLib.getInstance().setDeviceTrackingDisabled(disabled);
    result.success(DONE);
  }

  private void onGenerateShareLink(MethodCall call, final Result result) {
    String campaign = call.argument("campaign");
    String channel = call.argument("channel");
    String playerId = call.argument("playerId");
    String keywords = call.argument("keywords");

    LinkGenerator generator = ShareInviteHelper.generateInviteUrl(registrar.context());
    generator.setCampaign(campaign);
    generator.setChannel(channel);
    generator.setReferrerCustomerId(playerId);
    generator.addParameter("af_keywords", keywords);

    generator.generateLink(registrar.context(), new CreateOneLinkHttpTask.ResponseListener() {
      @Override
      public void onResponse(String linkUrl) {
        result.success(linkUrl);
      }

      @Override
      public void onResponseError(String errorMessage) {
        result.error("ONE_LINK_ERROR", errorMessage, null);
      }
    });
  }

  private void onSetCustomerUserId(MethodCall call, Result result) {
    String id = call.arguments();
    AppsFlyerLib.getInstance().setCustomerUserId(id);
    result.success(DONE);
  }

  private void onSetUserEmails(MethodCall call, Result result) {
    String userEmails = call.arguments().toString(); // need to convert array/list to a string
    AppsFlyerLib.getInstance().setUserEmails(AppsFlyerProperties.EmailsCryptType.NONE, userEmails);
    result.success(DONE);
  }

  private void onSetAdditionalData(MethodCall call, Result result) {
    HashMap<String, Object> data = call.arguments();
    AppsFlyerLib.getInstance().setAdditionalData(data);
    result.success(DONE);
  }

  private AppsFlyerConversionListener conversionDataListener = new AppsFlyerConversionListener() {
    public void onInstallConversionDataLoaded(Map<String, String> conversionData) {
      Log.d("FlutterAppsflyer onInstallConversionDataLoaded", conversionData.toString());
      channel.invokeMethod("conversionDataReceived", conversionData);
    }

    public void onAppOpenAttribution(Map<String, String> attributionData) {
      Log.d("FlutterAppsflyer onAppOpenAttribution", attributionData.toString());
      channel.invokeMethod("appOpenAttribution", attributionData);
    }

    public void onInstallConversionFailure(String errorMessage) {
      Log.d("FlutterAppsflyer onInstallConversionFailure", errorMessage);
      channel.invokeMethod("conversionDataRequestFailure", errorMessage);
    }

    public void onAttributionFailure(String errorMessage) {
      Log.d("FlutterAppsflyer onAttributionFailure", errorMessage);
      channel.invokeMethod("appOpenAttributionFailure", errorMessage);
    }
  };
}
