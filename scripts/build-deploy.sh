#!/bin/sh

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
ARCHIVE_PATH="$PWD/build.xcarchive"
APP_DIR="$ARCHIVE_PATH/Products/Applications"

LAST_COMMIT_HASH=`git rev-parse HEAD`
LAST_COMMIT_MESSAGE=`git log -1 --pretty='%s'`

echo "********************"
echo "*     Archive      *"
echo "********************"
xcodebuild -scheme "$XCODE_SCHEME" -workspace "$XCODE_WORKSPACE" -archivePath "$ARCHIVE_PATH" clean archive CODE_SIGN_IDENTITY="$DEVELOPER_NAME"

echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication "$APP_DIR/$APPNAME.app" -o "$APP_DIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

echo "********************"
echo "*    Uploading     *"
echo "********************"
RELEASE_NOTES="Commit: $LAST_COMMIT_HASH / LAST_COMMIT_MESSAGE, Build: $CIRCLE_BUILD_NUM, Uploaded: $RELEASE_DATE"
curl https://deploygate.com/api/users/noboru-i/apps \
  -F "file=@$APP_DIR/$APPNAME.ipa" \
  -F "token=$DEPLOY_GATE_KEY" \
  -F "message=$RELEASE_NOTES" -v

echo "********************"
echo "*  Save Artifacts  *"
echo "********************"
mv $APP_DIR/$APPNAME.ipa $CIRCLE_ARTIFACTS
