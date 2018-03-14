# 詰め共円 for iOS

[![Circle CI](https://circleci.com/gh/noboru-i/kyouen-ios.svg?style=svg)](https://circleci.com/gh/noboru-i/kyouen-ios)

[iTunes でダウンロード](https://itunes.apple.com/jp/app/jieme-gong-yuan/id792426923?mt=8)

## How to update version

1. update `CFBundleShortVersionString` by Xcode.
2. merge to master branch.
3. create tag. name mast be `vN.N.N` format.

## How to update Acknowledgements

```
license-plist --output-path $PRODUCT_NAME/Resources/Settings.bundle
```
