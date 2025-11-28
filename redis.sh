#!/bin/bash 

source ./common.sh

check_root

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling existing redis version"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling redis version 7"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections to redis and changing from protected-mode from yes to no"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enabling redis service"

systemctl start redis
VALIDATE $? "Starting redis service" 

time_taken_to_execute