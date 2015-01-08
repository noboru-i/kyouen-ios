WORKSPACE    = 'TumeKyouen.xcworkspace'
SCHEME       = 'TumeKyouen'
PRODUCT_NAME = 'TumeKyouen'
BUILD_DIR    = 'build'

PROVISIONING_PROFILE_UUID = '3E70D947-A29B-440F-9A98-32BE98F959E7'
KEYCHAIN_NAME             = 'custom.keychain'

PROVISIONING_PROFILE_PATH = '/path/to/provisioning_uuid.mobileprovision'
APPLE_CERTIFICATE_PATH    = '/path/to/apple.cer'
DISTRIBUTION_CER_PATH     = '/path/to/distribution.cer'
DISTRIBUTION_P12_PATH     = '/path/to/distribution.p12'

P12_PASSPHRASE          = ENV['P12_PASSPHRASE']
ITUNES_CONNECT_ID       = ENV['ITUNES_CONNECT_ID']
ITUNES_CONNECT_PASSWORD = ENV['ITUNES_CONNECT_PASSWORD']
CRITTERCISM_APP_ID      = ENV['CRITTERCISM_APP_ID']
CRITTERCISM_KEY         = ENV['CRITTERCISM_KEY']

PRODUCT_DIR    = File.join(BUILD_DIR, 'product')
XCARCHIVE_PATH = File.join(PRODUCT_DIR, "#{SCHEME}.xcarchive")
IPA_PATH       = File.join(PRODUCT_DIR, "#{SCHEME}.ipa")
DSYM_DIR       = File.join(XCARCHIVE_PATH, "dSYMs")
DSYM_PATH      = File.join(DSYM_DIR, "#{PRODUCT_NAME}.app.dSYM.zip")

desc 'delete build directories and execute xcodebuild clean.'
task :clean do
  rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
  sh 'set -o pipefail && xcodebuild clean | xcpretty -c'
end

desc 'install developer identity profile.'
task :install_signing_items do
  sh "cp #{PROVISIONING_PROFILE_PATH} $HOME/Library/MobileDevice/Provisioning\\ Profiles"
  sh "security create-keychain -p circle #{KEYCHAIN_NAME}"
  sh "security import #{APPLE_CERTIFICATE_PATH} -k #{KEYCHAIN_NAME} -T /usr/bin/codesign"
  sh "security import #{DISTRIBUTION_CER_PATH} -k #{KEYCHAIN_NAME} -T /usr/bin/codesign"
  sh "security import #{DISTRIBUTION_P12_PATH} -k #{KEYCHAIN_NAME} -P #{P12_PASSPHRASE} -T /usr/bin/codesign"
  sh "security default-keychain -s #{KEYCHAIN_NAME}"
end

desc 'run unit tests on main target.'
task :test do
  report_dir = ENV['CIRCLE_TEST_REPORTS']
  report_option = ""
  if report_dir
    report_option = "-r junit -o #{report_dir}/test-report.xml"
  end

  sh "set -o pipefail && xcodebuild test \\
      -sdk iphonesimulator \\
      -workspace #{WORKSPACE} \\
      -scheme #{SCHEME} | xcpretty -c #{report_option}"
end

desc 'archive ipa.'
task :archive do
  rm_rf(PRODUCT_DIR) if File.exist?(PRODUCT_DIR)
  mkdir_p(PRODUCT_DIR)

  sh "set -o pipefail && xcodebuild archive \\
      -sdk iphoneos \\
      -configuration Release \\
      -workspace #{WORKSPACE} \\
      -scheme #{SCHEME} \\
      -archivePath #{XCARCHIVE_PATH} \\
      PROVISIONING_PROFILE=#{PROVISIONING_PROFILE_UUID} | xcpretty -c"

  provisioning_path = "~/Library/MobileDevice/Provisioning\\ Profiles/#{PROVISIONING_PROFILE_UUID}.mobileprovision"
  provisioning_name = `/usr/libexec/PlistBuddy -c 'Print Name' /dev/stdin <<< $(security cms -D -i #{provisioning_path})`.chomp

  sh "set -o pipefail && xcodebuild \\
      -exportArchive \\
      -exportFormat ipa \\
      -archivePath #{XCARCHIVE_PATH} \\
      -exportPath #{IPA_PATH} \\
      -exportProvisioningProfile \"#{provisioning_name}\" | xcpretty -c"

  sh "(cd #{DSYM_DIR}; zip -r #{PRODUCT_NAME}.app.dSYM.zip #{PRODUCT_NAME}.app.dSYM)"

  # Xcode 6.1 and 6.1.1 cannot archive ipa contains SwiftSupport correctly
  # sh "sh package_ipa.sh #{XCARCHIVE_PATH}/Products/Applications/#{PRODUCT_NAME}.app #{IPA_PATH}"
end

desc 'submit dSYM to Crittercism'
task :crittercism do
  sh "curl https://app.crittercism.com/api_beta/dsym/#{CRITTERCISM_APP_ID} \\
      -F dsym=@#{DSYM_PATH} \\
      -F key=#{CRITTERCISM_KEY}"
end

desc 'validate ipa.'
task :validate_ipa do
  sh "altool \\
      --validate-app \\
      --file #{IPA_PATH} \\
      --username #{ITUNES_CONNECT_ID} \\
      --password #{ITUNES_CONNECT_PASSWORD}"
end

desc 'upload ipa.'
task :upload_ipa do
  sh "altool \\
      --upload-app \\
      --file #{IPA_PATH} \\
      --username #{ITUNES_CONNECT_ID} \\
      --password #{ITUNES_CONNECT_PASSWORD}"
end

desc 'run deploy tasks.'
task :deploy => [:install_signing_items,
                 :clean,
                 :archive,
                 :crittercism,
                 :validate_ipa,
                 :upload_ipa]