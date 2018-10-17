#import "FlutterAppsflyerPlugin.h"

@implementation FlutterAppsflyerPlugin

NSString* DONE = @"DONE";

static FlutterMethodChannel* afChannel;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  afChannel = [FlutterMethodChannel
               methodChannelWithName:@"com.sarpongkb/flutter_appsflyer"
               binaryMessenger:[registrar messenger]];
  FlutterAppsflyerPlugin* instance = [[FlutterAppsflyerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:afChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initSdk" isEqualToString:call.method]) {
    [self onInitSdk:call result:result];
  } else if ([@"trackEvent" isEqualToString:call.method]) {
    [self onTrackEvent:call result:result];
  } else if ([@"getAppsflyerDeviceId" isEqualToString:call.method]) {
    [self onGetAppsflyerDeviceId:call result:result];
  } else if ([@"getSdkVersion" isEqualToString:call.method]) {
    [self onGetSdkVersion:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}


- (void) onInitSdk:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* devKey = call.arguments[@"devKey"];
  NSString* appleAppId = call.arguments[@"appleAppId"];
  [AppsFlyerTracker sharedTracker].appsFlyerDevKey = devKey;
  [AppsFlyerTracker sharedTracker].appleAppID = appleAppId;
  [AppsFlyerTracker sharedTracker].delegate = self;
  [AppsFlyerTracker sharedTracker].isDebug = true;
  result(DONE);
}


- (void) onTrackEvent:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* eventName = call.arguments[@"eventName"];
  NSDictionary* eventValues = call.arguments[@"eventValues"];
  [[AppsFlyerTracker sharedTracker] trackEvent:eventName withValues:eventValues];
  result(DONE);
}


- (void) onGetAppsflyerDeviceId:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* deviceId = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
  result(deviceId);
}


- (void) onGetSdkVersion:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* sdkVersion = [[AppsFlyerTracker sharedTracker] getSDKVersion];
  result(sdkVersion);
}


- (void) onConversionDataReceived:(NSDictionary *)installData {
  [afChannel invokeMethod:@"conversionDataReceived" arguments:installData];
}

@end
