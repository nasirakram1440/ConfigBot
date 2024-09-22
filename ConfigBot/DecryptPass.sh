#!/bin/bash
#####################################################
# @Author: Muhammad Nasir Akram
# Last_change: 26.01.2024
#####################################################
pwd="${HOME}/ConfigBot"
temp_file="$2.pass"
echo $1 $2
echo  "$1" | openssl aes-256-cbc -d -a -pass pass:xxxxxxxx > $pwd/temp/$temp_file



