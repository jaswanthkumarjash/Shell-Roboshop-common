#!/bin/bash

source ./common.sh

START_TIME=$(date +%s)

APP_NAME=cart

check_root 

app_setup 

nodejs_setup

systemd_setup

time_taken_to_execute