#!/bin/bash
userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_FILE=$( echo $0 | cut -d '.' -f1 )
LOG_FILE="$LOG_FOLDER/$SCRIPT_FILE.log" # /var/log/shell-script/12-logs.log

mkdir -p $LOG_FOLDER
echo "Script started executed at: $(date)"

if [ $userid -ne 0 ]; then
    echo "error:: run the script with root access" # if it is failed stop script excution
    exit 1 #failuers is other than 0 
fi

VALIDATE(){   #functions recive inputs through arhs jut like shell script arguments  
    if [ $1 -ne 0 ]; then
        echo -e "  $2 is $R failuer $N" | tee -a $LOG_FILE  #tee command will read and print terminal and sends to logs 
        exit 1 # if it is failed stop script excution
    else 
        echo -e "$2 is $G success $N"  | tee -a $LOG_FILE  
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mogodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enable mongodb"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "start mongodb"
