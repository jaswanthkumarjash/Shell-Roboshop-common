#!/bin/bash

source ./common.sh

APP_NAME=nginx

check_root

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disabling existing nginx version"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enabling nginx version 1.24"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enabling nginx service" 

systemctl start nginx
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removing existing nginx page"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading frontend application"

cd /usr/share/nginx/html/
VALIDATE $? "Moving into nginx frontend code directory"

unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Unzipping frontend application code"

rm /etc/nginx/nginx.conf &>> $LOG_FILE
VALIDATE $? "Removing existing nginx configuration"

cp $FILE_PATH/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Creating new nginx configuration"

app_restart

time_taken_to_execute