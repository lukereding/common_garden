# common garden

This repository will contain all code associated with analyzing videos taken from common garden tanks.

## contents:

### `locate_fish.py`
Used to record (1) positions of different types of fish in the tank and (2) behaviors performed by fish. It's meant to be used for short videos. Requires [opencv](http://opencv.org/). It writes a `.json` file with a bunch of data. I recommend using the `rjson` package to parse this type of file in `R` like `json_data <- fromJSON(file="/path/to/file.json")`. This returns a bunch of lists that should be able to be wrangled into shape with careful use of `lapply` or `map` functions.

_usage_: python locate_fish.py /path/to/video

#### to do:
:boom: compute average pairwise distance between fish in each category    
:boom: create dialogue box that opens so that the user can select the video file    
:boom: bundle everything into an `.exe` file using py2exe.    

#### `chop_videos.sh`
Used to create 4 5-second videos from the 15 minute videos. Looks like large video files (e.g. ~15 min videos taken from an amazon fire) and extracts 5-sec videos at 1:00, 5:00, 9:00, and 13:00.
