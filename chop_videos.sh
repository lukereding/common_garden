#!/usr/bin/env bash

# the actual ffmpeg command

if [ "$#" -ne 2 ]; then
    echo "supply exactly two arguments. The first is the path to the video file, the second is either 1, 6, or 11, specifying the minute to start the clip from."
fi

# check file name
if [ ! -f $1 ]; then
  echo "file not found. exiting."
  exit 1
fi


# check second argument
if [ "$2" != "1" ] && [ "$2" != "6" ] && [ "$2" != "11" ]; then
  echo "second argument must be 1, 6, or 11."
  exit 3
fi

# get basename of file
BASE=`basename $1`
FILE=${BASE%.*}
DIR=$(dirname "${1}")

if [ "$2" -eq "1" ]; then
    ffmpeg -ss 00:01:00 -i $1 -t 00:00:10 -vcodec copy -async 1 -y "$DIR"/"$FILE"_1min.mp4
elif [ "$2" -eq "6" ]; then
    ffmpeg -ss 00:06:00 -i $1 -t 00:00:10 -vcodec copy -async 1 -y "$DIR"/"$FILE"_6min.mp4
else
    ffmpeg -ss 00:11:00 -i $1 -t 00:00:10 -vcodec copy -y "$DIR"/"$FILE"_11min.mp4
fi

if ! [ $? -eq 0 ]; then
    echo "ffmpeg failed with status $?. sorry."
    exit 2
fi