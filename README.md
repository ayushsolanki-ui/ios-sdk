# Synchronoss iOS In-App Purchase SDK

A custom implementation of In-App Purchases using StoreKit 2 for iOS 15 and later.

## 🛠 Technologies

- **SwiftUI**: Apple's declarative UI framework.
- **StoreKit 2**: A Swift-based API for adding in-app purchases and subscriptions to Apple platform apps.
- **XCTest**: A framework for writing unit tests for iOS apps and Xcode projects.

## 🚀 Getting Started

### Prerequisites

- Access to App Store Connect for creating Bundle Identifiers and Apps.
- **Xcode 13** or later.
- **iOS 15** or later.
- Ensure the project bundle ID matches the bundle identifier created in App Store Connect.

### 1. Installation

 - **Add Package Dependency**

   In your Xcode project, navigate to `File` → `Add Package Dependencies`, then search for this repository and add it:

   ```bash
   https://git.geekyants.com/client-projects/synchronous/ios-sdk
    ```
### 2. Setup Configuration

- **Open the Project in Xcode**

  Open your project in Xcode, select the project folder, and press `Cmd + N`.
  
  ![Configuration Step 1](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737350042/config1_hjl9eq.png)

- **Search for Config**

  Search for `Config` and click `Next`.
  
  ![Configuration Step 2](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737350042/config2_pdnnrb.png)

- **Select Target and Create**

  Select the target and click `Create`.
  
  ![Configuration Step 3](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737350043/config3_vrqrkt.png)

- **Add App API Key**

  Add your App API key in the `Config` file as `API_KEY = <YOUR_API_KEY>` and ensure this file is included in `.gitignore`. For sandbox testing and release builds, add the `API_KEY` to the Xcloud Cloud environment variables in App Store Connect or your CI/CD pipeline.
  
  ![Configuration Step 4](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737351715/config4.png)

- **Add API Key to App Targets**

  In your App Targets, under the `Info` tab, add the `API_KEY` with type `String` and value `$(API_KEY)`.
  
  ![Configuration Step 5](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737350042/config5_s7gxmf.png)

- **Add In-App Purchase Capability**

  In the `Signing & Capabilities` tab, add the **In-App Purchase** capability.
  
  ![Configuration Step 6](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737350042/config7_zp8xhm.png)

- **Verify Capability Addition**

  Once added, the capability will be visible below.
  
  ![Configuration Step 7](https://res.cloudinary.com/dhs6nqrgq/image/upload/v1737350042/config6_uf41ae.png)

- **Completion**

  Your configuration is now complete, and you can start integrating the SDK into your app.

### 3. Add the Paywall

 - Import the Package

```swift
import SynchronossIosIapSdk
```


 - Add the Payment Paywall anywhere you want with the valid `USER_UUID` and App `API_KEY`.

```swift
struct AppView: View {
    let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    var body: some View {
        RootPaymentView(userId: "[USER_UUID]", apiKey: apiKey)
    }
}
```

Now the products should be visible if you have them in **Ready for Submit** state in AppStore connect.