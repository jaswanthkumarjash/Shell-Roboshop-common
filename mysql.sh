#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing Mysql server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabling Mysql service"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting Mysql service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Password setting for root user"

time_taken_to_execute