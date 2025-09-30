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
}

dnf module disable nodejs -y
validate $? "disable nodejs"
dnf module enable nodejs:20 -y
validate $? "enable nodejs"
dnf install nodejs -y
validate $? "install nodejs"
useradd expense
validate $? "user add"
mkdir /app

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "down load application code"
cd /app
unzip /tmp/backend.zip
validate $? "unzip code"
npm install
validate $? "npm install"
cp  $Scrpt_Dir/expense.service /etc/systemd/system/backend.service
validate $? "copy system controll code"
systemctl daemon-reload
systemctl start backend
validate $? "start backend"
systemctl enable backend
validate $? "enable backend"
dnf install mysql -y
validate $? "install mysql"
mysql -h mysql.msdevsecops.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "dns add"
systemctl restart backend
validate $? "restart backend"


