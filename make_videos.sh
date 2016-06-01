#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "only need one argument: the path to the directory containing the video files"
    exit 1
fi

command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "ffmpeg is not installed. install with brew install ffmpeg"; exit 1; }

# make all the videos from 1 min
find $1 -type f -maxdepth 1 -name "*.mp4" -exec bash chop_videos.sh {} 1 \; 

# make all the videos from 6 min
find $1 -type f -maxdepth 1 -name "*.mp4" -exec bash chop_videos.sh {} 6 \; 

# make all the videos from 11 min
find $1 -type f -maxdepth 1 -name "*.mp4" -exec bash chop_videos.sh {} 1 \; 