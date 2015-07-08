#!/usr/bin/env python
"""Find and copy datavyu (.opf) files

This will search through a directory tree to find only .opf files.
All subfolders will be searched within the root folder you specify.
Select the root folder through the prompt, then select your destination.
Files will be copied to destination.

Save this file to the desktop (otherwise cd to folder with this file).
Open up a terminal (in utilities folder inside your applications).
Type the two lines below in the terminal:

mkdir ~/Desktop/dump
cd ~/Desktop
python findopf.py

After you run the python script you'll select the folder which contains the
.opf files, then select a folder to copy them over (dump).

Note: Must have Tk installed with your python distribution.
"""

from Tkinter import Tk
from tkFileDialog import askdirectory
import os
import shutil

def getFilePaths():
    look_dir = os.path.abspath(os.path.expanduser("~/Desktop"))
    root = Tk()
    root.withdraw()
    print("Choose starting folder to find .opf files")
    search_path = askdirectory(
        title='Choose starting folder to find .opf files',
        initialdir=look_dir,
        parent=root)
    print("Choose folder to copy over found .opf files")
    copy_path = askdirectory(
        title='Choose folder to copy over found .opf files',
        initialdir=look_dir,
        parent=root)
    root.destroy()
    return search_path, copy_path

if __name__ == '__main__':
    search_path_ret, copy_path_ret = getFilePaths()
    os.chdir(search_path_ret)
    print("Changing to directory:")
    print(os.getcwd())

    for root, dirs, files in os.walk('.'):
        for filestr in files:
            if filestr.endswith(".opf"):
                fileJoin = os.path.join(root, filestr)
                shutil.copy(fileJoin, copy_path_ret)
                print(''.join(["copying over: ", filestr]))

    print("Done")


