platform :ios, '8.0'
use_frameworks!

target 'TumeKyouen' do
  pod 'Alamofire', '~> 3.0'
  pod 'Google-Mobile-Ads-SDK', '~> 7.1'
  pod 'OAuthCore', '~> 0.0.1'
  pod 'SVProgressHUD', '~> 2.0.0'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Tumekyouen/Pods-TumeKyouen-acknowledgements.plist', 'TumeKyouen/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
