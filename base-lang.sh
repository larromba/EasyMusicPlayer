#!/bin/bash

home=`pwd`
path=$home/EasyMusic

fromDir=$path/en.lproj
toDir=$path/Base.lproj

cp "$fromDir"/*.strings "$toDir/"