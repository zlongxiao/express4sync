#!/bin/bash

read -p "please enter if update centos yum update:(Y or N)" -t 30 isUpdate
case $isUpdate in
Y|y|YES|yes)
    isUpdate1=true
  ;;
N|n|NO|no)
    isUpdate1=false
  ;;
*)
echo "Your choose is error!"
;;
esac

read -p "是否为主节点:(Y or N)" -t 30 isMain
case $isMain in
Y|y|YES|yes)
    isMain1=true
  ;;
N|n|NO|no)
    isMain1=false
  ;;
*)
echo "Your choose is error!"
;;
esac


read -p "是否通过yum安装syncthing(国内教慢，选择N将从国内下载):(Y or N)" -t 30 isYum
case $isYum in
Y|y|YES|yes)
    isYum1=true
  ;;
N|n|NO|no)
    isYum1=false
  ;;
*)
echo "Your choose is error!"
;;
esac

########删除已有数据 start########################
cd /home/
#结束进程
kill `ps aux | grep syncthing |grep -v grep| awk '{print $2}'`
rm -rf syncthing-linux-amd64-v1.4.0*
rm -rf /root/.config/syncthing/
rm -rf express4sync-master*
rm -rf /tmp/syncthing.log
pm2 delete sync-8383
########删除已有数据 end########################



#更新
if [[ $isUpdate1 = 'true' ]]; then
  yum update -y
fi
#安装依赖
yum install libaio wget curl unzip -y

#安装nodejs pm2
node -v
if [[ $? -eq 0 ]]; then
echo "node had installed"
else
curl --silent --location https://rpm.nodesource.com/setup_12.x | bash -
yum install -y nodejs
fi
echo 'node version:' `node -v`
echo 'npm version:' `npm -v`

pm2 -v
if [ $? -eq 0 ]
then
echo "pm2 had installed"
else
npm install pm2 -g
fi


echo 'pm2 version:' `pm2 -v`
#pm2 添加开机启动
pm2 startup

#安装express web服务
wget https://github.com/zlongxiao/express4sync/archive/master.zip
mv master.zip /home/express4sync-master.zip
unzip express4sync-master.zip
cd express4sync-master
npm install
pm2 start app.js --name sync-8383 --log-date-format 'YYYY-MM-DD HH:mm:ss.SSS'


#安装syncthing
echo "安装syncthing..."
if [ $isYum1 = 'true' ]; then
    rpm -ivh http://repo.okay.com.mx/centos/7/x86_64/release/okay-release-1-3.el7.noarch.rpm?
    yum install syncthing -y
    nohup syncthing >> /tmp/syncthing.log 2>&1 &
else
    cd /home/
    wget http://pmr.forke.cn:16666/api/alien/download/b74ee144-1b3f-4549-7f53-9aebbef3b42d/syncthing-linux-amd64-v1.4.0.tar.gz
    tar -xzvf syncthing-linux-amd64-v1.4.0.tar.gz
    cd syncthing-linux-amd64-v1.4.0
    nohup ./syncthing >> /tmp/syncthing.log 2>&1 &
fi
echo "安装syncthing成功..."

modifyConfig(){
    echo "修改配置文件................................"
    #修改配置文件
    config=/root/.config/syncthing/config.xml

    cp $config /root/.config/syncthing/config_back.xml
    #外网或局域网访问权限
    sed -i 's|<address>127.0.0.1:8384</address>|<address>0.0.0.0:8384</address>|' $config
    #主服务和从服务配置略有不同
    if [ $isMain1 = 'true' ]; then
        sed -i 's|name="localhost.localdomain"|name="main"|' $config
    else
        sed -i 's|name="localhost.localdomain"|name="node"|' $config
    fi
    echo "修改配置文件完成................................"
}

sleep 3s
ps_out=`ps -ef | grep syncthing |grep -v grep`
result=$(echo $ps_out)
if [ "$result" != "" ];then
    echo "Running"
    modifyConfig
else
    echo "Not Running"
fi

restart(){
    if [ $isYum1 = 'true' ]; then
        cd /root/syncthingLog/
        nohup syncthing  >> /tmp/syncthing.log 2>&1 &
    else
        cd /home/syncthing-linux-amd64-v1.4.0
        nohup ./syncthing >> /tmp/syncthing.log 2>&1 &
    fi
    echo "重启syncthing 成功"
}

###重启 syncthing
echo "重启syncthing...,等待创建配置文件..."
for ((i=10;i>0;i--)) 
do  
sleep 1s
echo "倒计时：$i秒";  
done  
kill `ps aux | grep syncthing |grep -v grep| awk '{print $2}'`
sleep 3s
s_out=`ps -ef | grep syncthing |grep -v grep`
result=$(echo $ps_out)
if [ "$result" != "" ];then
    echo "Running"
    restart
else
    echo "Not Running"
fi

echo "部署完成"
