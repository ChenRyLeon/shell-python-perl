#!/bin/bash - 
#===============================================================================
#
#          FILE: ns.sh
# 
#         USAGE: ./ns.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YANG SHUO (ADMIN), shuo.yang@mail.lekan.com
#  ORGANIZATION: Linux and Open Source 
#       CREATED: 2017年09月12日 17时34分51秒
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了
for ((i=10;i<=100;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done
 
for DOMAIN in `cat domain.txt`
do
read -u3                           #代表从管道中读取一个令牌
{
        sleep 1  #sleep 1用来模仿执行一条命令需要花费的时间（可以用真实命令来代替）
        nslookup ${DOMAIN} 202.106.0.20       
        echo >&3                   #代表我这一次命令执行到最后，把令牌放回管道
}&
done
wait
 
stop_time=`date +%s`  #定义脚本运行的结束时间
 
echo "TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写
