# Easy Music Player [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://img.shields.io) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

| master  | dev |
| ------------- | ------------- |
| [![Build Status](https://travis-ci.com/larromba/EasyMusicPlayer.svg?branch=master)](https://travis-ci.com/larromba/EasyMusicPlayer) | [![Build Status](https://travis-ci.com/larromba/EasyMusicPlayer.svg?branch=dev)](https://travis-ci.com/larromba/EasyMusicPlayer) |

## About
Easy Music Player [(app store)](https://itunes.apple.com/app/id1067558718?mt=8) is a simple app designed only to play and shuffle music. It's a music player without the faff. It also works with an external bluetooth headset.

## Installation from Source

### Dependencies
**SwiftGen**

`brew install swiftgen`

**SwiftLint**

`brew install swiftlint`

**Sourcery** *(testing only)*

`brew install sourcery`

**Carthage** 

`brew install carthage`

**Fastlane** *(app store snapshots only)*

`brew install fastlane`

### Build Instructions
This assumes you're farmiliar with Xcode and building iOS apps.

*Please note that you might need to change your app's bundle identifier and certificates to match your own.*

To install the app-store version on your device:
1. `carthage update --platform iOS`
2. open `EasyMusicPlayer.xcodeproj`
3. select `EasyMusicPlayer-Release` target
4. select your device from the device list
5. run the app

To debug on the simulator (using dummy audio files):
1. `carthage update --platform iOS --no-use-binaries`
2. open `EasyMusicPlayer.xcodeproj`
3. select `EasyMusicPlayer` target
4. select a simulator device from the device list
5. run the app

### Generating snapshots
```
cd <project root>
fastlane snapshot
cd screenshots
fastlane frameit silver
```

## How it works
It's essentially a wrapper around Apple's `MediaPlayer` framework.

## Licence
[![licensebuttons by-nc-sa](https://licensebuttons.net/l/by-nc-sa/3.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0) 

## Contact
larromba@gmail.com
