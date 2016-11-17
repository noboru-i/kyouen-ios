platform :ios, '8.0'
use_frameworks!

target 'TumeKyouen' do
  pod 'Alamofire', '~> 3.0'
  pod 'APIKit', '~> 2.0'
  pod 'Himotoki', '~> 2.1.1'
  pod 'OAuthCore', '~> 0.0.1'
  pod 'SVProgressHUD', '~> 2.0.0'
  pod 'Firebase'
  pod 'Firebase/AdMob'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = "2.3"
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
      end
    end

    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Tumekyouen/Pods-TumeKyouen-acknowledgements.plist', 'TumeKyouen/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
