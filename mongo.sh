#!/bin/bash

source ./common.sh

START_TIME=$(date +%s)

check_root

cp $FILE_PATH/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enabling mongod service"

systemctl start mongod
VALIDATE $? "Starting mongod service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod 
VALIDATE $? "Restarting mongod service"

time_taken_to_execute