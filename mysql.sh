#!/bin/bash

user=$(id -u)
if [ $user -ne 0 ]; then 
    echo "please proceed with root user pprevilage"
    exit 1
fi
script_dir=$PWD
logs_folder="/var/log/expense-script"
script_file= $( echo $0 | cut -d "." -f1 )
mkdir -p $logs_folder
log_file=$logs_folder/$script_file.log
echo "$log_file"