#!/bin/sh

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
LAST_COMMIT_HASH=`git rev-parse HEAD`
LAST_COMMIT_MESSAGE=`git log -1 --pretty='%s'`
SAVED_IPA="$CIRCLE_ARTIFACTS/$APPNAME.ipa"

echo $SAVED_IPA

echo "********************"
echo "*    Uploading     *"
echo "********************"
RELEASE_NOTES="Commit: $LAST_COMMIT_HASH / $LAST_COMMIT_MESSAGE, Build: $CIRCLE_BUILD_NUM, Uploaded: $RELEASE_DATE"
curl https://deploygate.com/api/users/noboru-i/apps \
  -F "file=@$SAVED_IPA" \
  -F "token=$DEPLOY_GATE_KEY" \
  -F "message=$RELEASE_NOTES" -v

echo "********************"
echo "*  GitHub Release  *"
echo "********************"
export HUB_CONFIG="$PWD/hub_config"
echo "github.com:" > $HUB_CONFIG
echo "- user: $CIRCLE_PROJECT_USERNAME" >> $HUB_CONFIG
echo "  oauth_token: $GITHUB_ACCESS_TOKEN" >> $HUB_CONFIG
hub release create -p -a $SAVED_IPA -m "Build: $CIRCLE_BUILD_NUM" "v`date '+%Y%m%d%H%M%S'`"
