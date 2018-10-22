#import "FlutterAppsflyerPlugin.h"

@implementation FlutterAppsflyerPlugin

NSString* DONE = @"DONE";

static FlutterMethodChannel* afChannel;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  afChannel = [FlutterMethodChannel
               methodChannelWithName:@"com.sarpongkb/flutter_appsflyer"
               binaryMessenger:[registrar messenger]];
  FlutterAppsflyerPlugin* instance = [[FlutterAppsflyerPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
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
  } else if ([@"generateShareLink" isEqualToString:call.method]) {
    [self onGenerateShareLink:call result:result];
  } else if ([@"setCustomerUserId" isEqualToString:call.method]) {
    [self onSetCustomerUserId:call result:result];
  } else if ([@"setUserEmails" isEqualToString:call.method]) {
    [self onSetUserEmails:call result:result];
  } else if ([@"setAdditionalData" isEqualToString:call.method]) {
    [self onSetAdditionalData:call result:result];
  } else if ([@"isDeviceTrackingEnabled" isEqualToString:call.method]) {
    [self isDeviceTrackingEnabled:call result:result];
  } else if ([@"setDeviceTrackingDisabled" isEqualToString:call.method]) {
    [self onSetDeviceTrackingDisabled:call result:result];
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


- (void) isDeviceTrackingEnabled:(FlutterMethodCall*)call result:(FlutterResult)result {
  BOOL enabled = ![AppsFlyerTracker sharedTracker].deviceTrackingDisabled;
  result([NSNumber numberWithBool:enabled]);
}


- (void) onSetDeviceTrackingDisabled:(FlutterMethodCall*)call result:(FlutterResult)result {
  BOOL disabled = call.arguments;
  NSLog(@"Requesting Appsflyer deviceTrackingDisabled: %i", disabled);
  NSLog(@"Before: Appsflyer deviceTrackingDisabled: %i", [AppsFlyerTracker sharedTracker].deviceTrackingDisabled);
  [AppsFlyerTracker sharedTracker].deviceTrackingDisabled = disabled;
  NSLog(@"After: Appsflyer deviceTrackingDisabled: %i", [AppsFlyerTracker sharedTracker].deviceTrackingDisabled);
  result(DONE);
}

- (void) onGenerateShareLink:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* campaign = call.arguments[@"campaign"];
  NSString* channel = call.arguments[@"channel"];
  NSString* playerId = call.arguments[@"playerId"];
  NSString* keywords = call.arguments[@"keywords"];

  [AppsFlyerShareInviteHelper generateInviteUrlWithLinkGenerator:^AppsFlyerLinkGenerator * _Nonnull(AppsFlyerLinkGenerator * _Nonnull generator) {
    [generator setCampaign:campaign];
    [generator setChannel:channel];
    [generator setReferrerCustomerId:playerId];
    [generator addParameterValue:keywords forKey:@"af_keywords"];
    return generator;
  } completionHandler:^(NSURL * _Nullable url) {
    result([url absoluteString]);
  }];
}


- (void) onSetCustomerUserId:(FlutterMethodCall*)call result:(FlutterResult)result {
  [[AppsFlyerTracker sharedTracker] setCustomerUserID:call.arguments];
  result(DONE);
}


- (void) onSetUserEmails:(FlutterMethodCall*)call result:(FlutterResult)result {
  [[AppsFlyerTracker sharedTracker] setUserEmails:call.arguments withCryptType:EmailCryptTypeNone];
  result(DONE);
}


- (void) onSetAdditionalData:(FlutterMethodCall*)call result:(FlutterResult)result {
  [[AppsFlyerTracker sharedTracker] setAdditionalData:call.arguments];
  result(DONE);
}


- (void) onConversionDataReceived:(NSDictionary *)installData {
  NSLog(@"FlutterAppsflyer onConversionDataReceived %@", installData);
  [afChannel invokeMethod:@"conversionDataReceived" arguments:installData];
}

- (void) onAppOpenAttribution:(NSDictionary *)attributionData {
  NSLog(@"FlutterAppsflyer onAppOpenAttribution %@", attributionData);
  [afChannel invokeMethod:@"appOpenAttribution" arguments:attributionData];
}

- (void)onAppOpenAttributionFailure:(NSError *)error {
  NSLog(@"FlutterAppsflyer onAppOpenAttributionFailure %li: %@", error.code, error.localizedDescription);
  [afChannel invokeMethod:@"appOpenAttributionFailure" arguments:error.localizedDescription];
}

- (void)onConversionDataRequestFailure:(NSError *)error {
  NSLog(@"FlutterAppsflyer onConversionDataRequestFailure %li: %@", error.code, error.localizedDescription);
  [afChannel invokeMethod:@"conversionDataRequestFailure" arguments:error.localizedDescription];
}


// Reports app open from deep link for iOS 10
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *) options {
  [[AppsFlyerTracker sharedTracker] handleOpenUrl:url options:options];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [[AppsFlyerTracker sharedTracker] trackAppLaunch];
}


// Reports app open from a Universal Link for iOS 9 or above
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler
{
  [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
  return YES;
}


@end
