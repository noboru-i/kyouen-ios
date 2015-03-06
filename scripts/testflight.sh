#!/bin/sh

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
ARCHIVE_PATH="$PWD/build.xcarchive"
APP_DIR="$ARCHIVE_PATH/Products/Applications"
DSYM_DIR="$ARCHIVE_PATH/dSYMs"

echo "********************"
echo "*     Archive      *"
echo "********************"
xcodebuild -scheme "$XCODE_SCHEME" -workspace "$XCODE_WORKSPACE" -archivePath "$ARCHIVE_PATH" clean archive CODE_SIGN_IDENTITY="$DEVELOPER_NAME"

echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication "$APP_DIR/$APPNAME.app" -o "$APP_DIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

RELEASE_NOTES="Build: $CIRCLE_BUILD_NUM\nUploaded: $RELEASE_DATE"

zip -r -9 "$DSYM_DIR/$APPNAME.app.dSYM.zip" "$DSYM_DIR/$APPNAME.app.dSYM"

echo "********************"
echo "*    Uploading     *"
echo "********************"
curl https://deploygate.com/api/users/noboru-i/apps
  -F "file=@$APP_DIR/$APPNAME.ipa"
  -F "token=$DEPLOY_GATE_KEY"
  -F "message=$RELEASE_NOTES" -v
