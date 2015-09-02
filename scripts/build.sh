#!/bin/sh

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
ARCHIVE_PATH="$PWD/build.xcarchive"
APP_DIR="$ARCHIVE_PATH/Products/Applications"

echo "********************"
echo "*     Archive      *"
echo "********************"
xcodebuild -scheme "$XCODE_SCHEME" -workspace "$XCODE_WORKSPACE" -archivePath "$ARCHIVE_PATH" -derivedDataPath "$PWD/derivedData" archive CODE_SIGN_IDENTITY="$DEVELOPER_NAME"

echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication "$APP_DIR/$APPNAME.app" -o "$APP_DIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

echo "********************"
echo "*  Save Artifacts  *"
echo "********************"
cp $APP_DIR/$APPNAME.ipa $CIRCLE_ARTIFACTS
