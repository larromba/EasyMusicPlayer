# Logging [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

| master  | dev |
| ------------- | ------------- |
| [![Build Status](https://travis-ci.com/larromba/Logging.svg?branch=master)](https://travis-ci.com/larromba/logging) | [![Build Status](https://travis-ci.com/larromba/Logging.svg?branch=dev)](https://travis-ci.com/larromba/logging) |

## About
Simple logging for Swift projects

## Installation

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

```
// Cartfile
github "larromba/logging" ~> 1.0
```

```
// Terminal
carthage update
```

## Usage

**Global logging**
```swift
log(...)
logWarning(...)
logError(...)
logMagic(...)
logHack(...)
```

**Targetted logging**
```swift

enum MyLog: Log {
    static var isEnabled: Bool = true
}
enum MyLog2: Log {
    static var isEnabled: Bool = true
}
enum MyLog3: Log {
    static var isEnabled: Bool = true
}

let aLogGroup: [Log.Type] = [MyLog2.self, MyLog3.self]

func foo() {
    MyLog.info(...)
    MyLog.warning(...)
    MyLog.error(...)
    MyLog.magic(...)
    MyLog.hack(...)
    MyLog.isEnabled = false

    // an example of how to disable log groups
    aLogGroup.forEach { $0.isEnabled = false }
}
```

## Licence
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

## Contact
larromba@gmail.com
