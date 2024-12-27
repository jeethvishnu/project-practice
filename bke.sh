#!/bin/bash
usr=$(id -u)
time=$(date +%F-%H-%M-%S)
scriptname=$(echo $0 | cut -d "." -f1)
log=/tmp/$scriptname-$time.log

# u=$(id -u)
npu(){
    if [ $1 -ne 0 ]
    then
        echo "$2 failed"
    else
        echo "$2 success"
    fi
}

if [ $usr -ne 0 ]
then
    echo "is this sudo"
    exit 1
else    
    echo "SUDO"
fi

dnf module list nodejs -y
npu $? "listing"

dnf module disable nodejs -y
npu $? "disabling"

dnf module enable nodejs:20 -y
npu $? "enabling"

dnf install nodejs -y
npu $? "installing"

id expense &>>log
if [ $? -ne 0 ]
then
    useradd expense
    npu $? "adding usr"
else
    echo "user already exist"
fi

mkdir -p /app
npu $? "dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
npu $? "zipfile"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
npu $? "unzipping"

npm install &>>log
npu $? "npm running"

cp /home/ec2-user/project-practice/backend.service /etc/systemd/system/backend.service
npu $? "copying"

systemctl daemon-reload &>>log

systemctl start backend &>>log

systemctl enable backend &>>log
npu $? "starting and enabling"

dnf install mysql -y &>>log
npu $? "installing"

mysql -h db.vjeeth.site -uroot -pExpenseApp@1 < /app/schema/backend.sql
npu $? "schema"

systemctl restart backend &>>log
npu $? "restarting"
