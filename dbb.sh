#!/bin/bash
usr=$(id -u)
time=$(date +%F-%H-%M-%S)
scriptname=$(echo $0 | cut -d "." -f1)
log=/tmp/$scriptname-$time.log

u=$(id -u)

npu(){
    if [ $1 -ne 0 ]
    then
        echo "$2 failed"
    else
        echo "$2 success"
    fi
}

if [ $u -ne 0 ]
then
    echo "is this sudo"
    exit 1
else    
    echo "SUDO"
fi

dnf install mysql-server -y
npu $? "installing"

systemctl enable mysqld
systemctl start mysqld
npu $? "starting and enabling"

mysql -h db.vjeeth.site -uroot -pExpenseApp@1 -e 'show databases;' &>>log
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    npu $? "password root setup"
else
    echo "passwd already set"
fi