import cv2
import numpy as np
import sys
from math import sqrt
import json
import os.path
from Tkinter import *
from tkFileDialog import askopenfilename

'''

script for analyzing behaviors in common garden videos

useage: python locate_fish.py video.mp4


### TO DO:
##### add box select the path to the video
##### py2exe && py2app

'''

# get the distance between the last element of the list and everything before it; repeat until the list is empty
def pairwise_distance(locations):
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
        return reduce(lambda x, y: x + y, distances) / len(distances)


def distance(x,y):
    d = sqrt((y[0] - x[0])**2 + (y[1] - x[1])**2)
    return d


def get_first_frame(filename):
    cap = cv2.VideoCapture(filename)
    try:
        ret, frame = cap.read()
        print "dimensions of video: {}".format(frame.shape)
    except:
        sys.exit("problem reading the video file")

    cap.release()
    return frame

def get_male_locations(frame):

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
def draw_circles_males(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),5,(110, 85, 31),-1)
        print x,y
        male_locations.append((x,y))

def draw_circles_model_females(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),5,(178,104,252),-1)
        print "x : {}\ny: {}\n".format(x,y)
        model_female_locations.append((x,y))

def draw_circles_focal_females(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        cv2.circle(frame_copy,(x,y),5,(125,152,80),-1)
        print "x : {}\ny: {}\n".format(x,y)
        focal_female_locations.append((x,y))

def get_male_locations():
    cv2.putText(frame_copy,'select all the males',(10,100), cv2.FONT_HERSHEY_SIMPLEX, 1,(110, 85, 31),2)
    cv2.putText(frame_copy,'press escape when done',(400,100), cv2.FONT_HERSHEY_SIMPLEX, 1,(110, 85, 31),2)
    cv2.namedWindow('locate_males')
    cv2.setMouseCallback('locate_males', draw_circles_males)

    # show the frame
    while True:
        cv2.imshow('locate_males',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows; cv2.waitKey(1)
            break

    print "male locations: {}".format(male_locations)

def get_model_female_locations():
    cv2.putText(frame_copy,'select all the model females',(10,200), cv2.FONT_HERSHEY_SIMPLEX, 1,(178,104,252),2)
    # cv2.putText(frame_copy,'press escape when done',(400,200), cv2.FONT_HERSHEY_SIMPLEX, 1,(178,104,252),2)
    cv2.namedWindow('locate_females')
    cv2.setMouseCallback('locate_females', draw_circles_model_females)

    # show the frame
    while True:
        cv2.imshow('locate_females',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows; cv2.waitKey(1)
            break

    print "model female locations: {}".format(model_female_locations)

def get_focal_female_locations():
    cv2.putText(frame_copy,'select all the focal juveniles',(10,300), cv2.FONT_HERSHEY_SIMPLEX, 1,(125,152,80),2)
    # cv2.putText(frame_copy,'press escape when done',(400,300), cv2.FONT_HERSHEY_SIMPLEX, 1,(125,152,80),2)
    cv2.namedWindow('locate_focal_females')
    cv2.setMouseCallback('locate_focal_females', draw_circles_focal_females)

    # show the frame
    while True:
        cv2.imshow('locate_focal_females',frame_copy)
        if cv2.waitKey(20) & 0xFF == 27:
            cv2.destroyAllWindows
            break

    print "focal female locations: {}".format(focal_female_locations)

def show_video(name):
    cap = cv2.VideoCapture(name)
    if not cap.isOpened():
      print "Error when reading video"
    else:
        while(True):
            # Capture frame-by-frame
            ret, frame = cap.read()
            cv2.putText(frame,'press q when done',(20,20), cv2.FONT_HERSHEY_SIMPLEX, 1,(130,130,130),2)
            try:
                cv2.imshow(name,frame)
            except:
                cap = cv2.VideoCapture(name)
                ret, frame = cap.read()
                cv2.imshow(name,frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    # When everything done, release the capture
    cap.release()
    cv2.destroyAllWindows()

def get_info(text):
    print text,
    var = raw_input()
    while var.isdigit() == False:
        var = raw_input('please only input a digit: ')
    return var

def callback():
    name = askopenfilename()
    print name
    return name

def get_path():
    Button(text='open file:', command=callback).pack(fill=X)
    mainloop()

print "here"

if __name__ == "__main__":

    # read om the videoname
    video_name = sys.argv[1]

    # show the video, on repeat if needed
    show_video(video_name)

    # get first frame
    frame = get_first_frame(video_name)
    frame_copy = frame

    # get the male locations
    male_locations = []
    get_male_locations()

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

    # get info on aggressive interactions:
    print "aggressive interactions:\n\n",
    large_vs_large = get_info("number of times a large male was aggressive towards another large male: ")
    large_vs_small = get_info("number of times a large male was aggressive towards a small male: ")
    large_vs_female = get_info("number of times a large male was aggressive towards a female: ")
    small_vs_female = get_info("number of times a small male was aggressive towards a female: ")
    int_vs_female = get_info("number of times an intermediate male was aggressive towards a female: ")
    int_vs_int = get_info("number of times an intermediate male was aggressive towards another intermediate male: ")
    female_vs_female = get_info("number of times a female was aggressive towards another female: ")
    female_vs_male = get_info("number of times a female was aggressive towards a male : ")
    large_courting = get_info("number of times a large male courted a female : ")
    intermediate_courting = get_info("number of times an intermediate male courted a female : ")
    small_courting = get_info("number of times a small male courted a female : ")

    number_focal = len(focal_female_locations)
    number_male = len(male_locations)
    number_model_female = len(model_female_locations)

    tank_id = get_info("unique tank identifier (e.g. SS1) : ")

    try:
        from pick import pick
        title = 'Please choose the treatment of the tank: '
        options = ['all small males', 'all large males', 'large and small males', 'all intermediate males', 'all females', 'heterospecifics']
        treatment, index = pick(options, title)
        print "treatment : {}".format(treatment)
    except:
        pass
    # get the data all together in a dictionary
    data = {
    'focal_juvenile_locations' : focal_female_locations,
    'male_locations' : male_locations,
    'model_female_locations' : model_female_locations,
    'large_vs_large' : large_vs_large,
    'large_vs_small' : large_vs_small,
    'int_vs_int' : int_vs_int,
    'large_vs_female' : large_vs_female,
    'small_vs_female' : small_vs_female,
    'int_vs_female' : int_vs_female,
    'female_vs_female' : female_vs_female,
    'female_vs_male' : female_vs_male,
    'large_courting' : large_courting,
    'intermediate_courting' : intermediate_courting,
    'small_courting' : small_courting,
    'number_focal' : number_focal,
    'number_male' : number_male,
    'number_model_female' : number_model_female,
    'tank_id' : tank_id,
    'treatment' : treatment,
    'pairwise_distance_males' : pairwise_distance(male_locations),
    'pairwise_distance_females' : pairwise_distance(model_female_locations),
    'pairewise_distance_juvs' : pairwise_distance(focal_female_locations)
    }

    name = os.path.basename(video_name).split('.')[0] + '.json'
    i = 1
    while os.path.isfile(name):
        name = name.split('.')[0] + '_' + str(i) + '.json'
        i += 1

    try:
        with open(name, 'w') as f:
            json.dump(data, f)
    except:
        print "oh no! problem writing the data file. See Luke."

    print "\n\nall done. wahoo!\nthe data has been saved at {}".format(name)

    cv2.destroyAllWindows()
