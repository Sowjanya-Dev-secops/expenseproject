#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

log_folder="/var/log/roboshop-script"

user=$(id -u)
script_name=$( echo $0 | cut -d "." -f1 )
mkdir -p $log_folder
log_file="$log_folder/$script_name.log"
Script_Dir=$PWD

if [ $user -ne 0 ]; then
    echo -e "$R ERROR::$N proceed with root user"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R Error:: $N $2  failure" | tee -a $log_file
        exit 1
    else
        echo -e "$G Success:: $N $2 successful" | tee -a $log_file
    fi
}

dnf module disable nginx -y &>>$log_file
dnf module enable nginx:1.24 -y &>>$log_file
dnf install nginx -y &>>$log_file
VALIDATE $? "install nginx"
systemctl enable nginx &>>$log_file
VALIDATE $? "enabling nginx"
systemctl start nginx &>>$log_file

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "remove deafault nginx"
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$log_file
VALIDATE $? "downloading frontend code"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$log_file
VALIDATE $? "unzip nginx code"

cp $Script_Dir/frontend.service /etc/nginx/nginx.conf &>>$log_file
sleep 5
systemctl restart nginx &>>$log_file
VALIDATE $? "restart nginx"