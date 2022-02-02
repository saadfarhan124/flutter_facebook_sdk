## 0.0.1

- Initial version. Only iOS Support.

## 0.0.2

- Added support for android.

## 0.0.3

- Added initiate checkout facebook event

## 0.0.4

- Updated FBSDKCoreKit version from '8.0.0' to '9.1.0'
- Updated deployment platform from '8.0' to '9.0'
- Added a generic function to log facebook events

## 0.0.5

- Fixed plugin crash on app resume android.

## 1.0.0

- Migrate to null safety.

## 1.1.0

- Update FBSDKCoreKit version to 12.3.1.
- Fix deprecated function.
    - AppEvents => AppEvents.shared
    - parameters of AppEvents.shared.logEvent => Dictionary<AppEvents.ParameterName, Any>
    - Settings.setAdvertiserTrackingEnabled(enabled) => Settings.shared.isAdvertiserTrackingEnabled = enabled