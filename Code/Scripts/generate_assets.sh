#!/bin/sh

if which swiftgen >/dev/null; then
    swiftgen config run --config .swiftgen.yml
else
    echo "warning: swiftgen not installed, download from https://github.com/SwiftGen/SwiftGen"
    exit -1
fi
