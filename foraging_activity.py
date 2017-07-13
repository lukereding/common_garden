import cv2
import numpy as np
import sys
from math import sqrt
import json
import os.path
import os
from Tkinter import *
from tkFileDialog import askopenfilename
import tkMessageBox

'''

script for recording foraging and activity measures in common garden videos. all GUI.

useage: python foraging_activity.py

'''

# class to get the video from the user
class get_video:
    def __init__(self, master):

        def callback(self):
            global video_name
            video_name = self.askopenfilename()
        global video_name
        self.master = master
        master.title("please choose the video file")

        self.label = Label(master, text="please choose the video file to analyze")
        self.label.pack()

        self.quit_button = Button(text='Close after file is chosen', command=master.quit).pack()

        video_name = askopenfilename()

# class to create window to collect behavior observations from user
class get_behaviors:
    def __init__(self, master):

        self.master = master
        master.title("foraging and activity measures in common garden experiments")
        self.label = Label(master, text="enter in the number / time of behaviors in each box below")
        self.label.pack()


        # I can't find a better way around this stupidity (sorry):
        self.label1 = Label( master, text="number of foraging events recorded:  ")
        self.E1 = Entry(master, bd =5)
        self.label1.pack()
        self.E1.pack()

        self.label2 = Label( master, text="total number of foraging fish:  ")
        self.E2 = Entry(master, bd =5)
        self.label2.pack()
        self.E2.pack()

        self.label12 = Label( master, text="total time fish spent active (e.g. `01:15` for 1 minute and 15 seconds):  ")
        self.E12 = Entry(master, bd =5)
        self.label12.pack()
        self.E12.pack()

        self.label4 = Label( master, text="number of fish followed by the activity time:   ")
        self.E4 = Entry(master, bd =5)
        self.label4.pack()
        self.E4.pack()

        self.label11 = Label( master, text="comments:")
        self.E11 = Entry(master, bd =5)
        self.label11.pack()
        self.E11.pack()

        self.label15 = Label( master, text="your name:")
        self.E15 = Entry(master, bd =5)
        self.label15.pack()
        self.E15.pack()

        self.save_button = Button(master, text="Submit responses", command=self.on_button)
        self.save_button.pack()

        self.quit_button = Button(master, text="Close", command=master.quit)
        self.quit_button.pack()

    # save variables when the submit button is pressed
    def on_button(self):
        global number_foraging_events, number_foraging_fish, time_active, number_active, comments, observer
        number_foraging_events = self.E1.get()
        number_foraging_fish = self.E2.get()
        time_active = self.E12.get()
        number_active = self.E4.get()
        comments = self.E11.get()
        observer = self.E15.get()
        # master.quit

# loop dat video
def show_video(name):
    cap = cv2.VideoCapture(name)
    rotate = False
    M = cv2.getRotationMatrix2D((960,540), 180, 1.0)
    if not cap.isOpened():
      print("Error when reading video")
    else:
        while(True):
            try:
                # Capture frame-by-frame
                ret, frame = cap.read()
                if rotate:
                    frame = cv2.warpAffine(frame, M, (1920, 1080))
                cv2.putText(frame,'press the escape key when done',(20,20), cv2.FONT_HERSHEY_SIMPLEX, 1,(130,130,130),2)
                cv2.imshow(name,frame)
            except:
                cap = cv2.VideoCapture(name)
                ret, frame = cap.read()
                cv2.imshow(name,frame)
            k = cv2.waitKey(20)
            if k == 27:
                break
            elif k == 114:
                rotate = False if rotate is True else True

    # When everything done, release the capture
    cap.release()
    cv2.destroyAllWindows()
    return rotate

# check if a data directory exists; if  not, create it
def check_if_data_dir_exists(p):
    if not os.path.exists(os.path.join(p,'data')):
        os.makedirs(os.path.join(p,'data'))
    return os.path.join(p,'data')

# check if already watched dir exists; if not, create it
def check_if_already_watched_exists(p):
    if not os.path.exists(os.path.join(p,'already_watched_activity')):
        os.makedirs(os.path.join(p,'already_watched_activity'))
    return os.path.join(p,'already_watched_activity')

def get_creation_time(path):
    """Get the creation time of a file."""
    return os.stat(path).st_birthtime
#############################
## end function declarations ##
#################################


if __name__ == "__main__":

    # read om the videoname
    root = Tk()
    # get screen dimensions
    my_gui = get_video(root)
    root.mainloop()
    root.quit()
    root.destroy()
    print("video_name: {}".format(video_name))

    # show the video, on repeat if needed
    rotate = show_video(video_name)

    # close the windows
    cv2.destroyAllWindows(); cv2.waitKey(1)

    root2 = Tk()
    my_gui = get_behaviors(root2)
    root2.mainloop()
    root2.destroy()

    # the videos are named like 'week_of_04_03_2016_SS1_00:01'. let's extract the date and tank id from that
    path, video = os.path.split(video_name)

    # make sure it comforms to our naming convention:
    if len(video.split("_")) == 5:
        # get date
        date = video.split('_')[0:3]
        date = '-'.join(date)

        # get tank id
        tank_id = video.split('_')[-2]

        # get when in the video
        time_in_video = video.split('_')[-1].split('.')[0]

    # otherwise, call assign None
    else:
        tank_id = time_in_video = None
        date = get_creation_time(video_name)
    # get the data all together in a dictionary
    data = {
    'video_name' : video_name,
    'number_foraging_events' : number_foraging_events,
    'number_foraging_fish' : number_foraging_fish,
    'time_active' : time_active,
    'number_active' : number_active,
    'comments' : comments,
    'observer' :observer,
    'tank_id' : tank_id,
    'date' : date,
    'comments' : comments,
    'observer' : observer
    }

    # figure out how to name the resulting file
    name = video.split('.')[0] + '.json'
    data_dir = check_if_data_dir_exists(path)
    i = 1
    while os.path.isfile(data_dir + '/' + name):
        name = video.split('.')[0] + '_' + str(i) + '_activity.json'
        i += 1

    # save the data file in the data directory, first making sure it exists
    print(data_dir + '/' + name)
    try:
        with open(data_dir + '/' + name, 'w') as f:
            json.dump(data, f)

        # then move the file to the 'already_watched' directory
        save_to = check_if_already_watched_exists(path)
        print(save_to)

        os.rename(video_name, os.path.join(save_to, video))
        tkMessageBox.showinfo("oh yeahhh","\n\nall done. wahoo!\nthe data has been saved at {}".format(data_dir + '/' + name))
    except:
        print("oh no! problem writing the data file. See Luke.")
        tkMessageBox.showinfo("oh no!","oh no! problem writing the data file. See Luke.")

    cv2.destroyAllWindows()
