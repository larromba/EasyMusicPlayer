#!/bin/bash

FRAMEWORK="Carthage/Build/iOS/TestExtensions.framework"
FILE="TestExtensions"

if test -f "$FRAMEWORK/$FILE"_old; then
	echo "Already fixed:"
	echo "$FRAMEWORK"
	exit 0
fi

mv "$FRAMEWORK/$FILE" "$FRAMEWORK/$FILE"_old
lipo -thin x86_64 "$FRAMEWORK/$FILE"_old -output "$FRAMEWORK/$FILE"
