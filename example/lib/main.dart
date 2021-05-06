import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_sdk/flutter_facebook_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deepLinkUrl = 'Unknown';
  FlutterFacebookSdk facebookDeepLinks;
  bool isAdvertisingTrackingEnabled = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String deepLinkUrl;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      facebookDeepLinks = FlutterFacebookSdk();
      facebookDeepLinks.onDeepLinkReceived.listen((event) {
        setState(() {
          _deepLinkUrl = event;
        });
      });
      deepLinkUrl = await facebookDeepLinks.getDeepLinkUrl;
      setState(() {
        _deepLinkUrl = deepLinkUrl;
      });
    } on PlatformException {}
    if (!mounted) return;
  }

  Future<void> logViewContent() async {
    await facebookDeepLinks.logViewedContent(
        contentType: "Product",
        contentData: "Nestle Milkpak",
        contentId: "NST135",
        currency: "PKR",
        price: 160);
  }

  Future<void> logAddToCart() async {
    await facebookDeepLinks.logAddToCart(
        contentType: "Product",
        contentData: "Nestle Milkpak",
        contentId: "NST135",
        currency: "PKR",
        price: 160);
  }

  Future<void> logAddToWishlist() async {
    await facebookDeepLinks.logAddToWishlist(
        contentType: "Product",
        contentData: "Nestle Milkpak",
        contentId: "NST135",
        currency: "PKR",
        price: 160);
  }

  Future<void> logPurchase() async {
    await facebookDeepLinks.logPurhcase(amount: 669, currency: "PKR", params: {
      'content-type': "product_group",
      'num-items': 56,
    });
  }

  Future<void> logCompleteRegistration() async {
    await facebookDeepLinks.logCompleteRegistration(
        registrationMethod: "Number");
  }

  Future<void> logActivateApp() async {
    await facebookDeepLinks.logActivateApp();
  }

  Future<void> logSearch() async {
    await facebookDeepLinks.logSearch(
        contentType: "Product",
        contentData: "Nestle Milkpak",
        contentId: "NST135",
        searchString: "Habeeb",
        success: false);
  }

  Future<void> logInitiateCheckout() async {
    await facebookDeepLinks.logInitiateCheckout(
      contentType: "Product",
      contentData: "Nestle Milkpak",
      contentId: "NST135",
      currency: "PKR",
      numItems: 12,
      paymentInfoAvailable: false,
      totalPrice: 560,
    );
  }

  Future<void> logEvent(
      {@required String eventName,
      double valueToSum,
      dynamic parameters}) async {
    await facebookDeepLinks.logEvent(
        eventName: eventName, parameters: parameters, valueToSum: valueToSum);
  }

  Future<void> setAdvertiserTracking() async {
    await facebookDeepLinks.setAdvertiserTracking(
        isEnabled: !isAdvertisingTrackingEnabled);
    setState(() {
      isAdvertisingTrackingEnabled = !isAdvertisingTrackingEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_deepLinkUrl\n'),
              FlatButton(
                  onPressed: () async => await logViewContent(),
                  child: Text("Trigger View Content")),
              FlatButton(
                  onPressed: () async => await logActivateApp(),
                  child: Text("Trigger Activate App")),
              FlatButton(
                  onPressed: () async => await logAddToCart(),
                  child: Text("Trigger Add to cart")),
              FlatButton(
                  onPressed: () async => await logAddToWishlist(),
                  child: Text("Trigger Add to Wishlist")),
              FlatButton(
                  onPressed: () async => await logCompleteRegistration(),
                  child: Text("Trigger Complete Registration")),
              FlatButton(
                  onPressed: () async => await logPurchase(),
                  child: Text("Trigger Purchase")),
              FlatButton(
                  onPressed: () async => await logSearch(),
                  child: Text("Trigger Search")),
              FlatButton(
                  onPressed: () async => await logInitiateCheckout(),
                  child: Text("Trigger Initiate Checkout")),
              FlatButton(
                  onPressed: () async => await logEvent(
                        eventName: "button_clicked",
                        parameters: {
                          'button_id': 'the_clickme_button',
                        },
                      ),
                  child: Text("Trigger Button Clicked")),
              FlatButton(
                  onPressed: () async => await logEvent(
                        eventName: "fb_mobile_add_payment_info",
                        valueToSum: 55,
                        parameters: {
                          'SUCCESS': "true",
                        },
                      ),
                  child: Text("Trigger Payment Info Click")),
              Platform.isIOS
                  ? FlatButton(
                      onPressed: () async => await setAdvertiserTracking(),
                      child: isAdvertisingTrackingEnabled
                          ? Text("Disable Advertiser Tracking")
                          : Text("Enable Advertiser Tracking"))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
