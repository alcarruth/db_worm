#!/bin/sh

rm -rf js
mkdir -p js
coffee -c -o js/ src/*.coffee
