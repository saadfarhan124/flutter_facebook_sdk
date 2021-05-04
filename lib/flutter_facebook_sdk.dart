import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A singleton class for plugin
/// so that multiple streams dont open up

class FlutterFacebookSdk {
  factory FlutterFacebookSdk() {
    if (_singleton == null) {
      _singleton = FlutterFacebookSdk._();
    }
    return _singleton;
  }

  FlutterFacebookSdk._();

  static FlutterFacebookSdk _singleton;

  /// Method Channel Initilization to register method calls
  static const MethodChannel _channel =
      const MethodChannel('flutter_facebook_sdk/methodChannel');

  /// Event Channel to listen to event changes
  static const EventChannel _eventChannel =
      const EventChannel("flutter_facebook_sdk/eventChannel");

  Stream<String> _onDeepLinkReceived;

  /// Returns a stream listener to handle deep link url changes
  /// Add a listener to this event to get updated deep link url
  /// ``` dart
  /// facebookDeepLinks = FlutterFacebookSdk();
  /// facebookDeepLinks.onDeepLinkReceived.listen((event) {
  /// setState(() {
  /// _deepLinkUrl = event;
  /// });
  /// });
  /// ```
  Stream<String> get onDeepLinkReceived {
    if (_onDeepLinkReceived == null) {
      _onDeepLinkReceived =
          _eventChannel.receiveBroadcastStream().cast<String>();
    }
    return _onDeepLinkReceived;
  }

  /// Returns the platform version of the running device
  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Returns deep link url
  Future<String> get getDeepLinkUrl async {
    final String url = await _channel.invokeMethod('getDeepLinkUrl');
    return url;
  }

  /// Logs App Activate Event of FBSDK
  Future<bool> logActivateApp() async {
    await _channel.invokeMethod("activateApp");
    return true;
  }

  /// Logs View Content Event of FBSDK with [currency] and [price]
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

  /// Logs Add to Cart Event of FBSDK with [currency] and [price]
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

  /// Logs Add to Wishlist Event of FBSDK with [currency] and [price]
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

  /// Logs Complete Registration Event of FBSDK with [registrationMethod]
  Future<bool> logCompleteRegistration(
      {@required String registrationMethod}) async {
    final bool result = await _channel.invokeMethod("logCompleteRegistration", {
      "registrationMethod": registrationMethod,
    });
    return result;
  }

  /// Logs Purchase Event of FBSDK with [currency] and [amount]
  Future<bool> logPurhcase(
      {@required double amount,
      @required String currency,
      @required Map<String, Object> params}) async {
    final bool result = await _channel.invokeMethod("logPurchase",
        {"amount": amount, "currency": currency, "parameters": params});
    return result;
  }

  /// Logs Search Event of FBSDK with [searchString] and [success]
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

  /// Logs Initiate Checkout Event of FBSDK with [numItems] and [paymentInfoAvailable]
  Future<bool> logInitiateCheckout(
      {@required String contentType,
      @required String contentData,
      @required String contentId,
      @required int numItems,
      @required bool paymentInfoAvailable,
      @required String currency,
      @required double totalPrice}) async {
    final bool result = await _channel.invokeMethod("logInitiateCheckout", {
      "contentType": contentType,
      "contentData": contentData,
      "contentId": contentId,
      "numItems": numItems,
      "paymentInfoAvailable": paymentInfoAvailable,
      "currency": currency,
      "totalPrice": totalPrice
    });
    return result;
  }

  /// Only Available in iOS
  /// Set the advertiser tracking to truue or false
  /// App events won't work if this is disabled
  Future<bool> setAdvertiserTracking({@required bool isEnabled}) async {
    final bool result = await _channel
        .invokeMethod("setAdvertiserTracking", {"enabled": isEnabled});
    return result;
  }
}
