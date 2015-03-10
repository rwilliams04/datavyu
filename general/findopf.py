#!/usr/bin/env python
"""Find and copy datavyu (.opf) files

This will search through a directory tree to find only .opf files.
All subfolders will be searched within the root folder you specify.
Select the root folder through the prompt, then select your destination.
Files will be copied to destination.

Save this file to the desktop (otherwise cd to folder with this file).
Open up a terminal (in utilities folder inside your applications).
Type the two lines below in the terminal:

cd ~/Desktop
python findopf.py

Note: Must have Tk installed with your python distribution.
"""

from Tkinter import Tk
from tkFileDialog import askdirectory
import os
import shutil

opfDir = "~/Desktop"

Tk().withdraw()

opfPath = os.path.abspath(os.path.expanduser(opfDir))

foldername = askdirectory(
    title='Choose starting folder to find .opf files',
    initialdir=opfPath)

newfolder = askdirectory(
    title='Choose folder to copy over found .opf files',
    initialdir=opfPath)

os.chdir(foldername)
print(os.getcwd())

for root, dirs, files in os.walk('.'):
    for filestr in files:
        if filestr.endswith(".opf"):
            fileJoin = os.path.join(root, filestr)
            shutil.copy(fileJoin, newfolder)
            print(''.join(["copying over: ", filestr]))

print("Done")

