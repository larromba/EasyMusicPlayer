# Easy Music Player [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://img.shields.io) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

| master  | dev |
| ------------- | ------------- |
| [![Build Status](https://travis-ci.com/larromba/EasyMusicPlayer.svg?branch=master)](https://travis-ci.com/larromba/EasyMusicPlayer) | [![Build Status](https://travis-ci.com/larromba/EasyMusicPlayer.svg?branch=dev)](https://travis-ci.com/larromba/EasyMusicPlayer) |

## About
[Easy Music Player](https://itunes.apple.com/app/id1067558718?mt=8) is a simple app designed to play and shuffle music on your device. It's a music player without the faff.

## Installation from Source
If you want to learn iOS development, this project uses industry standard practises.

If you're new to programming, and want an introduction, please go [here](https://github.com/larromba/How-to-Code).

### Dependencies
**SwiftGen**

`brew install swiftgen`

This is used to automatically create the code that accesses `Assets.xcassets` and `Colors.xcassets`.

You can read more [here](https://github.com/realm/SwiftLint).

**SwiftLint**

`brew install swiftlint`

This is a dependency used to lint the code.

You can read more [here](https://github.com/SwiftGen/SwiftGen).

**mockolo** *(unit testing only)*

`brew install mockolo`

This is used to automatically create mocks for unit testing. 

You can read more [here](https://github.com/uber/mockolo).

**fastlane** *(app store snapshots only)*

`brew install fastlane`

This is used to automatically create app store snapshots.

You can read more [here](https://github.com/fastlane/fastlane).

### Build Instructions
This assumes you're familiar with Xcode and building iOS apps. If you're not, start searching the internet and try to figure it out (this experience is very much part of the job in real life!)

*Please note that you might need to change your app's bundle identifier and certificates to match your own.*

To install the on your device with `XCode`:
1. open `EasyMusicPlayer.xcodeproj`
2. select `EasyMusicPlayer` target
3. select your device from the device list
4. run the app

To install the on your device with `ideviceinstaller`:
1. open `EasyMusicPlayer.xcodeproj`
2. select `EasyMusicPlayer` target
3. create an archive
4. `ideviceinstaller -i PATH_TO_YOUR_ARCHIVE.xcarchive/Products/Applications/EasyMusicPlayer.app`

To install on the simulator:
_The simulator's music library can be found here: `SimulatorMusicLibrary`_
1. open `EasyMusicPlayer.xcodeproj`
2. select `EasyMusicPlayer` target
3. select a simulator device from the device list
4. run the app

### Generating snapshots
This will generate framed snapshots for the app store.

```
cd <project root>
fastlane snapshot -p Code/EasyMusicPlayer.xcodeproj
cd AppStore/Screenshots
fastlane frameit silver
```

## How it works
It's essentially just a ui wrapper around Apple's `MediaPlayer` framework. 
- The top bar shows the track information and lets the user scrub the time
- The bottom section contains some usual controls: 
    - the usual: play, pause, previous, next, repeat 
    - a shuffle button: this might seem pointless, as the tracks are initially in a random order, however over time, the order gets learned and is predictable
    - a search button: simple search to play a tune you're looking for

## Intention
The primary intention is to maintain a simple app that quickly plays on your device. Even though music is mostly listened to online nowadays, sometimes devices run out of data, or there's no internet. Apple's Music app is a bit complex, so this is an alternative way to quickly get some music playing.

The secondary intention is to maintain an iOS project in SwiftUI using industry standards for those who are interested to learn iOS development. The best way to learn is often by doing - so please feel free to clone this project and hack it up!

## Contributing
You are welcome to contribute something cool. Easter Eggs are welcome!

It might be a good idea to discuss the idea before spending your time on it by either:
- raising an issue on GitHub
- contacting me using the link below

To contribute, please make a pull-request with your idea remembering to:
- Create a feature branch from develop - this project is trying to follow [git-flow](https://datasift.github.io/gitflow/IntroducingGitFlow.html).
- Place all your logic in view models. If you'd like to understand why, please read the **Architecture** section below.
- Unit test your view models & code where it makes sense.
- Loosely follow this [style guide](https://github.com/kodecocodes/swift-style-guide/tree/main) and these [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Make a pull request into the `main` branch
- I will check your code, squash-merge it into `main`, and then release a new version.

_If you don't have the money to afford a university degree, and want to become an iOS developer, please make a PR, add this project to your CV, and use my contact details as a reference._

Have fun! This app is live in the app store, so your contributions will help people around the world enjoy their music.

## Localizations
There's a number of things localised. You can find them in text files here: 

`Code/EasyMusicPlayer/[LANGUAGE].lproj. 

Most of them were Google translated, so please feel welcome to make corrections, or even add a new language!

## Scripts
There are number of scripts to automatically run the dependencies described above. None of them are malicious. It's always good practise to check yourself to avoid spyware. They are kept here: `Code/Scripts`, and ran from the `Build Phases` tab on the `EasyMusicPlayer` and `EasyMusicPlayerTests` targets.

## Testing
- `ViewModels` are unit tested. When injecting objects, please reference them over an interface (protocol). Use `ing` or `able` as the extension of your interface's name (e.g. `MusicPlayer` -> `MusicPlaying`). This is inspired by the [Swift API Guidelines](https://www.swift.org/documentation/api-design-guidelines/)).
- The service objects are mostly covered by QA tests.
- The QA steps are loosely replicated in the UI tests (however the framework hasn't always been stable).

## CI
`Travis CI` is used to run the unit tests remotely on each branch. The badges on the top of this page show the status of the main branches.

## Architecture
Architecture will make you go crazy, it really will. It's human nature to try and find a repeatable pattern that can be applied to every situation. However, at least in my experience, that's not really possible, or natural! Conceptually it feels possible, but after trying to invent an architecture, and from using various architectures professionally, it seems a slippery slope whereby you either fight the ecosystem, or over-engineer things.

I once worked with an old C programmer; he had around 15 years of experience. I remember seeing his iOS code and thinking, is that is? I expected more! There's lots of stuff going on in this function, where's all the abstractions, etc. It's taken me some years to realise we often think 'complex' means 'better'. It's not. Simple is better. This is what his 15 years of experience showed; sure - it wasn't pretty, but anyone could have read it, and this is important when working with others. Whilst there's good practises to follow, code should always remain accessible - it's just a tool; a hammer - why overcomplicate that?

`ViewModels` make sense for this project, as we want to test the logic, and practise a common design pattern found in professional projects. People will disagree, and that's ok, because there's not one correct way to do things. The aim is to keep things simple; we're creating: complexity stifles it; play encourages it.

## File Structure
Please note the file structure is intentionally flat, and the the virtual folders in XCode are used for the organisation. From experience, once files start moving around or renamed, it gets messy with git. It also makes searching for files much easier in the code directory if the project gets more complicated.

## Licence
[![licensebuttons by-nc-sa](https://licensebuttons.net/l/by-nc-sa/3.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0) 

## Contact
Please use [this form](http://developer.larhythmix.com/contact).
