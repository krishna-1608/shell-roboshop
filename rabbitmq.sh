#!/bin/bash
userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_FILE=$( echo $0 | cut -d '.' -f1 )
LOG_FILE="$LOG_FOLDER/$SCRIPT_FILE.log" # /var/log/shell-script/12-logs.log
START_TIME=$(date +%s)

mkdir -p $LOG_FOLDER
SCRIPT_DIR=$PWD
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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE 
VALIDATE $? "Adding RabbitMq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE 
VALIDATE $? "installing RabbitMq server"
systemctl enable rabbitmq-server &>>$LOG_FILE 
VALIDATE $? "Enabling RabbitMq server"
systemctl start rabbitmq-server &>>$LOG_FILE 
VALIDATE $? "Starting RabbitMq server"
rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE 
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE 
VALIDATE $? "Setting up permisiion"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"