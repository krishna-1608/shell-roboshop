#!/bin/bash
userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_FILE=$( echo $0 | cut -d '.' -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOG_FOLDER/$SCRIPT_FILE.log" # /var/log/shell-script/12-logs.log
START_TIME=$(date +%s)

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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling deafult redis version"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Validating remote connection to Redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "redis service enabled"
systemctl start redis &>>$LOG_FILE 
VALIDATE $? "redis service started"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"