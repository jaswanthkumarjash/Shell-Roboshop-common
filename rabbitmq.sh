#!/bin/bash

source ./common.sh

check_root

cp $FILE_PATH/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding RabbitMQ repo"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling Rabbitmq server"

systemctl start rabbitmq-server
VALIDATE $? "Start Rabbitmq server"

if rabbitmqctl list_users | grep -q "^roboshop"; then
    echo -e "Roboshop user already exists ...$Y SKIPPING$N"
else
    rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
    VALIDATE $? "Adding roboshop user"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "Setting permissions"

time_taken_to_execute