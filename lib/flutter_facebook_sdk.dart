import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterFacebookSdk {
  factory FlutterFacebookSdk() {
    if (_singleton == null) {
      _singleton = FlutterFacebookSdk._();
    }
    return _singleton;
  }

  FlutterFacebookSdk._();

  static FlutterFacebookSdk _singleton;

  static const MethodChannel _channel =
      const MethodChannel('flutter_facebook_sdk/methodChannel');
  static const EventChannel _eventChannel =
      const EventChannel("flutter_facebook_sdk/eventChannel");

  Stream<String> _onDeepLinkReceived;

  Stream<String> get onDeepLinkReceived {
    if (_onDeepLinkReceived == null) {
      _onDeepLinkReceived =
          _eventChannel.receiveBroadcastStream().cast<String>();
    }
    return _onDeepLinkReceived;
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> get getDeepLinkUrl async {
    final String url = await _channel.invokeMethod('getDeepLinkUrl');
    return url;
  }

  Future<bool> logActivateApp() async {
    await _channel.invokeMethod("activateApp");
    return true;
  }

  Future<bool> logViewedContent(
      {@required String contentType,
      @required String contentData,
      @required String contentId,
      @required String currency,
      @required double price}) async {
    final bool result = await _channel.invokeMethod("logViewedContent", {
      "contentType": contentType,
      "contentData": contentData,
      "contentId": contentId,
      "currency": currency,
      "price": price
    });
    return result;
  }

  Future<bool> logAddToCart(
      {@required String contentType,
      @required String contentData,
      @required String contentId,
      @required String currency,
      @required double price}) async {
    final bool result = await _channel.invokeMethod("logAddToCart", {
      "contentType": contentType,
      "contentData": contentData,
      "contentId": contentId,
      "currency": currency,
      "price": price
    });
    return result;
  }

  Future<bool> logAddToWishlist(
      {@required String contentType,
      @required String contentData,
      @required String contentId,
      @required String currency,
      @required double price}) async {
    final bool result = await _channel.invokeMethod("logAddToWishlist", {
      "contentType": contentType,
      "contentData": contentData,
      "contentId": contentId,
      "currency": currency,
      "price": price
    });
    return result;
  }

  Future<bool> logCompleteRegistration({@required String registrationMethod})async{
    final bool result = await _channel.invokeMethod("logCompleteRegistration", {
      "registrationMethod": registrationMethod,
    
    });
    return result;
  }

  Future<bool> logPurhcase({@required double amount, @required String currency, @required Map<String, Object> params})async{
    final bool result = await _channel.invokeMethod("logPurchase", {
      "amount": amount,
      "currency": currency,
      "parameters" : params
    });
    return result;
  }

  Future<bool> logSearch(
      {@required String contentType,
      @required String contentData,
      @required String contentId,
      @required String searchString,
      @required bool success}) async {
    final bool result = await _channel.invokeMethod("logSearch", {
      "contentType": contentType,
      "contentData": contentData,
      "contentId": contentId,
      "searchString": searchString,
      "success": success
    });
    return result;
  }

  Future<bool> setAdvertiserTracking({@required bool isEnabled}) async{
    final bool result = await _channel.invokeMethod("setAdvertiserTracking", {
      "enabled" : isEnabled
    });
    return result;
  }

  
}
