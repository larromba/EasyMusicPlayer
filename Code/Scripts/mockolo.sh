#!/bin/sh

if which mockolo >/dev/null; then
    mockolo -s . -d EasyMusicPlayerTests/Mocks.swift -i EasyMusicPlayer
else
    echo "warning: mockolo not installed, download from https://github.com/uber/mockolo"
    exit -1
fi
