Pod::Spec.new do |s|
  s.name            = "MozoSDK"
  s.version         = "2.1.3.3"
  s.summary         = "Mozo protocol toolkit for Swift"
  s.description     = <<-DESC
The Mozo SDK is a Swift implementation of the Mozo protocol. It allows maintaining authentication, authorization with Mozo Services, receiving Mozo Tokens via beacons and buying, selling, transferring Mozo. It is also supporting UI components for authentication and buying, selling, transferring Mozo.
                      DESC
  s.homepage         = "https://mozotoken.com"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.authors          = { "Mozo Developers" => "developer@mozocoin.io" }
  s.source           = { :git => "https://github.com/Biglabs/mozo-ios-sdk.git", :tag => "v#{s.version}" }
  s.social_media_url = "https://www.facebook.com/mozoxvn"

  s.swift_version    = "5"
  s.ios.deployment_target = "12.0"

  s.source_files     = "MozoSDK/Classes/**/*.{h,m,swift}"
  s.resource_bundles = {
      'MozoSDK' => ['MozoSDK/Classes/**/*.*', 'MozoSDK/Resources/**']
  }
  
  s.dependency 'Alamofire'
  s.dependency 'CoreStore'
  s.dependency 'RNCryptor', '~> 5.1.0'
  s.dependency 'web3swift', '~> 2.6.4'
  s.dependency 'MBProgressHUD'
  s.dependency 'SDWebImage'
  s.dependency 'SwiftyJSON'
  s.dependency 'libPhoneNumber-iOS'
  s.dependency 'JWTDecode'
end
