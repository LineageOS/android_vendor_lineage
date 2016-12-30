#!/bin/bash

url=$1
output=$2

curl -L "$url" --create-dirs -o $output --compressed -H "Accept-Encoding: gzip,deflate,sdch" && exit 0 || exit 1
