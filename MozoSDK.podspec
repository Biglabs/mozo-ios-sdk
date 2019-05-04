Pod::Spec.new do |s|

  s.name         = "MozoSDK"
  s.version      = "1.4.21"
  s.summary = 'Mozo protocol toolkit for Swift'
  s.description = <<-DESC
                        The Mozo SDK is a Swift implementation of the Mozo protocol. This SDK was originally made by Hoang Nguyen. It allows maintaining authentication/authorization with MozoX Services, receiving MozoX lucky coins via beacons and buying/selling/transferring MozoX. It is also supporting UI components for authentication and buying/selling/transferring MozoX.
                        ```
                    DESC

  s.homepage         = 'https://www.mozocoin.io/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mozo developers' => 'developer@mozocoin.io' }
  s.source           = { :git => 'https://github.com/Biglabs/mozo-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '4.1'
  s.ios.deployment_target = '10.0'

  s.source_files = "MozoSDK/Classes/**/*.{h,swift}"
  
  s.resources = ['MozoSDK/Classes/**/*.xcdatamodeld']
  s.resource_bundles = {
      'MozoSDK' => ['MozoSDK/Classes/**/*.{storyboard,xib}',
                    'MozoSDK/Assets/*.xcassets',
                    'MozoSDK/Localization/*.lproj/*.strings']
  }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  
  s.dependency 'SwiftyJSON', '~> 3.1.4'
  s.dependency 'web3swift', '~> 1.1.1'
  s.dependency 'secp256k1_ios', '~> 0.1'
  s.dependency 'RNCryptor', '~> 5.0.3'
  s.dependency 'PromiseKit/Alamofire', '~> 6.0'
  s.dependency 'AlamofireImage', '~> 3.5.0'
  s.dependency 'CoreStore', '5.1.1'
  s.dependency 'AppAuth', '~> 0.92.0'
  s.dependency 'Starscream', '3.0.2'
  s.dependency 'ReachabilitySwift', '4.3.0'
  s.dependency 'MBProgressHUD', '~> 1.1.0'
end
