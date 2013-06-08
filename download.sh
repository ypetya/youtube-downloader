#!/bin/bash

# @author : Peter Kiss - ypetya@gmail.com
# usage -> README
HELP="$( cat ${0%/*}/README.md )"


# Downloading param link from youtube using offliberty.com:
# --------------------------------------------------------
# Example request:
#
# http POST format:
# http://offliberty.com/off.php
# Request Method:POST
# Status Code:200 OK
# Form data :
# track=http://www.youtube.com/watch?NR=1&v=YOQjPrqWOwo&feature=endscreen

# --- FUNCTIONS

# this function will return the download url of a youtube video from offliberty
# DEBUG_ARGS="-D header_received.log"
function get_youtube_download_link() { 
  curl -s $DEBUG_ARGS --data-urlencode "track=$1" 'http://offliberty.com/off.php' | grep -o http.*mp3
}

# this function downloads the file
# it calls for a download url and if it is OK, it downloads the file
# param 1: the youtube link
# param 2: the file_name to save
function get_mp3_from_youtube() {
  DOWNLOAD_LINK="$(get_youtube_download_link $1 )"
  if [ -z "$DOWNLOAD_LINK" ]; then
    echo " Invalid download link, sorry."
  else
    echo " Download link: $DOWNLOAD_LINK"
    curl -o $2 $DOWNLOAD_LINK
  fi
}

# this function gets the youtube page of a video
# parses the title out from the HTML and creates the destenation file name
# if destenation file not found, it starts the downloading
function download_youtube_link() {
  echo " Downloading link: $1"
  BODY="$(curl -s $1)"
  while [ -z "$BODY" ]; do
    echo "No internet connection, waiting 10 sec"
    sleep 10
    BODY="$(curl -s $1)"
  done
  TITLE=$(echo $BODY | grep -o "title>.*</title>")
  TITLE=${MYSTRING//?(<\/)title>/}
  TITLE="$(echo $TITLE | tr ' ' '_' | tr -cd '[:alnum:]_-').mp3"
  FILE="$OUTPUT_DIR/$TITLE"
  if [ -f $FILE ]; then
    echo " File already exists. skipping: $FILE"
  else
    echo " Destenation: $FILE" 
    get_mp3_from_youtube $1 "$OUTPUT_DIR/$TITLE"
  fi
}

# this function gets all of the files in INPUT_DIR
# greps them for yourube links, and downloads them
# after a file is finished, it will be removed
function download_all_files_from_youtube {
  DIR=$(pwd)
  # getting links from input files 
  for f in $(ls -1 $INPUT_DIR/*); 
  do
    echo "Getting links from file : $f"
    LINKS=$(cat $f | grep -o "http[^\' \";,$]*")
    for link in $LINKS; do
      download_youtube_link $link
    done
    # removing  file after finished
    rm $f
  done

  cd $DIR
}

# --- SCRIPT STARTS HERE

# exit if script is already running
RUNNING=($(pidof -x $0))
if [ ${#RUNNING[@]} -gt 1 ]; then
  echo "Previous ${COMMAND} is still running, exiting."
  exit 1
fi

# interprete command prompt
if [ $# -eq 1 ]; then
  # number of params == 1 --> download it
  OUTPUT_DIR=$(pwd)
  download_youtube_link $1
elif [ $# -eq 2 ]; then
  # number of params == 2 --> using download dirs
  INPUT_DIR="${1%/}"
  OUTPUT_DIR="${2%/}"
  for d in $INPUT_DIR $OUTPUT_DIR; do mkdir -p $d; done
  download_all_files_from_youtube 
else
 echo "$HELP"
fi

