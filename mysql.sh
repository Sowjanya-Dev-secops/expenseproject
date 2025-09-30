#!/bin/bash

user=$(id -u)
if [ $user -ne 0 ]; then 
    echo "please proceed with root user pprevilage"
    exit 1
fi
script_dir=$PWD
logs_folder="/var/log/expense-script"
script_file=$( echo $0 | cut -d "." -f1 )


mkdir -p $logs_folder
log_file=$logs_folder/$script_file.log
echo "$log_file"

validate(){
    if [ $1 -ne 0 ]; then
        echo "Error :: $2 is failled"
    else
        echo "SUCCESS :: $2 is success"
    fi
}
dnf install mysql-server -y &>>log_file
validate $? "Mysql Installation"

systemctl enable mysqld &>>log_file
validate $? "enable mysql"

systemctl start mysqld &>>log_file
validate $? "start mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>log_file
validate $? "set password"