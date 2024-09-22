#!/bin/bash

#####################################################
# @Author: Muhammad Nasir Akram
# Last_change: 03.05.2024
# This script pings a specific host x number of times
#####################################################

# Note: Change the 'pwd' & 'whichping' according to the environment
declare -i number_of_times_to_ping
pwd="${HOME}/ConfigBot"
whichping=/usr/bin/ping
whichecho=/usr/bin/echo
number_of_times_to_ping=3
if [ $# -eq 0 ]
 then 
  $whichecho "No arguments passed"
elif [ $# -eq 1 ]
 then
  #echo "One argument passed"
  #echo "$1"
  $whichping $1 -c $number_of_times_to_ping ;
  # Set the environment variable PING_RESULT to the value of $?
  result=$?
  $whichecho "$result" > $pwd/LastPingResult.log
elif [ $# -eq 2 ]
 then
  
  #echo "Two arguments passed, the second argument should be results file name
  
  $whichping $1 -c $number_of_times_to_ping ;
  # Set the environment variable PING_RESULT to the value of $?
  result=$?
  $whichecho "$result" > $pwd/$2
else
 $whichecho "Nothing matched"
fi

