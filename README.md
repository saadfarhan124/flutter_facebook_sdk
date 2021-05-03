# Facebook Sdk For Flutter

![GitHub code size](https://img.shields.io/github/languages/code-size/saadfarhan124/sadfarhan124-facebook_flutter_plugin)
![GitHub followers](https://img.shields.io/github/followers/saadfarhan124?style=social)
![GitHub contributors](https://img.shields.io/github/contributors/saadfarhan124/sadfarhan124-facebook_flutter_plugin)
[![Linkedin](https://i.stack.imgur.com/gVE0j.png) LinkedIn](https://www.linkedin.com/in/saadfarhan124/)
[![GitHub](https://i.stack.imgur.com/tskMh.png) GitHub](https://github.com/saadfarhan124/)

`facebook_sdk_flutter` allows you to fetch `deep links`, `deferred deep links` and `log facebook app events`.

This was created using the latest facebook SDK to include support for iOS 14. The plugin currently supports app events and deeps links for iOS and Android. 

## Prerequisites

First of all, if you don't have one already, you must first create an app at Facebook developers: https://developers.facebook.com/

Get your app id (referred to as [APP_ID] below)

# For IOS

* If your code does not have CFBundleURLTypes, add the following just before the final </dict> element:
```
 <key>CFBundleURLTypes</key>
    <array>
      <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>fb[APP_ID]</string>
      </array>
      </dict>
    </array>
    <key>FacebookAppID</key>
    <string>[APP_ID]</string>
    <key>FacebookDisplayName</key>
    <string>[DISPLAY_NAME]</string>
    <key>FacebookAutoLogAppEventsEnabled</key>
    <true/>
    <key>FacebookAdvertiserIDCollectionEnabled</key>
    <true/>
```

# For Android 

* Add the following to your strings.xml file 
```

<string name="facebook_app_id">[APP_ID]</string>
<string name="fb_login_protocol_scheme">fb[APP_ID]</string>

```

* Add the following meta tag to the application element in AndroidManifest.xml
```

<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>

```

* Add the following element in AndroidManifest.xml
```

<uses-permission android:name="android.permission.INTERNET"/>

```

* Don't forget to replace [APP_ID] with your Application ID

