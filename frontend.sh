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
dnf install nginx -y &>>log_file
validate $? "install nginx"
systemctl enable nginx &>>log_file
validate $? "enable nginx"
systemctl start nginx &>>log_file
validate $? "start nginx"
rm -rf /usr/share/nginx/html/* &>>log_file
validate $? "remove default nginx code"
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>log_file
validate $? "download nginx code"
cd /usr/share/nginx/html
validate $? "change dir code"
unzip /tmp/frontend.zip &>>log_file
validate $? "unzip code"
cp $Scrpt_Dir/expense.service /etc/nginx/default.d/expense.conf
validate $? "copy system control"
systemctl restart nginx &>>log_file
validate $? "restart  nginx"