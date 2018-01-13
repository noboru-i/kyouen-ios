platform :ios, '9.0'
use_frameworks!

target 'TumeKyouen' do
  pod 'Alamofire', '~> 4.0'
  pod 'OAuthCore', '~> 0.0.1'
  pod 'SVProgressHUD', '~> 2.1'
  pod 'Firebase'
  pod 'Firebase/AdMob'
  pod 'Firebase/Performance'
  pod 'TwitterCore', '~> 3.0'
  pod 'TwitterKit', '~> 3.0'
  pod 'Fabric', '~> 1.7.2'
  pod 'Crashlytics', '~> 3.9.3'
end

post_install do |installer|
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Tumekyouen/Pods-TumeKyouen-acknowledgements.plist', 'TumeKyouen/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
