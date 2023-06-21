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

## 1.2.0

- Update FBSDKCoreKit version to 14.1.0.
- Add general App Events Log
  - EVENT_NAME_RATED
  - EVENT_NAME_DONATE
  - EVENT_NAME_CONTACT
  - EVENT_NAME_START_TRIAL
  - EVENT_NAME_SPENT_CREDITS
  - EVENT_NAME_SUBSCRIBE
  - EVENT_NAME_PURCHASED
  - EVENT_NAME_CUSTOMIZE_PRODUCT
  - EVENT_NAME_ACHIEVED_LEVEL
  - EVENT_NAME_FIND_LOCATION
  - EVENT_NAME_ADDED_TO_CART
  - EVENT_NAME_VIEWED_CONTENT
  - EVENT_NAME_SCHEDULE
  - EVENT_NAME_SUBMIT_APPLICATION