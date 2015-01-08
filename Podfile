platform :ios, '7.0'
pod 'AFNetworking', '~> 2.2'
pod 'Google-Mobile-Ads-SDK', '~> 6.8'
pod 'OAuthCore', '~> 0.0.1'
pod 'SVProgressHUD', '~> 1.0'
pod 'FLEX', '~> 1.0'

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'TumeKyouen/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end