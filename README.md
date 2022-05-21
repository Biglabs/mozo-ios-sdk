# Mozo SDK for iOS
[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MozoSDK/badge.png)](https://cocoapods.org/pods/MozoSDK)
[![Swift version](https://img.shields.io/badge/Swift-5-orange)](#)
[![iOS version](https://img.shields.io/badge/iOS-11-green)](#)

MozoSDK for iOS by MozoX Pte. Ltd.
For more information please see [the website][1].

## Install

#### Using [CocoaPods](https://cocoapods.org/pods/MozoSDK)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target 'MyApp' do
  pod 'MozoSDK'
end
```

## Requirements

With iOS 10 and higher you need to add some keys to the Info.plist of your project. This should be found in 'your_project/ios/your_project/Info.plist'.
1. The "Privacy - Camera Usage Description" key. Add the following code:
```
<key>NSCameraUsageDescription</key>
<string>To scan QR Codes and detect your face.</string>
```
2. The "Privacy - Location Always Usage Description" key.
```
<key>NSLocationAlwaysUsageDescription</key>
<string>To assist you in finding Mozo Tokens.</string>
```
3. The "Privacy - Bluetooth Peripheral Usage Description" key.
```
<key>NSBluetoothPeripheralUsageDescription</key>
<string>To enable you to receive Mozo Tokens.</string>
```

## Getting Started with Swift

1. Import the MozoSDK header in the application delegate.

```swift
import MozoSDK
```

2. Create a default service configuration by adding the following code snippet in the `application:didFinishLaunchingWithOptions:` application delegate method.

```swift
MozoSDK.configure()
```
or you can create a specific configuration for your company through registered api key:

```swift
MozoSDK.configure(apiKey: "YOUR API KEY")
```
and your target network:

```swift
MozoSDK.configure(apiKey: "YOUR API KEY", network: NetworkType.MainNet)
```

3. In Swift file you want to use the SDK, import the MozoSDK headers for the services you are using. The header file import convention is `import MozoSDK`, as in the following examples:

```swift
import MozoSDK
```
4. Request MozoSDK for authentication:
 
```swift
MozoSDK.authenticate()
```

5. Request MozoSDK for transfer:

```swift
MozoSDK.transferMozo()
```

6. Request MozoSDK for transaction history:

```swift
MozoSDK.displayTransactionHistory()
```

## Getting Started with Objective-C

1. Import the MozoSDK header in the application delegate.

```objective-c
@import MozoSDK;
```

2. Create a default service configuration by adding the following code snippet in the `application:didFinishLaunchingWithOptions:` application delegate method.

```objective-c
[MozoSDK configure];
```

3. Import the MozoSDK headers for the services you are using. The header file import convention is `@import MozoSDK;`, as in the following examples:

```objective-c
@import MozoSDK;
```

## FEATURES

- [Authentication][https://github.com/Biglabs/mozo-ios-sdk/wiki/authentication]
- [UI Components][https://github.com/Biglabs/mozo-ios-sdk/wiki/ui-components]
- [Transfer Mozo Offchain][https://github.com/Biglabs/mozo-ios-sdk/wiki/transfer-mozo-offchain]
- [Transaction History][https://github.com/Biglabs/mozo-ios-sdk/wiki/transaction-history]

## GIVE FEEDBACK

To report a specific problem or feature request, open a new issue on Github. For questions, suggestions, or anything else, email to <developer@mozocoin.io>, or join our Slack channel.

## LICENSE

See the [LICENSE](LICENSE) file.

[1]: https://mozocoin.io/.
