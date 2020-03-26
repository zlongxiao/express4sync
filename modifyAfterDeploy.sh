#!/bin/bash

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



modifyConfig(){
    echo "修改配置文件................................"
    #修改配置文件
    config=/root/.config/syncthing/config.xml

    cp $config /root/.config/syncthing/config_back.xml

    sed -i 's|<address>127.0.0.1:8384</address>|<address>0.0.0.0:8384</address>|' $config
    #主服务和从服务配置略有不同
    if [ $isMain1 = 'true' ]; then
        sed -i 's|type="readwrite"|type="sendonly"|' $config
        sed -i 's|name="localhost.localdomain"|name="main"|' $config
    else
        sed -i 's|name="localhost.localdomain"|name="node"|' $config
        sed -i 's|type="readwrite"|type="receiveonly"|' $config
    fi
    ##非常重要
    sed -i 's|<ignoreDelete>false</ignoreDelete>|<ignoreDelete>true</ignoreDelete>|' $config
    
    #sed -i 's|<order>random</order>|<order>newestFirst</order>|' $config
    #sed -i 's|<minDiskFree unit="%">1</minDiskFree>|<minDiskFree unit="%">90</minDiskFree>|' $config
    #下面两个没有意义
    ##sed -i 's|path="/root/Sync"|path="/home/express4sync-master/public"|' $config
    ##sed -i 's|label="Default Folder"|label="public"|' $config

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
        nohup syncthing &
    else
        cd /home/syncthing-linux-amd64-v1.4.0
        nohup ./syncthing &
    fi
    echo "重启syncthing 成功"
}

###重启 syncthing
echo "重启syncthing..."
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





