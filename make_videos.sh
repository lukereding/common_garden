#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "only need one argument: the path to the directory containing the video files"
    exit 1
fi

command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "ffmpeg is not installed. install with brew install ffmpeg"; exit 2; }


# create a new directory called 'short_videos' if it doesn't exist
if [ ! -d "$1""/short_videos" ]; then
    mkdir "$1""/short_videos"
fi

# create a log file so that when you run this script multiple times, it won't re-create the same videos
# if it doesn't exist, then chop up all the videos
LOGFILE='DO_NOT_DELETE.log'
if [ ! -f "$1"/"$LOGFILE" ]; then
    find "$1" -type f -name "*.mp4" -exec bash chop_videos.sh {} 1 \; 
    find "$1" -type f -name "*.mp4" -exec bash chop_videos.sh {} 6 \; 
    find "$1" -type f -name "*.mp4" -exec bash chop_videos.sh {} 11 \;
    echo "creating log file at "$1"/"$LOGFILE""
    echo -e "This file's only purpose is to be updated when the make_videos.sh program runs. The make_videos.sh program will only make new short videos for the 15 min. common garden videos that are newer than the last time this file was created (and thus the program run).\n\nPlease do not delete or remove this file." > "$1"/"$LOGFILE"
else
    
    # otherwise, a log file already exists, so use the -newer option in find to only update those newer files
    
    # make all the videos from 1 min
    find "$1" -type f -newer "$1"/"$LOGFILE" -maxdepth 1 -name "*.mp4" -exec bash chop_videos.sh {} 1 \; 

    if [ $? -gt 0 ]; then
        echo "something went wrong with the ffmpeg conversion."
        exit 3
    fi

    # make all the videos from 6 min
    find "$1" -type f -newer "$1"/"$LOGFILE" -maxdepth 1 -name "*.mp4" -exec bash chop_videos.sh {} 6 \; 

    if [ $? -gt 0 ]; then
        echo "something went wrong with the ffmpeg conversion."
        exit 3
    fi

    # make all the videos from 11 min
    find "$1" -type f -newer "$1"/"$LOGFILE" -maxdepth 1 -name "*.mp4" -exec bash chop_videos.sh {} 11 \; 

    if [ $? -gt 0 ]; then
        echo "something went wrong with the ffmpeg conversion."
        exit 3
    fi
fi

# update the log file
touch "$1"/"$LOGFILE"

if [ $? -eq 0 ]; then
    echo -e "\n\ndone creating videos. "$1"/"$LOGFILE" was updated."
fi

exit 0