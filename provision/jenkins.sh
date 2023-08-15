#!/bin/bash

# Description: Install OpenJDK, Maven & Jenkins on Debian based OS.

logger(){

    # variables
    LOG_FILE_PATH=/tmp
    LOG_FILE_NAME=script.log

    if [ $# -eq 2 ]
    then
        SEVERITY="$1"
        LOG_MESSAGE="$2"
    elif [ $# -eq 1 ]
    then
        SEVERITY="INFO"
        LOG_MESSAGE="$1"
    else
        SEVERITY="EXCEPTION"
        LOG_MESSAGE="Wrong Sytax used for logger function. Usage: logger <SEVERITY> <LOG_MESSAGE>"
    fi
    
    echo -e "$(date '+%Y-%m-%d %T') $SEVERITY: $LOG_MESSAGE" >> $LOG_FILE_PATH/$LOG_FILE_NAME

}

logger "$0 Started"

logger "Updating Packages"
sudo apt update

logger "Installing OpenJDK & Maven"
sudo apt install openjdk-11-jdk -y
sudo apt install maven -y

logger "Adding Jenkins Repo"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

logger "Installing Jenkins"
sudo apt-get update
sudo apt-get install jenkins -y

logger "$0 Completed"
