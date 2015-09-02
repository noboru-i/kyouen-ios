#!/bin/sh

sudo gem install --no-document checkstyle_filter-git saddler saddler-reporter-github ios_analytics

xcodebuild -scheme "$XCODE_SCHEME" -workspace "$XCODE_WORKSPACE" -archivePath "$ARCHIVE_PATH" -derivedDataPath "$PWD/derivedData" analyze CODE_SIGN_IDENTITY="$DEVELOPER_NAME"

if [ -z "${CI_PULL_REQUEST}" ]; then
    # when not pull request
    REPORTER=Saddler::Reporter::Github::CommitReviewComment
else
    REPORTER=Saddler::Reporter::Github::PullRequestReviewComment
fi

echo "********************"
echo "* iOS analytics    *"
echo "********************"
ios_analytics translate --appName=$APPNAME --derivedData="$PWD/derivedData" \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require saddler/reporter/github --reporter $REPORTER
