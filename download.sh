#!/bin/bash

# @author : Peter Kiss - ypetya@gmail.com
# usage -> README.md
# * script can be sourced
# * MinGW compatible


# this function prints out help message
function help() {
  HELP_FILE="${0%/*}/README.md"
  if [ -e "$HELP_FILE" ]; then
    cat "$HELP_FILE"
  else
    echo "bash mode"
    grep fun download.sh
  fi
}


# this function downloads the file [Call this]
# it calls for a download url and if it is OK, it downloads
#  * if curl is interrupted it retries (case of internet connection problem)
# fun param 1: the youtube link
# fun param 2: the file_name to save
function get_mp3_from_youtube() {
  local DOWNLOAD_LINK="$(get_youtube_download_link $1 )"
  if [ -z "$DOWNLOAD_LINK" ]; then
    echo " Invalid download link, sorry."
  else
    echo " Download link: $DOWNLOAD_LINK"
    local CURL_EXIT_CODE=18;
    local RETRY_COUNT=64;
    while [ $CURL_EXIT_CODE -eq 18 ]; do
      if [ $RETRY_COUNT -le 0]; then break; fi
      let RETRY_COUNT=$RETRY_COUNT-1
      curl -C -o $2 "$DOWNLOAD_LINK"; 
      CURL_EXIT_CODE=$?;
    done
  fi
}


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


# DEBUG_ARGS="-D header_received.log"
# this function will return the download url of a youtube video from offliberty
function get_youtube_download_link() { 
  curl -s $DEBUG_ARGS --data-urlencode "track=$1" 'http://offliberty.com/off.php' | perl -n -e 'while(/(http.*mp3)/){print "$1\n"}'
}


# this function gets the youtube page of a video
# parses the title out from the HTML and generates the destenation file name
# if destenation does not exist yet starts the downloading
function download_youtube_link() {
  echo " Downloading link: $1"
  BODY="$(curl -s $1)"
  while [ -z "$BODY" ]; do
    echo "No internet connection, waiting 10 sec"
    sleep 10
    BODY="$(curl -s $1)"
  done
  TITLE=$(echo $BODY | perl -n -e 'while(/(title>.*<\/title>)/){print "$1\n"}')
  TITLE="${TITLE#title>}"
  TITLE="${TITLE%</title>}"
  TITLE="$(echo $TITLE | tr ' ' '_' | tr -cd '[:alnum:]_-').mp3"
  FILE="$OUTPUT_DIR/$TITLE"
  if [ -f $FILE ]; then
    echo " File already exists. skipping: $FILE"
  else
    echo " Destenation: $FILE" 
    get_mp3_from_youtube $1 "$OUTPUT_DIR/$TITLE"
  fi
}


# this function gets all of the files from INPUT_DIR
# greps them for youtube links and downloads the videos as an audio mp3
# an input file will be removed after all the downloads finished
function download_all_files_from_youtube {
  DIR=$(pwd)
  # getting links from input files 
  for f in $(ls -1 $INPUT_DIR/*); 
  do
    echo "Getting links from file : $f"
    LINKS=$(cat $f | perl -n -e 'while(/(http[^'' ";,$]*)/){print "$1\n"}' )
    for link in $LINKS; do
      download_youtube_link $link
    done
    # removing file after finished
    rm $f
  done

  cd $DIR
}

# this function ensures script running only once
# check pidof exists MinGW / windows compatibility
function run_only_once() {
  if ! type pidof > /dev/null 2>&1; then 
    echo "Windows mode, no pidof"; 
  else
    # exit if script is already running
    RUNNING=($(pidof -x $0))
    if [ ${#RUNNING[@]} -gt 1 ]; then
      echo "Previous ${COMMAND} is still running, exiting."
      echo "RUNNING pids: $RUNNING"
      exit 1
    fi
  fi
}

# this function interpretes the input args
# interprete command prompt
function start() {
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
    help
  fi
}

run_only_once
start $*
