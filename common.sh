#!/bin/bash

START_TIME=$(date +%s)

USERID=$(id -u)

R="\E[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FILE_PATH=$PWD
LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOG_FOLDER
MONGODB_HOST=mongo.jaswanthjash12.shop
MYSQL_HOST=mysql.jaswanthjash12.shop


check_root () {
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: YOU dont have root access"
        exit 1
    fi
}

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R FAILED$N"
        exit 2
    else
        echo -e "$2 ...$G SUCCESS$N"
    fi
}


app_setup () {

    id roboshop &>> $LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "Roboshop system user" roboshop
        VALIDATE $? "System user creation"
    else
        echo -e "System user already exist ...$Y SKIPPING$N" | tee -a $LOG_FILE
    fi

    mkdir -p /app
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>> $LOG_FILE
    VALIDATE $? "Downloading $APP_NAME application code"

    rm -rf /app/*
    VALIDATE $? "Removing the existing code"

    cd /app
    VALIDATE $? "Moving into /app directory"

    unzip /tmp/$APP_NAME.zip &>> $LOG_FILE
    VALIDATE $? "Unzipping the $APP_NAME application code"

}


nodejs_setup () {
    dnf module disable nodejs -y &>> $LOG_FILE
    VALIDATE $? "Disabling existing nodejs"

    dnf module enable nodejs:20 -y &>> $LOG_FILE
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>> $LOG_FILE
    VALIDATE $? "Installing nodejs"

    npm install &>> $LOG_FILE
    VALIDATE $? "Installing dependencies"

}

java_setup (){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Packing the application"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming the artifact"
}

python_setup (){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"
    
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

go_setup () {

    dnf install golang -y &>> $LOG_FILE
    VALIDATE $? "Installing Golang"

    go mod init dispatch &>> $LOG_FILE
    VALIDATE $? "Initialize dispatch module"

    go get &>> $LOG_FILE
    VALIDATE $? "Update the dependencies"

    go build &>> $LOG_FILE
    VALIDATE $? "Compile and make it executable"

}


systemd_setup () {
    cp $FILE_PATH/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Creating systemd service"

    systemctl daemon-reload
    VALIDATE $? "Daemon-reload"

    systemctl enable $APP_NAME &>> $LOG_FILE
    VALIDATE $? "Enabling $APP_NAME service"

    systemctl start $APP_NAME
    VALIDATE $? "Starting $APP_NAME service"
}

app_restart () {
    systemctl restart $APP_NAME
    VALIDATE $? "Restarting $APP_NAME service"
}

time_taken_to_execute () {
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo "Total script execution time is $TOTAL_TIME seconds"
}