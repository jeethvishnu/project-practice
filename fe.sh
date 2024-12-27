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

dnf install nginx -y
npu $? "installing"

systemctl enable nginx
systemctl start nginx
npu $? "enabling and starting"

rm -rf /usr/share/nginx/html/*
npu $? "removing"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
npu $? "downloading"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
npu $? "unzipping"

cp /home/ec2-user/project-practice/expense.conf /etc/nginx/default.d/expense.conf
npu $? "conf file"

systemctl restart nginx
npu $? "restarting"

