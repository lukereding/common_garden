# common garden

This repository contains code and executable files to run a program to analyze videos taken for the common garden experiment.

## using the program
- on the mac mini in the lab, simply click on the common garden icon in the dock.
- (Note that these steps only work if you are using a Mac. A Windows machine could run the program directly like `python common_garden.py` after downloading all necessary dependencies.)
- Download this repository by clicking the Download button above. Choose zip.
- Un-zip the repository.
- Connect the hard drive containing the videos to the computer.
- In the Finder, find the folder you creating by un-ziping the directory. Double click on `common_garden`. Follow the instructions.

When the program is started, it prompts you to select the video you'd like to analyze. This is any video in the `small_videos` directory of Mary's external hard drive. The program then shows the 10 second video on repeat indefinately. Record all relevant behaviors and take note of the locations of all fish. Hit Escape to stop the video. The first frame of the video then appears; use the left and right cursors to go forward or backwards through the video to find a frame where you can see most of the fish. Hit Escape once you find this frame. The program them prompts you to click on the locations of the males, model females, and juvenile fish. Hit Escape after each. The program then opens a dialogue box where you can enter the number of behaviors. Click Submit to submit your answers, and Close to end the trial. If everything works, a box will pop up telling you everything saved.

The program moves the video you just watched to a new folder called `already watched` and the resulting JSON data file to a new `data` folder.

### In action:

![gif example](https://github.com/lukereding/common_garden/raw/master/example_of_usage.gif)


## contents:

### `common_garden`

Executable file for MAC OSX. If you have a mac, downloading this file and double-clicking it should do the trick.

Note that this executable was made with [pyinstaller](https://github.com/pyinstaller/pyinstaller) and that I have had no luck with similar programs that promise to do similar things (py2exe, py2app, nuitka, etc.). This file was created with `pyinstaller common_garden.py --onefile --windowed`.

Run by double-clicking on the icon.

### `common_garden.py`
Used to record (1) positions of different types of fish in the tank and (2) behaviors performed by fish. It's meant to be used for short videos. Requires [opencv](http://opencv.org/). It writes a `.json` file with a bunch of data. I recommend using the `rjson` package to parse this type of file in `R` like `json_data <- fromJSON(file="/path/to/file.json")`. This returns a bunch of lists that should be able to be wrangled into shape with careful use of `lapply` or `map` functions.

Run like `python common_garden.py`. This is equivalent to double-clicking on the common_garden icon.

### `make_videos.sh`
Used to create 3 10-second videos from the 15 minute videos. Looks like large video files (e.g. ~15 min videos taken from an amazon fire) and extracts 5-sec videos at 1:00, 6:00, and 11:00. It assumes that all your videos are in a single folder with no sub-folders or directories. Spaces in pathnames are allowed.

Run like `bash make_videos.sh /path/to/videos`

### `chop_videos.sh`
Workhorse script of `make_videos.sh`. Not used directly. Overwrites video files if necessary.
