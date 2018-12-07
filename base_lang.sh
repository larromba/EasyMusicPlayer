#!/bin/bash

home=`pwd`
path=$home/EasyMusicPlayer

fromDir=$path/en.lproj
toDir=$path/Base.lproj

cp "$fromDir"/*.strings "$toDir/"