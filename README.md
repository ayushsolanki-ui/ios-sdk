# Synchronoss IOS In App Purchase SDK

In App Purchase custom implementation using Storekit 2 for iOS 15+

## 🛠 Technologies

- **SwiftUI**: The declarative UI framework from Apple.

## 🚀 Getting Started

### Prerequisites
- AppStore Connect access for creating Bundle Identifier and App
- **Xcode 13** and later
- iOS  15 or later
- Please make sure that the project bundle ID is the same as the bundle identifier you added while creating the app in AppStore connect.

### Installation
1. In your Xcode project go to File -> Add Package Dependencies then search for this repo and add -

```bash
https://git.geekyants.com/client-projects/synchronous/ios-sdk
```

2. Import the package

```swift
import SynchronossIosIapSdk

```

3. Add the store view anywhere you want

```swift
struct AppView: View {
    let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    var body: some View {
        RootPaymentView(userId: "monisankar@geekyants.com", apiKey: apiKey)
    }
}
```

4. Now the products must be visible if you have them in **Ready for Submit** state in AppStore connect.