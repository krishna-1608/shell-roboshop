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

### NodeJS ###
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Creating sysytem user"

mkdir /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cataalogue application"

cd /app 
VALIDATE $? "changing to app directory"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "installing depndencies" 

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy sysytemctl service"

systemctl daemon-reload

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy mango repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "install mogodb client"

mongosh --host mongodb.krishna.icu </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load catalogue Products"

systemctl restart catalogue
VALIDATE $? "restart catalogue"


