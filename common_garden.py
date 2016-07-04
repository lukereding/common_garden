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

script for analyzing behaviors in common garden videos. all GUI.

useage: python locate_fish.py

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
        master.title("behavior yourself!")

        self.label = Label(master, text="enter in the number of behaviors in each box below")
        self.label.pack()


        # I can't find a better way around this stupidity (sorry):
        self.label1 = Label( master, text="number of times a large male was aggressive towards another large male: ")
        self.E1 = Entry(master, bd =5)
        self.label1.pack()
        self.E1.pack()

        self.label2 = Label( master, text="number of times a large male was aggressive towards a small male:  ")
        self.E2 = Entry(master, bd =5)
        self.label2.pack()
        self.E2.pack()

        self.label12 = Label( master, text="number of times a large male was aggressive towards a female: ")
        self.E12 = Entry(master, bd =5)
        self.label12.pack()
        self.E12.pack()

        self.label4 = Label( master, text="number of times a small male was aggressive towards a female:")
        self.E4 = Entry(master, bd =5)
        self.label4.pack()
        self.E4.pack()

        self.label5 = Label( master, text="number of times an intermediate male was aggressive towards a female: ")
        self.E5 = Entry(master, bd =5)
        self.label5.pack()
        self.E5.pack()

        self.label6 = Label( master, text="number of times an intermediate male was aggressive towards another intermediate male: ")
        self.E6 = Entry(master, bd =5)
        self.label6.pack()
        self.E6.pack()

        self.label7 = Label( master, text="number of times a female was aggressive towards another female: ")
        self.E7 = Entry(master, bd =5)
        self.label7.pack()
        self.E7.pack()

        self.label3 = Label( master, text="number of times a female was aggressive towards a male: ")
        self.E3 = Entry(master, bd =5)
        self.label3.pack()
        self.E3.pack()

        self.label8 = Label( master, text="number of times a large male courted a female: ")
        self.E8 = Entry(master, bd =5)
        self.label8.pack()
        self.E8.pack()

        self.label9 = Label( master, text="number of times an intermediate male courted a female:")
        self.E9 = Entry(master, bd =5)
        self.label9.pack()
        self.E9.pack()

        self.label10 = Label( master, text="number of times a small male courted a female:")
        self.E10 = Entry(master, bd =5)
        self.label10.pack()
        self.E10.pack()

        self.label13 = Label( master, text="number of times a males chased a juvenile:")
        self.E13 = Entry(master, bd =5)
        self.label13.pack()
        self.E13.pack()

        self.label11 = Label( master, text="comments:")
        self.E11 = Entry(master, bd =5)
        self.label11.pack()
        self.E11.pack()

        self.save_button = Button(master, text="Submit responses", command=self.on_button)
        self.save_button.pack()

        self.quit_button = Button(master, text="Close", command=master.quit)
        self.quit_button.pack()

    # save variables when the submit button is pressed
    def on_button(self):
        global large_vs_large, large_vs_small, small_vs_female, int_vs_female, int_vs_int, female_vs_female, female_vs_male, large_court, int_court, small_court, large_vs_female, male_chased_juvenile, comments
        large_vs_large = self.E1.get()
        large_vs_small = self.E2.get()
        small_vs_female = self.E4.get()
        int_vs_female = self.E5.get()
        int_vs_int = self.E6.get()
        female_vs_female = self.E7.get()
        female_vs_male = self.E3.get()
        large_court = self.E8.get()
        int_court = self.E9.get()
        small_court = self.E10.get()
        large_vs_female = self.E12.get()
        male_chased_juvenile = self.E13.get()
        comments = self.E11.get()

# to get frame to use for identifying the fish from the user; return the number of the frame to use
def get_frame(name, rotate):
    cap = cv2.VideoCapture(name)
    ret, img = cap.read()
    if ret is False:
        sys.exit("couldn't read the video file.")
    if rotate:
        M = cv2.getRotationMatrix2D((960,540), 180, 1.0)
        img = cv2.warpAffine(img, M, (1920, 1080))
    frame_number = 1
    total_frames = cap.get(7)
    while(1):
        # put instructions on the frame
        cv2.putText(img,'select a frame where you can see the max. number of fish',(10,100), cv2.FONT_HERSHEY_SIMPLEX, 1,(0,0,0),2)
        cv2.putText(img,'press the forward and backwards keys to navigate',(10,200), cv2.FONT_HERSHEY_SIMPLEX, 1,(0,0,0),2)
        cv2.putText(img,'press Escape when you find a suitable frame',(10,300), cv2.FONT_HERSHEY_SIMPLEX, 1,(0,0,0),2)
        # show the frame
        cv2.imshow('select a frame where you can see the max. number of fish',img)
        k = cv2.waitKey(33)
        if k == 63235 and (total_frames - frame_number) > 10: # right arrow
            frame_number += 10 # skip 10 frames at a time, otherwise too tedious
            ret = cap.set(1,frame_number)
            ret, img = cap.read()
            if rotate:
                img = cv2.warpAffine(img, M, (1920, 1080))
        elif k == 63234 and (total_frames - frame_number) > 10: # left arrow
            frame_number -= 10
            ret = cap.set(1,frame_number)
            ret, img = cap.read()
            if rotate:
                img = cv2.warpAffine(img, M, (1920, 1080))
        elif k == 27: # escape
            break
        # if the user gets to the end of the video, reset the video
        elif (total_frames - frame_number) < 10:
            cap.set(1,1)
            ret, img = cap.read()
            frame_number = 1
    cv2.destroyAllWindows; cv2.waitKey(1)
    cap.release()
    return frame_number

def get_creation_time(path):
    """Get the creation time of a file."""
    return os.stat(path).st_birthtime

def tuple_to_list(x):
    return [list(a) for a in x]

def pairwise_distance(locations):
    """Get the distance between the last element of the list and everything before it; repeat until the list is empty."""
    loc = locations
    # returns None if there's only one location.
    if len(loc) == 1:
        return None
    else:
        distances = []
        while len(loc) >= 2:
            last_location = loc.pop()
            # probably a better way to do this that doesn't require nesting a list
            distances.append([distance(last_location, i) for i in loc])
        distances = sum(distances, [])
        return round(reduce(lambda x, y: x + y, distances) / len(distances) , 2)


def distance(x,y):
    """Find distance in two dimensions."""
    d = sqrt((y[0] - x[0])**2 + (y[1] - x[1])**2)
    return d

def get_correct_frame(filename, number, rotate):
    """Get the nth frame from a video for the user to locate the fish."""
    cap = cv2.VideoCapture(filename)
    M = cv2.getRotationMatrix2D((960,540), 180, 1.0)
    try:
        cap.set(1, number)
        ret, frame = cap.read()
        if rotate:
            frame = cv2.warpAffine(frame, M, (1920, 1080))
    except:
        sys.exit("problem reading the video file")

    cap.release()
    return frame

def get_male_locations(frame):
    """Get locations of males in tank."""
    # print instructions on the frame
    cv2.putText(frame,'select all the males',(10,100), cv2.FONT_HERSHEY_SIMPLEX, 3,(255,255,255),2)

    # create window
    cv2.namedWindow('first_frame')

    # create callback function
    cv2.setMouseCallback('first_frame', draw_circles)

    # show the frame
    while True:
        cv2.imshow('first_frame',frame)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows; cv2.waitKey(1)
            break

# mouse callback function
def draw_circles_large_males(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),8,(110, 85, 31),-1)
        print x,y
        large_male_locations.append((x,y))

def draw_circles_model_females(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),8,(178,104,252),-1)
        print "x : {}\ny: {}\n".format(x,y)
        model_female_locations.append((x,y))

def draw_circles_focal_females(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),8,(125,152,80),-1)
        print "x : {}\ny: {}\n".format(x,y)
        focal_female_locations.append((x,y))

def draw_circles_small_males(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),8,(200, 200, 200),-1)
        print x,y
        small_male_locations.append((x,y))

def get_large_male_locations():
    cv2.putText(frame_copy,'select all large (or intermediate) males',(10,100), cv2.FONT_HERSHEY_SIMPLEX, 1,(0, 0, 0),2)
    cv2.putText(frame_copy,'press escape when done',(700,100), cv2.FONT_HERSHEY_SIMPLEX, 1,(0, 0, 0),2)
    cv2.namedWindow('locate_large_males')
    cv2.setMouseCallback('locate_large_males', draw_circles_large_males)

    # show the frame
    while True:
        cv2.imshow('locate_large_males',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows()
            break

    print "large male locations: {}".format(large_male_locations)

def get_small_male_locations():
    cv2.putText(frame_copy,'select all the small males',(10,150), cv2.FONT_HERSHEY_SIMPLEX, 1,(200, 200, 200),2)
    cv2.namedWindow('locate_small_males')
    cv2.setMouseCallback('locate_small_males', draw_circles_small_males)

    # show the frame
    while True:
        cv2.imshow('locate_small_males',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows()
            break

    print "small_male locations: {}".format(small_male_locations)


def get_model_female_locations():
    cv2.putText(frame_copy,'select all the model females',(10,200), cv2.FONT_HERSHEY_SIMPLEX, 1,(178,104,252),2)
    # cv2.putText(frame_copy,'press escape when done',(400,200), cv2.FONT_HERSHEY_SIMPLEX, 1,(178,104,252),2)
    cv2.namedWindow('locate_females')
    cv2.setMouseCallback('locate_females', draw_circles_model_females)

    # show the frame
    while True:
        cv2.imshow('locate_females',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows()
            break

    print "model female locations: {}".format(model_female_locations)

def get_focal_female_locations():
    cv2.putText(frame_copy,'select all the focal juveniles',(10,250), cv2.FONT_HERSHEY_SIMPLEX, 1,(125,152,80),2)
    # cv2.putText(frame_copy,'press escape when done',(400,300), cv2.FONT_HERSHEY_SIMPLEX, 1,(125,152,80),2)
    cv2.namedWindow('locate_focal_females')
    cv2.setMouseCallback('locate_focal_females', draw_circles_focal_females)

    # show the frame
    while True:
        cv2.imshow('locate_focal_females',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows()
            break

    print "focal female locations: {}".format(focal_female_locations)

# loop dat video
def show_video(name):
    cap = cv2.VideoCapture(name)
    rotate = False
    M = cv2.getRotationMatrix2D((960,540), 180, 1.0)
    if not cap.isOpened():
      print "Error when reading video"
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

# not used
def get_info(text):
    print text,
    var = raw_input()
    while var.isdigit() == False:
        var = raw_input('please only input a digit: ')
    return var

# check if a data directory exists; if  not, create it
def check_if_data_dir_exists(p):
    if not os.path.exists(os.path.join(p,'data')):
        os.makedirs(os.path.join(p,'data'))
    return os.path.join(p,'data')

# check if already watched dir exists; if not, create it
def check_if_already_watched_exists(p):
    if not os.path.exists(os.path.join(p,'already_watched')):
        os.makedirs(os.path.join(p,'already_watched'))
    return os.path.join(p,'already_watched')

# not used anymore
def double_list(l):
    return [(x*2, y*2) for (x,y) in l]

# no longer used; get screen dimensions, return 'small' is smaller than HD
# not used
def get_screen_dim(r):
    screen_width = r.winfo_screenwidth()
    screen_height = r.winfo_screenheight()
    if screen_width < 1920:
        size = "small"
    else:
        size = "fine"
    return screen_width, screen_height, size



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
    print "video_name: {}".format(video_name)

    # show the video, on repeat if needed
    rotate = show_video(video_name)

    # get frame number to use from the video from the user
    frame_number = get_frame(video_name, rotate)

    # get first frame
    frame = get_correct_frame(video_name, frame_number, rotate)
    frame_copy = frame

    # get the large male locations
    frame_copy = frame
    large_male_locations = []
    get_large_male_locations()

    # get the small male locations
    frame_copy = frame
    small_male_locations = []
    get_small_male_locations()

    # get model female locations
    frame_copy = frame
    model_female_locations = []
    get_model_female_locations()

    # get focal female locations
    frame_copy = frame
    focal_female_locations = []
    get_focal_female_locations()

    # close the windows`
    cv2.destroyAllWindows(); cv2.waitKey(1)

    root2 = Tk()
    my_gui = get_behaviors(root2)
    root2.mainloop()
    root2.destroy()

    # get number of each type of fish
    number_focal = len(focal_female_locations)
    number_large_male = len(large_male_locations)
    number_small_male = len(small_male_locations)
    number_model_female = len(model_female_locations)
    total_fish = number_focal + number_large_male + number_small_male + number_model_female

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
    print "mode female locations: {}".format(model_female_locations)
    # get the data all together in a dictionary
    data = {
    'video_name' : video_name,
    'focal_juvenile_locations' : tuple_to_list(focal_female_locations),
    'large_male_locations' : tuple_to_list(large_male_locations),
    'small_male_locations' : tuple_to_list(small_male_locations),
    'model_female_locations' : tuple_to_list(model_female_locations),
    'large_vs_large' : large_vs_large,
    'large_vs_small' : large_vs_small,
    'int_vs_int' : int_vs_int,
    'large_vs_female' : large_vs_female,
    'small_vs_female' : small_vs_female,
    'int_vs_female' : int_vs_female,
    'female_vs_female' : female_vs_female,
    'female_vs_male' : female_vs_male,
    'large_courting' : large_court,
    'intermediate_courting' : int_court,
    'small_courting' : small_court,
    'number_focal' : number_focal,
    'number_large_male' : number_large_male,
    'number_small_male' : number_small_male,
    'number_model_female' : number_model_female,
    'male_chased_juvenile' : male_chased_juvenile,
    'tank_id' : tank_id,
    'pairwise_distance_large_males' : pairwise_distance(large_male_locations) if large_male_locations else "NA",
    'pairwise_distance_small_males' : pairwise_distance(small_male_locations) if small_male_locations else "NA",
    'pairwise_distance_females' : pairwise_distance(model_female_locations) if model_female_locations else "NA",
    'pairewise_distance_juvs' : pairwise_distance(focal_female_locations) if focal_female_locations else "NA",
    'total_fish' : total_fish,
    'time_of_clip' : time_in_video,
    'date' : date,
    'comments' : comments
    }

    # figure out how to name the resulting file
    name = video.split('.')[0] + '.json'
    data_dir = check_if_data_dir_exists(path)
    i = 1
    while os.path.isfile(data_dir + '/' + name):
        name = video.split('.')[0] + '_' + str(i) + '.json'
        i += 1

    # save the data file in the data directory, first making sure it exists
    print data_dir + '/' + name
    try:
        with open(data_dir + '/' + name, 'w') as f:
            json.dump(data, f)

        # then move the file to the 'already_watched' directory
        save_to = check_if_already_watched_exists(path)
        print save_to

        os.rename(video_name, os.path.join(save_to, video))
        tkMessageBox.showinfo("oh yeahhh","\n\nall done. wahoo!\nthe data has been saved at {}".format(data_dir + '/' + name))
    except:
        print "oh no! problem writing the data file. See Luke."
        tkMessageBox.showinfo("oh no!","oh no! problem writing the data file. See Luke.")


    print "\n\nall done. wahoo!\nthe data has been saved at {}".format(data_dir + '/' + name)

    cv2.destroyAllWindows()
