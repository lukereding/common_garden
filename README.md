# common garden

This repository will contain all code associated with analyzing videos taken from common garden tanks.

## to use the program:
- Are you using a Mac? 
   - If so, great, otherwise you can directly run the `common_garden.py` script after installing a ton of dependencies.
- Download this repository by clicking the Download button above. Choose zip.
- Un-zip the repository.
- Connect the hard drive containing the videos to the computer.
- In the Finder, find the folder you creating by un-ziping the directory. Double click on `common_garden`. Follow the instructions.

## contents:

### `common_garden.exe`

Executable file for MAC OSX. If you have a mac, downloading this file and double-clicking it should do the trick.

Note that this executable was made with [pyinstaller](https://github.com/pyinstaller/pyinstaller) and that I have had no luck with similar programs that promise to do similar things (py2exe, py2app, nuitka, etc.). The `.exe` file was created with `pyinstaller common_garden.py --onefile --windowed`.

Run by double-clicking on the icon.

### `common_garden.py`
Used to record (1) positions of different types of fish in the tank and (2) behaviors performed by fish. It's meant to be used for short videos. Requires [opencv](http://opencv.org/). It writes a `.json` file with a bunch of data. I recommend using the `rjson` package to parse this type of file in `R` like `json_data <- fromJSON(file="/path/to/file.json")`. This returns a bunch of lists that should be able to be wrangled into shape with careful use of `lapply` or `map` functions.

Run like `python common_garden.py`

### `make_videos.sh`
Used to create 3 10-second videos from the 15 minute videos. Looks like large video files (e.g. ~15 min videos taken from an amazon fire) and extracts 5-sec videos at 1:00, 6:00, and 11:00. It assumes that all your videos are in a single folder with no sub-folders or directories. Spaces in pathnames are allowed.

Run like `bash make_videos.sh /path/to/videos`

### `chop_videos.sh`
Workhorse script of `make_videos.sh`. Not used directly. Overwrites video files if necessary. 