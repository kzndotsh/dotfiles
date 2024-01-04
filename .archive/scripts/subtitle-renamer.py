#!/usr/bin/env python

# coding: utf-8

import os

import re



# get script directory and change os path to it

script_dir = os.path.abspath(__file__)[:-10]

os.chdir(script_dir)

files = os.listdir()



# create lists of common video and subtitle extensions

videoExtensions = [".mkv", ".mp4", ".avi", ".mov", ".wmv", ".flv", ".m4v", ".mpg", ".mpeg", ".m2v", ".3gp", ".3g2", ".f4v", ".f4p", ".f4a", ".f4b"]

subtitleExtensions = [".srt", ".sub", ".idx", ".ssa", ".ass", ".smi", ".rt", ".txt", ".mpl", ".vtt", ".dfxp", ".ttml", ".usf", ".xml", ".sup"]



# identify file type

def get_file_type(file: str, videoExtensions: list, subtitleExtensions: list):

    if file[-4:] in videoExtensions:

        return "video"

    elif file[-4:] in subtitleExtensions:

        return "sub"

    else:

        return None



# split files into video and subtitle lists

def classify_files(files: list, videoExtensions: list, subtitleExtensions: list) -> tuple:

    videos = []

    subs = []

    for file in files:

        filetype = get_file_type(file, videoExtensions, subtitleExtensions)

        if filetype == "video":

            videos.append(file)

        elif filetype == "sub":

            subs.append(file)

        else:

            print(f"unknown file type {file}")

    return videos, subs



# rename subs

def rename_file(subName: str, vidName: str, MODE = "DRY"):

    try:

        new_name = vidName[:-4] + subName[-4:]

        if MODE == "DRY":

            print(f"{subName} -> {new_name}")

        else:

            print(f"{subName} -> {new_name}")

            os.rename(subName, new_name)

    except:

        print("error")



# get episode number from file name using regex

def getEpisode(filename):

    match = re.search(

        r'''(?ix)                 # Ignore case (i), and use verbose regex (x)

        (?:                       # non-grouping pattern

          e|x|episode|^           # e or x or episode or start of a line

          )                       # end non-grouping pattern 

        \s*                       # 0-or-more whitespaces

        (\d{1,3})                   # exactly 2 digits

        ''', filename)

    if match:

        return int(match.group(1))



# function to delete files and print a message showing the operation

def delete(file: str, MODE = "DRY"):

    if MODE == "DRY":

        print(f"deleting {file}")

    else:

        print(f"deleting {file}")

        os.remove(file)





videos, subs = classify_files(files, videoExtensions, subtitleExtensions)



# check if the number of videos and subtitles match, else print warning and confirm to continue, else exit

if len(videos) != len(subs):

    print("Warning: Number of videos and subtitles do not match!")

    print(f"{len(videos)} videos and {len(subs)} subtitles")

    confirm = input("Continue? (y/n) ")

    if confirm == "y":

        pass

    else:

        print("Exiting...")

        exit()



# sort files

videos.sort(key = lambda x: x.replace(" ", "").split("-")[2])

subs.sort()



# loop through subs and get episode number. if video with same episode number exists, rename sub, keeping the extension. Else, print warning

for sub in subs:

    episode = getEpisode(sub)

    if episode:

        for vid in videos:

            if getEpisode(vid) == episode:

                rename_file(sub, vid, "DRY")

                break

        else:

            delete(sub, "DRY")

    else:

        print(f"Warning: No episode number found for {sub}")



# ask user if they want to rename the files and rename them if they do

confirm = input("Rename files? (y/n) ")

if confirm == "y":

    for sub in subs:

        episode = getEpisode(sub)

        if episode:

            for vid in videos:

                if getEpisode(vid) == episode:

                    rename_file(sub, vid, "RENAME")

                    break

            else:

                delete(sub, "RENAME")

        else:

            print(f"Warning: No episode number found for {sub}")   

else:

    print("Exiting...")

    exit()



# print completion message and ask user if they want to delete the python script

print("Done!")

confirm = input("Delete script? (y/n) ")

if confirm == "y":

    os.remove(__file__)

    print("Script deleted")

else:

    print("Script kept")

    exit()
