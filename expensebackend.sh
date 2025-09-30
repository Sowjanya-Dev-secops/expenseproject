#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

user=$(id -u)
log_dir="/var/log/expense-script"
mkdir -p $log_dir
Scrpt_Dir=$PWD

script_file=$( echo $0 | cut -d "." -f1 )

log_file=$log_dir/$script_file.log

if [ $user -ne 0 ]; then
    echo "Error:: please proceede with root previlage"
fi

validate(){
    if [ $? -ne 0 ]; then
        echo -e "$R Error $N::$2 is failure "
        exit 1
    else
        echo -e "$G success $N:: $2 is succes "
    fi
}

dnf module disable nodejs -y &>>log_file
validate $? "disable nodejs"
dnf module enable nodejs:20 -y &>>log_file
validate $? "enable nodejs"
dnf install nodejs -y &>>log_file
validate $? "install nodejs"
useradd expense &>>log_file
validate $? "user add" 
mkdir /app

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>log_file
validate $? "down load application code"
cd /app
unzip /tmp/backend.zip &>>log_file
validate $? "unzip code"
npm install
validate $? "npm install" &>>log_file
cp  $Scrpt_Dir/expense.service /etc/systemd/system/backend.service
validate $? "copy system controll code"
systemctl daemon-reload 
systemctl start backend &>>log_file
validate $? "start backend" 
systemctl enable backend &>>log_file
validate $? "enable backend" 
dnf install mysql -y &>>log_file
validate $? "install mysql"
mysql -h mysql.msdevsecops.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>log_file
validate $? "dns add"
systemctl restart backend &>>log_file
validate $? "restart backend"


