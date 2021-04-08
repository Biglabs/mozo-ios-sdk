Pod::Spec.new do |s|

  s.name         = "MozoSDK"
  s.version      = "2.0.45"
  s.summary = 'Mozo protocol toolkit for Swift'
  s.description = <<-DESC
                        The Mozo SDK is a Swift implementation of the Mozo protocol. It allows maintaining authentication/authorization with Mozo Services, receiving Mozo Tokens via beacons and buying/selling/transferring Mozo. It is also supporting UI components for authentication and buying/selling/transferring Mozo.
                        ```
                    DESC

  s.homepage         = 'https://www.mozocoin.io/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mozo Developers' => 'developer@mozocoin.io' }
  s.source           = { :git => 'https://github.com/Biglabs/mozo-ios-sdk.git', :tag => "v#{s.version}" }
  s.social_media_url = 'https://facebook.com/MozoXVietNam'

  s.swift_version = '4.1'
  s.ios.deployment_target = '11.0'

  s.source_files = "MozoSDK/**/*.{h,m,swift}"
  s.resources = ['MozoSDK/Classes/**/*.xcdatamodeld', 'MozoSDK/Classes/**/*.txt']
  s.resource_bundles = {
      'MozoSDK' => ['MozoSDK/Classes/**/*.{storyboard,xib}',
                    'MozoSDK/Assets/*.{xcassets,gif}',
                    'MozoSDK/Localization/*.lproj/*.strings']
  }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  
  s.dependency 'AppAuth'
  s.dependency 'CoreStore', '7.3.1'
  
  s.dependency 'RNCryptor', '~> 5.1.0'
  s.dependency 'web3swift', '~> 2.3.0'

  s.dependency 'ReachabilitySwift'
  s.dependency 'MBProgressHUD'
  s.dependency 'AlamofireImage'
  s.dependency 'Kingfisher', '6.1.1'
  s.dependency 'SwiftyJSON', '5.0'
  s.dependency 'libPhoneNumber-iOS'
  s.dependency 'JWTDecode', '2.6.0'

end
