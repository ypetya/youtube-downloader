Youtube downloader script
=========================

This script downloads mp3 files from youtube using offliberty.com

* To download a single file use the command:

    downloader.sh <youtube_link>

* Mass downloading
    
    downloader.sh <input_dir> <output_dir>

How it works
============

1. put files containing many youtube urls into the input directory 
2. run the script with the output dir specified
3. you will get the mp3s to the output directory

The output file name is determined from the youtube page HTML title

Reasons
=======

I wrote this script to download some music to my raspberry while I am sleeping :)
Author: Peter Kiss <ypetya@gmail.com>
