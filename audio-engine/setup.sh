#!/bin/bash

DIR="$HOME/Library/Application Support/SuperCollider/sounds";
FILE="1bar-metro.wav";

mkdir -p "$DIR";
cp $FILE "$DIR/$FILE";