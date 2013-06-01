#!/bin/bash

#
# @author : Peter Kiss - ypetya@gmail.com
#
# Youtube downloader can download multiple mp3 files from youtube using offliberty.com
#
# How it works?
# -------------
# 1. put files into the input directory, named as the output you would like, containing the youtube url
# 2. run the script
# 3. you will get the mp3s in the output drectory, with the same filename as you defined
#
# Example usage:
# -------------
# 1. feed the input as the following
# echo "youtube.com/v=asadfjh" > input/my.mp3
# this will result to download the music as an mp3 to output/my.mp3
# 2. ./youtube_downloader.sh
# 3. listen music
# mplayer output/*.mp3

# --- CONFIG SECTION

if[ -z $OUTPUT_DIR]; then
  OUTPUT_DIR="output"
fi

if[ -z $INPUT_DIR]; then
  INPUT_DIR="input"
fi

# --- SCRIPT STARTS HERE



# downloading param link from youtube using offliberty.com

# http POST format:
# http://offliberty.com/off.php
# Request Method:POST
# Status Code:200 OK
# Form data :
# track:http://www.youtube.com/watch?NR=1&v=YOQjPrqWOwo&feature=endscreen

# this function will return the download url
function get_youtube_download_link() { 
  curl -D header_received.log --data-urlencode "track=$1" 'http://offliberty.com/off.php' | grep -o http.*mp3;}

# this function downloads the file
# param 1: the youtube link
# param 2: the file_name to save
function get_mp3_from_youtube() {
  curl `get_youtube_download_link $1` > $2
}

function download_all_files_from_youtube {


}

